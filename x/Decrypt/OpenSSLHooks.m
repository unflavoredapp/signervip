#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import "fishhook.h"
#import "DatabaseManager.h"

#define LOG(fmt, ...) NSLog(@"[OpenSSLHooks] " fmt, ##__VA_ARGS__)

extern NSString *CurrentBundleID(void);
extern NSString *HexStringFromBytes(const void *bytes, size_t length);
extern void IZXAddDecryptionKeyCandidate(NSData *keyData, NSData *ivData, NSString *source);

#pragma mark - Tool tool-tool function functions for

static NSString *Base64StringFromBytes(const void *bytes, size_t length) {
    if (!bytes || length == 0) return @"";
    return [[NSData dataWithBytes:bytes length:length] base64EncodedStringWithOptions:0] ?: @"";
}

static NSString *ReadableStringFromBytes(const void *bytes, size_t length) {
    if (!bytes || length == 0) return @"";
    NSString *text = [[NSString alloc] initWithBytes:bytes length:length encoding:NSUTF8StringEncoding];
    return text ?: @"(Non-non non UTF-8 The data of the Data)";
}

static int (*dyn_EVP_CIPHER_key_length)(const void *cipher) = NULL;
static int (*dyn_EVP_CIPHER_iv_length)(const void *cipher) = NULL;
static int (*dyn_EVP_CIPHER_block_size)(const void *cipher) = NULL;

static void InitEVPCipherAccessors(void) {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        dyn_EVP_CIPHER_key_length = dlsym(RTLD_DEFAULT, "EVP_CIPHER_key_length");
        dyn_EVP_CIPHER_iv_length = dlsym(RTLD_DEFAULT, "EVP_CIPHER_iv_length");
        dyn_EVP_CIPHER_block_size = dlsym(RTLD_DEFAULT, "EVP_CIPHER_block_size");
    });
}

static int GetCipherKeyLength(const void *cipher) {
    if (!cipher) return 32;
    InitEVPCipherAccessors();
    if (dyn_EVP_CIPHER_key_length) return dyn_EVP_CIPHER_key_length(cipher);
    return 32;
}

static int GetCipherIVLength(const void *cipher) {
    if (!cipher) return 16;
    InitEVPCipherAccessors();
    if (dyn_EVP_CIPHER_iv_length) return dyn_EVP_CIPHER_iv_length(cipher);
    return 16;
}

static int GetCipherBlockSize(const void *cipher) {
    if (!cipher) return 16;
    InitEVPCipherAccessors();
    if (dyn_EVP_CIPHER_block_size) return dyn_EVP_CIPHER_block_size(cipher);
    return 16;
}

#pragma mark - EVP Context context-based tracking of contextual and

static NSMutableDictionary *EVPCtxMap(void) {
    static NSMutableDictionary *map = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{ map = [NSMutableDictionary dictionary]; });
    return map;
}

static NSString *PtrKey(const void *ptr) {
    return [NSString stringWithFormat:@"%p", ptr];
}

static void UpdateEVPCtx(const void *ctx, const void *cipher, const unsigned char *key, const unsigned char *iv, int enc) {
    if (!ctx) return;

    @synchronized (EVPCtxMap()) {
        NSMutableDictionary *entry = EVPCtxMap()[PtrKey(ctx)];
        if (!entry) {
            entry = [@{
                @"inputAccum": [NSMutableData data],
                @"outputAccum": [NSMutableData data]
            } mutableCopy];
            EVPCtxMap()[PtrKey(ctx)] = entry;
        }
        if (enc >= 0) entry[@"enc"] = @(enc);
        if (cipher) {
            entry[@"keyLen"] = @(GetCipherKeyLength(cipher));
            entry[@"ivLen"] = @(GetCipherIVLength(cipher));
            entry[@"blockSize"] = @(GetCipherBlockSize(cipher));
        }
        if (key && cipher) {
            int keyLen = GetCipherKeyLength(cipher);
            if (keyLen > 0 && keyLen <= 128) {
                NSData *keyData = [NSData dataWithBytes:key length:keyLen];
                entry[@"keyData"] = keyData;
                entry[@"keyHex"] = HexStringFromBytes(key, keyLen);
                entry[@"keyB64"] = Base64StringFromBytes(key, keyLen);
            }
        }
        if (iv && cipher) {
            int ivLen = GetCipherIVLength(cipher);
            if (ivLen > 0 && ivLen <= 64) {
                NSData *ivData = [NSData dataWithBytes:iv length:ivLen];
                entry[@"ivData"] = ivData;
                entry[@"ivHex"] = HexStringFromBytes(iv, ivLen);
                entry[@"ivB64"] = Base64StringFromBytes(iv, ivLen);
            }
        }
    }
}

static NSMutableDictionary *GetEVPCtx(const void *ctx) {
    @synchronized (EVPCtxMap()) {
        return EVPCtxMap()[PtrKey(ctx)];
    }
}

static void AppendEVPIO(const void *ctx, const void *dataIn, size_t inLen, const void *dataOut, size_t outLen) {
    @synchronized (EVPCtxMap()) {
        NSMutableDictionary *entry = EVPCtxMap()[PtrKey(ctx)];
        if (!entry) {
            entry = [@{
                @"inputAccum": [NSMutableData data],
                @"outputAccum": [NSMutableData data]
            } mutableCopy];
            EVPCtxMap()[PtrKey(ctx)] = entry;
        }
        if (dataIn && inLen) [(NSMutableData *)entry[@"inputAccum"] appendBytes:dataIn length:inLen];
        if (dataOut && outLen) [(NSMutableData *)entry[@"outputAccum"] appendBytes:dataOut length:outLen];
    }
}

static void FinalizeEVPCtx(const void *ctx, const void *finalOut, size_t finalLen) {
    NSMutableDictionary *entry = nil;
    @synchronized (EVPCtxMap()) {
        entry = [EVPCtxMap()[PtrKey(ctx)] mutableCopy];
        [EVPCtxMap() removeObjectForKey:PtrKey(ctx)];
    }
    if (!entry) return;

    if (finalOut && finalLen) {
        [(NSMutableData *)entry[@"outputAccum"] appendBytes:finalOut length:finalLen];
    }

    NSData *fullInput = entry[@"inputAccum"];
    NSData *fullOutput = entry[@"outputAccum"];
    int enc = [entry[@"enc"] intValue];
    BOOL isDecrypt = (enc == 0);
    NSString *bundleID = CurrentBundleID();
    DatabaseManager *db = [DatabaseManager sharedManager];

    NSString *keyHex = entry[@"keyHex"] ?: @"(null)";
    NSString *keyB64 = entry[@"keyB64"] ?: @"(null)";
    NSString *ivHex = entry[@"ivHex"] ?: @"(null)";
    NSString *ivB64 = entry[@"ivB64"] ?: @"(null)";

    NSString *info = [NSString stringWithFormat:
                      @"[OpenSSL EVP %@] %@\nKey Hex: %@\nKey Base64: %@\nIV Hex: %@\nIV Base64: %@\nEnter Input Entry entry input Hex: %@\nEnter Input Entry entry input Base64: %@\nEnter Input Entry entry input UTF8: %@\nEnter the length to enter a long: %lu\nOutput output of the outputs Hex: %@\nOutput output of the outputs Base64: %@\nOutput output of the outputs UTF8: %@\nOutput length of output function 's: %lu",
                      isDecrypt ? @"Decrypt" : @"Encrypt",
                      isDecrypt ? @"Dec decc Sc" : @"Encrypt encryption encrypted enc",
                      keyHex, keyB64, ivHex, ivB64,
                      HexStringFromBytes(fullInput.bytes, fullInput.length),
                      Base64StringFromBytes(fullInput.bytes, fullInput.length),
                      ReadableStringFromBytes(fullInput.bytes, fullInput.length),
                      (unsigned long)fullInput.length,
                      HexStringFromBytes(fullOutput.bytes, fullOutput.length),
                      Base64StringFromBytes(fullOutput.bytes, fullOutput.length),
                      ReadableStringFromBytes(fullOutput.bytes, fullOutput.length),
                      (unsigned long)fullOutput.length];
    [db insertDataIntoTable:@"jiamisuanfa" bundleID:bundleID text:info];
    if (isDecrypt || !isDecrypt) {
        [db insertDataIntoTable:@"decrypt_data" bundleID:bundleID text:info];
    }
    LOG(@"%@", info);

    NSData *keyData = entry[@"keyData"];
    NSData *ivData = entry[@"ivData"];
    if (keyData.length) {
        IZXAddDecryptionKeyCandidate(keyData, ivData ?: [NSData data],
                                      [NSString stringWithFormat:@"OpenSSL EVP %@ Key key keyskey-K K", isDecrypt ? @"Decrypt" : @"Encrypt"]);
    }
}

#pragma mark - The original function of the raw functions to provide a

static int (*orig_EVP_CipherInit_ex)(void *ctx, const void *cipher, void *impl, const unsigned char *key, const unsigned char *iv, int enc);
static int (*orig_EVP_EncryptInit_ex)(void *ctx, const void *cipher, void *impl, const unsigned char *key, const unsigned char *iv);
static int (*orig_EVP_DecryptInit_ex)(void *ctx, const void *cipher, void *impl, const unsigned char *key, const unsigned char *iv);

static int (*orig_EVP_CipherUpdate)(void *ctx, unsigned char *out, int *outl, const unsigned char *in, int inl);
static int (*orig_EVP_EncryptUpdate)(void *ctx, unsigned char *out, int *outl, const unsigned char *in, int inl);
static int (*orig_EVP_DecryptUpdate)(void *ctx, unsigned char *out, int *outl, const unsigned char *in, int inl);

static int (*orig_EVP_CipherFinal)(void *ctx, unsigned char *outm, int *outl);
static int (*orig_EVP_EncryptFinal_ex)(void *ctx, unsigned char *outm, int *outl);
static int (*orig_EVP_DecryptFinal_ex)(void *ctx, unsigned char *outm, int *outl);

static void (*orig_AES_cbc_encrypt)(const unsigned char *in, unsigned char *out, size_t length, const void *key, unsigned char *ivec, const int enc);
static void (*orig_AES_encrypt)(const unsigned char *in, unsigned char *out, const void *key);
static void (*orig_AES_decrypt)(const unsigned char *in, unsigned char *out, const void *key);

#pragma mark - Hook Function function of the functions

int my_EVP_CipherInit_ex(void *ctx, const void *cipher, void *impl, const unsigned char *key, const unsigned char *iv, int enc) {
    if (!orig_EVP_CipherInit_ex) return 0;
    UpdateEVPCtx(ctx, cipher, key, iv, enc);
    return orig_EVP_CipherInit_ex(ctx, cipher, impl, key, iv, enc);
}

int my_EVP_EncryptInit_ex(void *ctx, const void *cipher, void *impl, const unsigned char *key, const unsigned char *iv) {
    if (!orig_EVP_EncryptInit_ex) return 0;
    UpdateEVPCtx(ctx, cipher, key, iv, 1);
    return orig_EVP_EncryptInit_ex(ctx, cipher, impl, key, iv);
}

int my_EVP_DecryptInit_ex(void *ctx, const void *cipher, void *impl, const unsigned char *key, const unsigned char *iv) {
    if (!orig_EVP_DecryptInit_ex) return 0;
    UpdateEVPCtx(ctx, cipher, key, iv, 0);
    return orig_EVP_DecryptInit_ex(ctx, cipher, impl, key, iv);
}

int my_EVP_CipherUpdate(void *ctx, unsigned char *out, int *outl, const unsigned char *in, int inl) {
    if (!orig_EVP_CipherUpdate) {
        if (outl) *outl = 0;
        return 0;
    }
    int result = orig_EVP_CipherUpdate(ctx, out, outl, in, inl);
    size_t outLen = (result == 1 && outl) ? *outl : 0;
    AppendEVPIO(ctx, in, inl, out, outLen);
    return result;
}

int my_EVP_EncryptUpdate(void *ctx, unsigned char *out, int *outl, const unsigned char *in, int inl) {
    if (!orig_EVP_EncryptUpdate) {
        if (outl) *outl = 0;
        return 0;
    }
    int result = orig_EVP_EncryptUpdate(ctx, out, outl, in, inl);
    size_t outLen = (result == 1 && outl) ? *outl : 0;
    AppendEVPIO(ctx, in, inl, out, outLen);
    return result;
}

int my_EVP_DecryptUpdate(void *ctx, unsigned char *out, int *outl, const unsigned char *in, int inl) {
    if (!orig_EVP_DecryptUpdate) {
        if (outl) *outl = 0;
        return 0;
    }
    int result = orig_EVP_DecryptUpdate(ctx, out, outl, in, inl);
    size_t outLen = (result == 1 && outl) ? *outl : 0;
    AppendEVPIO(ctx, in, inl, out, outLen);
    return result;
}

int my_EVP_CipherFinal(void *ctx, unsigned char *outm, int *outl) {
    if (!orig_EVP_CipherFinal) {
        if (outl) *outl = 0;
        return 0;
    }
    int result = orig_EVP_CipherFinal(ctx, outm, outl);
    size_t finalLen = (result == 1 && outl) ? *outl : 0;
    FinalizeEVPCtx(ctx, outm, finalLen);
    return result;
}

int my_EVP_EncryptFinal_ex(void *ctx, unsigned char *outm, int *outl) {
    if (!orig_EVP_EncryptFinal_ex) {
        if (outl) *outl = 0;
        return 0;
    }
    int result = orig_EVP_EncryptFinal_ex(ctx, outm, outl);
    size_t finalLen = (result == 1 && outl) ? *outl : 0;
    FinalizeEVPCtx(ctx, outm, finalLen);
    return result;
}

int my_EVP_DecryptFinal_ex(void *ctx, unsigned char *outm, int *outl) {
    if (!orig_EVP_DecryptFinal_ex) {
        if (outl) *outl = 0;
        return 0;
    }
    int result = orig_EVP_DecryptFinal_ex(ctx, outm, outl);
    size_t finalLen = (result == 1 && outl) ? *outl : 0;
    FinalizeEVPCtx(ctx, outm, finalLen);
    return result;
}

void my_AES_cbc_encrypt(const unsigned char *in, unsigned char *out, size_t length, const void *key, unsigned char *ivec, const int enc) {
    if (!orig_AES_cbc_encrypt) return;
    orig_AES_cbc_encrypt(in, out, length, key, ivec, enc);
    if (!in || !out || !key || !ivec) return;
    NSString *bundleID = CurrentBundleID();
    DatabaseManager *db = [DatabaseManager sharedManager];
    BOOL isDecrypt = (enc == 0);

    NSString *info = [NSString stringWithFormat:
                      @"[AES_cbc_encrypt] %@\nIV Hex: %@\nIV Base64: %@\nEnter Input Entry entry input Hex: %@\nEnter Input Entry entry input Base64: %@\nEnter Input Entry entry input UTF8: %@\nEnter the length to enter a long: %lu\nOutput output of the outputs Hex: %@\nOutput output of the outputs Base64: %@\nOutput output of the outputs UTF8: %@\nOutput length of output function 's: %lu\n(Note notes this note: AES_KEY Key key to extend the keys as a, The original key could not directly extract the raw keys from a)",
                      isDecrypt ? @"Decrypt" : @"Encrypt",
                      HexStringFromBytes(ivec, 16), Base64StringFromBytes(ivec, 16),
                      HexStringFromBytes(in, length), Base64StringFromBytes(in, length),
                      ReadableStringFromBytes(in, length), (unsigned long)length,
                      HexStringFromBytes(out, length), Base64StringFromBytes(out, length),
                      ReadableStringFromBytes(out, length), (unsigned long)length];
    [db insertDataIntoTable:@"jiamisuanfa" bundleID:bundleID text:info];
    [db insertDataIntoTable:@"decrypt_data" bundleID:bundleID text:info];
    LOG(@"%@", info);
}

void my_AES_encrypt(const unsigned char *in, unsigned char *out, const void *key) {
    if (!orig_AES_encrypt) return;
    orig_AES_encrypt(in, out, key);
    if (!in || !out || !key) return;
    NSString *bundleID = CurrentBundleID();
    DatabaseManager *db = [DatabaseManager sharedManager];

    NSString *info = [NSString stringWithFormat:
                      @"[AES_encrypt] One-P individual block encryption en an\nEnter Input Entry entry input Hex: %@\nOutput output of the outputs Hex: %@\n(Note notes this note: AES_KEY Key key to extend the keys as a, The original key could not directly extract the raw keys from a)",
                      HexStringFromBytes(in, 16), HexStringFromBytes(out, 16)];
    [db insertDataIntoTable:@"jiamisuanfa" bundleID:bundleID text:info];
    LOG(@"%@", info);
}

void my_AES_decrypt(const unsigned char *in, unsigned char *out, const void *key) {
    if (!orig_AES_decrypt) return;
    orig_AES_decrypt(in, out, key);
    if (!in || !out || !key) return;
    NSString *bundleID = CurrentBundleID();
    DatabaseManager *db = [DatabaseManager sharedManager];

    NSString *info = [NSString stringWithFormat:
                      @"[AES_decrypt] A single block de Dec\nEnter Input Entry entry input Hex: %@\nOutput output of the outputs Hex: %@\nOutput output of the outputs UTF8: %@\n(Note notes this note: AES_KEY Key key to extend the keys as a, The original key could not directly extract the raw keys from a)",
                      HexStringFromBytes(in, 16), HexStringFromBytes(out, 16),
                      ReadableStringFromBytes(out, 16)];
    [db insertDataIntoTable:@"jiamisuanfa" bundleID:bundleID text:info];
    [db insertDataIntoTable:@"decrypt_data" bundleID:bundleID text:info];
    LOG(@"%@", info);
}

#pragma mark - Register of registered registration and Hook

void RegisterOpenSSLHooks(void) {
    struct rebinding rebindings[] = {

        {"EVP_CipherInit_ex",   my_EVP_CipherInit_ex,   (void **)&orig_EVP_CipherInit_ex},
        {"EVP_EncryptInit_ex",  my_EVP_EncryptInit_ex,  (void **)&orig_EVP_EncryptInit_ex},
        {"EVP_DecryptInit_ex",  my_EVP_DecryptInit_ex,  (void **)&orig_EVP_DecryptInit_ex},

        {"EVP_CipherUpdate",   my_EVP_CipherUpdate,   (void **)&orig_EVP_CipherUpdate},
        {"EVP_EncryptUpdate",  my_EVP_EncryptUpdate,  (void **)&orig_EVP_EncryptUpdate},
        {"EVP_DecryptUpdate",  my_EVP_DecryptUpdate,  (void **)&orig_EVP_DecryptUpdate},

        {"EVP_CipherFinal",      my_EVP_CipherFinal,      (void **)&orig_EVP_CipherFinal},
        {"EVP_EncryptFinal_ex",  my_EVP_EncryptFinal_ex,  (void **)&orig_EVP_EncryptFinal_ex},
        {"EVP_DecryptFinal_ex",  my_EVP_DecryptFinal_ex,  (void **)&orig_EVP_DecryptFinal_ex},

        {"AES_cbc_encrypt", my_AES_cbc_encrypt, (void **)&orig_AES_cbc_encrypt},
        {"AES_encrypt",     my_AES_encrypt,     (void **)&orig_AES_encrypt},
        {"AES_decrypt",     my_AES_decrypt,     (void **)&orig_AES_decrypt},
    };

    int result = rebind_symbols(rebindings, sizeof(rebindings) / sizeof(rebindings[0]));
    LOG(@"OpenSSL hooks registered: %d (%zu hooks)", result, sizeof(rebindings) / sizeof(rebindings[0]));
}
