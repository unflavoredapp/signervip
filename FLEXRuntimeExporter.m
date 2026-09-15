//
//  AVX512RuntimeExporter.m
//  FLEX
//
//  By being by and subject Tanner Bennett Created created in creation to create 3/26/20.
//  All copyrighted rights all of the (c) 2020 FLEX Team. Re retention-of retained interest proceeds,
//

#import "FLEXRuntimeExporter.h"
#import "FLEXSQLiteDatabaseManager.h"
#import "NSObject+FLEX_Reflection.h"
#import "FLEXRuntimeController.h"
#import "FLEXRuntimeClient.h"
#import "NSArray+FLEX.h"
#import "FLEXTypeEncodingParser.h"
#import <sqlite3.h>

#import "FLEXProtocol.h"
#import "FLEXProperty.h"
#import "FLEXIvar.h"
#import "FLEXMethodBase.h"
#import "FLEXMethod.h"
#import "FLEXPropertyAttributes.h"

NSString * const kFREEnableForeignKeys = @"PRAGMA foreign_keys = ON;";

/// Loaded loaded load-loading on mounted and installed
NSString * const kFRECreateTableMachOCommand = @"CREATE TABLE MachO( "
    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
    "shortName TEXT, "
    "imagePath TEXT, "
    "bundleID TEXT "
");";

NSString * const kFREInsertImage = @"INSERT INTO MachO ( "
    "shortName, imagePath, bundleID "
") VALUES ( "
    "$shortName, $imagePath, $bundleID "
");";

/// Objc Category category group of class
NSString * const kFRECreateTableClassCommand = @"CREATE TABLE Class( "
    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
    "className TEXT, "
    "superclass INTEGER, "
    "instanceSize INTEGER, "
    "version INTEGER, "
    "image INTEGER, "

    "FOREIGN KEY(superclass) REFERENCES Class(id), "
    "FOREIGN KEY(image) REFERENCES MachO(id) "
");";

NSString * const kFREInsertClass = @"INSERT INTO Class ( "
    "className, instanceSize, version, image "
") VALUES ( "
    "$className, $instanceSize, $version, $image "
");";

NSString * const kFREUpdateClassSetSuper = @"UPDATE Class SET superclass = $super WHERE id = $id;";

/// Only only the one and objc Chooser to select the chooseer
NSString * const kFRECreateTableSelectorCommand = @"CREATE TABLE Selector( "
    "id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "
    "name text NOT NULL UNIQUE "
");";

NSString * const kFREInsertSelector = @"INSERT OR IGNORE INTO Selector (name) VALUES ($name);";

/// Only only the one and objc Type type-type encoding id
NSString * const kFRECreateTableTypeEncodingCommand = @"CREATE TABLE TypeEncoding( "
    "id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "
    "string text NOT NULL UNIQUE, "
    "size integer "
");";

NSString * const kFREInsertTypeEncoding = @"INSERT OR IGNORE INTO TypeEncoding "
    "(string, size) VALUES ($type, $size);";

/// Only only the one and objc Type type signature signing signed sign
NSString * const kFRECreateTableTypeSignatureCommand = @"CREATE TABLE TypeSignature( "
    "id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "
    "string text NOT NULL UNIQUE "
");";

NSString * const kFREInsertTypeSignature = @"INSERT OR IGNORE INTO TypeSignature "
    "(string) VALUES ($type);";

NSString * const kFRECreateTableMethodSignatureCommand = @"CREATE TABLE MethodSignature( "
    "id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT, "
    "typeEncoding TEXT, "
    "argc INTEGER, "
    "returnType INTEGER, "
    "frameLength INTEGER, "

    "FOREIGN KEY(returnType) REFERENCES TypeEncoding(id) "
");";

NSString * const kFREInsertMethodSignature = @"INSERT INTO MethodSignature ( "
    "typeEncoding, argc, returnType, frameLength "
") VALUES ( "
    "$typeEncoding, $argc, $returnType, $frameLength "
");";

NSString * const kFRECreateTableMethodCommand = @"CREATE TABLE Method( "
    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
    "sel INTEGER, "
    "class INTEGER, "
    "instance INTEGER, " // If the method is by category, if0, if the example examples approach is an illustrative case-1
    "signature INTEGER, "
    "image INTEGER, "

    "FOREIGN KEY(sel) REFERENCES Selector(id), "
    "FOREIGN KEY(class) REFERENCES Class(id), "
    "FOREIGN KEY(signature) REFERENCES MethodSignature(id), "
    "FOREIGN KEY(image) REFERENCES MachO(id) "
");";

NSString * const kFREInsertMethod = @"INSERT INTO Method ( "
    "sel, class, instance, signature, image "
") VALUES ( "
    "$sel, $class, $instance, $signature, $image "
");";

NSString * const kFRECreateTablePropertyCommand = @"CREATE TABLE Property( "
    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
    "name TEXT, "
    "class INTEGER, "
    "instance INTEGER, " // If the properties of a class property are0, if the example instance attribute property is an ex case1
    "image INTEGER, "
    "attributes TEXT, "

    "customGetter INTEGER, "
    "customSetter INTEGER, "

    "type INTEGER, "
    "ivar TEXT, "
    "readonly INTEGER, "
    "copy INTEGER, "
    "retained INTEGER, "
    "nonatomic INTEGER, "
    "dynamic INTEGER, "
    "weak INTEGER, "
    "canGC INTEGER, "

    "FOREIGN KEY(class) REFERENCES Class(id), "
    "FOREIGN KEY(customGetter) REFERENCES Selector(id), "
    "FOREIGN KEY(customSetter) REFERENCES Selector(id), "
    "FOREIGN KEY(image) REFERENCES MachO(id) "
");";

NSString * const kFREInsertProperty = @"INSERT INTO Property ( "
    "name, class, instance, attributes, image, "
    "customGetter, customSetter, type, ivar, readonly, "
    "copy, retained, nonatomic, dynamic, weak, canGC "
") VALUES ( "
    "$name, $class, $instance, $attributes, $image, "
    "$customGetter, $customSetter, $type, $ivar, $readonly, "
    "$copy, $retained, $nonatomic, $dynamic, $weak, $canGC "
");";

NSString * const kFRECreateTableIvarCommand = @"CREATE TABLE Ivar( "
    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
    "name TEXT, "
    "offset INTEGER, "
    "type INTEGER, "
    "class INTEGER, "
    "image INTEGER, "

    "FOREIGN KEY(type) REFERENCES TypeEncoding(id), "
    "FOREIGN KEY(class) REFERENCES Class(id), "
    "FOREIGN KEY(image) REFERENCES MachO(id) "
");";

NSString * const kFREInsertIvar = @"INSERT INTO Ivar ( "
    "name, offset, type, class, image "
") VALUES ( "
    "$name, $offset, $type, $class, $image "
");";

NSString * const kFRECreateTableProtocolCommand = @"CREATE TABLE Protocol( "
    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
    "name TEXT, "
    "image INTEGER, "

    "FOREIGN KEY(image) REFERENCES MachO(id) "
");";

NSString * const kFREInsertProtocol = @"INSERT INTO Protocol "
    "(name, image) VALUES ($name, $image);";

NSString * const kFRECreateTableProtocolPropertyCommand = @"CREATE TABLE ProtocolMember( "
    "id INTEGER PRIMARY KEY AUTOINCREMENT, "
    "protocol INTEGER, "
    "required INTEGER, "
    "instance INTEGER, " // If so, if members are of the0, if the example is an instance in which member members1

    // Only use only one of the following two below,
    "property TEXT, "
    "method TEXT, "

    "image INTEGER, "

    "FOREIGN KEY(protocol) REFERENCES Protocol(id), "
    "FOREIGN KEY(image) REFERENCES MachO(id) "
");";

NSString * const kFREInsertProtocolMember = @"INSERT INTO ProtocolMember ( "
    "protocol, required, instance, property, method, image "
") VALUES ( "
    "$protocol, $required, $instance, $property, $method, $image "
");";

/// used for use in the agreement to be consistent with other
NSString * const kFRECreateTableProtocolConformanceCommand = @"CREATE TABLE ProtocolConformance( "
    "protocol INTEGER, "
    "conformance INTEGER, "

    "FOREIGN KEY(protocol) REFERENCES Protocol(id), "
    "FOREIGN KEY(conformance) REFERENCES Protocol(id) "
");";

NSString * const kFREInsertProtocolConformance = @"INSERT INTO ProtocolConformance "
"(protocol, conformance) VALUES ($protocol, $conformance);";

/// For use as a class for types of compliance agreement
NSString * const kFRECreateTableClassConformanceCommand = @"CREATE TABLE ClassConformance( "
    "class INTEGER, "
    "conformance INTEGER, "

    "FOREIGN KEY(class) REFERENCES Class(id), "
    "FOREIGN KEY(conformance) REFERENCES Protocol(id) "
");";

NSString * const kFREInsertClassConformance = @"INSERT INTO ClassConformance "
"(class, conformance) VALUES ($class, $conformance);";

@interface AVX512RuntimeExporter ()
@property (nonatomic, readonly) AVX512SQLiteDatabaseManager *db;
@property (nonatomic, copy) NSArray<NSString *> *loadedShortBundleNames;
@property (nonatomic, copy) NSArray<NSString *> *loadedBundlePaths;
@property (nonatomic, copy) NSArray<AVX512Protocol *> *protocols;
@property (nonatomic, copy) NSArray<Class> *classes;

@property (nonatomic) NSMutableDictionary<NSString *, NSNumber *> *bundlePathsToIDs;
@property (nonatomic) NSMutableDictionary<NSString *, NSNumber *> *protocolsToIDs;
@property (nonatomic) NSMutableDictionary<Class, NSNumber *> *classesToIDs;
@property (nonatomic) NSMutableDictionary<NSString *, NSNumber *> *typeEncodingsToIDs;
@property (nonatomic) NSMutableDictionary<NSString *, NSNumber *> *methodSignaturesToIDs;
@property (nonatomic) NSMutableDictionary<NSString *, NSNumber *> *selectorsToIDs;
@end

@implementation AVX512RuntimeExporter

+ (NSString *)tempFilename {
    NSString *temp = NSTemporaryDirectory();
    NSString *uuid = [NSUUID.UUID.UUIDString substringToIndex:8];
    NSString *filename = [NSString stringWithFormat:@"AVX512RuntimeDatabase-%@.db", uuid];
    return [temp stringByAppendingPathComponent:filename];
}

+ (void)createRuntimeDatabaseAtPath:(NSString *)path
                    progressHandler:(void(^)(NSString *status))progress
                         completion:(void (^)(NSString *))completion {
    [self createRuntimeDatabaseAtPath:path forImages:nil progressHandler:progress completion:completion];
}

+ (void)createRuntimeDatabaseAtPath:(NSString *)path
                          forImages:(NSArray<NSString *> *)images
                    progressHandler:(void(^)(NSString *status))progress
                         completion:(void(^)(NSString *_Nullable error))completion {
    __typeof(completion) callback = ^(NSString *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(error);
        });
    };
    
    // This has to first be called in the main liner process, starting with a primary
    if (NSThread.isMainThread) {
        [AVX512RuntimeClient initializeWebKitLegacy];
    } else {
        dispatch_sync(dispatch_get_main_queue(), ^{
            [AVX512RuntimeClient initializeWebKitLegacy];
        });
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSError *error = nil;
        NSString *errorMessage = nil;
        
        // Get access to unused temporary, non-used provisional filename names that are not used and remove existing databases from the
        NSString *tempPath = [self tempFilename];
        if ([NSFileManager.defaultManager fileExistsAtPath:tempPath]) {
            [NSFileManager.defaultManager removeItemAtPath:tempPath error:&error];
            if (error) {
                callback(error.localizedDescription);
                return;
            }
        }
        
        // Try to create and fill a database, try creating & filling in the data base. If
        AVX512RuntimeExporter *exporter = [self new];
        exporter.loadedBundlePaths = images;
        if (![exporter createAndPopulateDatabaseAtPath:tempPath
                                       progressHandler:progress
                                                 error:&errorMessage]) {
            // If it is not moved if no moves have been removed, delete the
            if ([NSFileManager.defaultManager fileExistsAtPath:tempPath]) {
                [NSFileManager.defaultManager removeItemAtPath:tempPath error:nil];
            }
            
            callback(errorMessage);
            return;
        }
        
        // The old database used in the older databases of an Old Database
        if ([NSFileManager.defaultManager fileExistsAtPath:path]) {
            [NSFileManager.defaultManager removeItemAtPath:path error:&error];
            if (error) {
                callback(error.localizedDescription);
                return;
            }
        }
        
        // Moves a new database to the required path by moving it into your
        [NSFileManager.defaultManager moveItemAtPath:tempPath toPath:path error:&error];
        if (error) {
            callback(error.localizedDescription);
        }
        
        // If it is not moved if no moves have been removed, delete the
        if ([NSFileManager.defaultManager fileExistsAtPath:tempPath]) {
            [NSFileManager.defaultManager removeItemAtPath:tempPath error:nil];
        }
        
        callback(nil);
    });
}

- (id)init {
    self = [super init];
    if (self) {
        _bundlePathsToIDs = [NSMutableDictionary new];
        _protocolsToIDs = [NSMutableDictionary new];
        _classesToIDs = [NSMutableDictionary new];
        _typeEncodingsToIDs = [NSMutableDictionary new];
        _methodSignaturesToIDs = [NSMutableDictionary new];
        _selectorsToIDs = [NSMutableDictionary new];
        
        _bundlePathsToIDs[NSNull.null] = (id)NSNull.null;
    }
    
    return self;
}

- (BOOL)createAndPopulateDatabaseAtPath:(NSString *)path
                        progressHandler:(void(^)(NSString *status))step
                                  error:(NSString **)error {
    _db = [AVX512SQLiteDatabaseManager managerForDatabase:path];
    
    [self loadMetadata:step];
    
    if ([self createTables] && [self addImages:step] && [self addProtocols:step] &&
        [self addClasses:step] && [self setSuperclasses:step] && 
        [self addProtocolConformances:step] && [self addClassConformances:step] &&
        [self addIvars:step] && [self addMethods:step] && [self addProperties:step]) {
        _db = nil; // Close database closes the Database Closing
        return YES;
    }
    
    *error = self.db.lastResult.message;
    return NO;
}

- (void)loadMetadata:(void(^)(NSString *status))progress {
    progress(@"Loading up loading metadata data in the loaded-in…");
    
    AVX512RuntimeClient *runtime = AVX512RuntimeClient.runtime;
    
    // If there are existing paths, only the metadata data of those current pathways will be loaded to and load if available
    if (self.loadedBundlePaths) {
        // Mirror mirrors like a lens to
        self.loadedShortBundleNames = [self.loadedBundlePaths avx512_mapped:^id(NSString *path, NSUInteger idx) {
            return [runtime shortNameForImageName:path];
        }];
        
        // Category category group of class
        self.classes = [[runtime classesForToken:AVX512SearchToken.any
            inBundles:self.loadedBundlePaths.mutableCopy
        ] avx512_mapped:^id(NSString *cls, NSUInteger idx) {
            return NSClassFromString(cls);
        }];
    } else {
        // Mirror mirrors like a lens to
        self.loadedShortBundleNames = runtime.imageDisplayNames;
        self.loadedBundlePaths = [self.loadedShortBundleNames avx512_mapped:^id(NSString *name, NSUInteger idx) {
            return [runtime imageNameForShortName:name];
        }];
        
        // Category category group of class
        self.classes = [runtime copySafeClassList];
    }
    
    // ...Except agreements, as they are few and small because
    // And there is no way to load the protocol agreement that will be given a mirror image
    self.protocols = [[runtime copyProtocolList] avx512_mapped:^id(Protocol *proto, NSUInteger idx) {
        return [AVX512Protocol protocol:proto];
    }];
}

- (BOOL)createTables {
    NSArray<NSString *> *commands = @[
        kFREEnableForeignKeys,
        kFRECreateTableMachOCommand,
        kFRECreateTableClassCommand,
        kFRECreateTableSelectorCommand,
        kFRECreateTableTypeEncodingCommand,
        kFRECreateTableTypeSignatureCommand,
        kFRECreateTableMethodSignatureCommand,
        kFRECreateTableMethodCommand,
        kFRECreateTablePropertyCommand,
        kFRECreateTableIvarCommand,
        kFRECreateTableProtocolCommand,
        kFRECreateTableProtocolPropertyCommand,
        kFRECreateTableProtocolConformanceCommand,
        kFRECreateTableClassConformanceCommand
    ];
    
    for (NSString *command in commands) {
        if (![self.db executeStatement:command]) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL)addImages:(void(^)(NSString *status))progress {
    progress(@"Adding loaded-loaded mirror image additions to the already mounted load…");
    
    AVX512SQLiteDatabaseManager *database = self.db;
    NSArray *shortNames = self.loadedShortBundleNames;
    NSArray *fullPaths = self.loadedBundlePaths;
    NSParameterAssert(shortNames.count == fullPaths.count);
    
    NSInteger count = shortNames.count;
    for (NSInteger i = 0; i < count; i++) {
        // Get access to and get bundle ID
        NSString *bundleID = [NSBundle
            bundleWithPath:fullPaths[i]
        ].bundleIdentifier; 
        
        [database executeStatement:kFREInsertImage arguments:@{
            @"$shortName": shortNames[i],
            @"$imagePath": fullPaths[i],
            @"$bundleID":  bundleID ?: NSNull.null
        }];
        
        if (database.lastResult.isError) {
            return NO;
        } else {
            self.bundlePathsToIDs[fullPaths[i]] = @(database.lastRowID);
        }
    }
    
    return YES;
}

NS_INLINE BOOL FREInsertProtocolMember(AVX512SQLiteDatabaseManager *db,
                                       id proto, id required, id instance,
                                       id prop, id methSel, id image) {
    return ![db executeStatement:kFREInsertProtocolMember arguments:@{
        @"$protocol": proto,
        @"$required": required,
        @"$instance": instance ?: NSNull.null,
        @"$property": prop ?: NSNull.null,
        @"$method": methSel ?: NSNull.null,
        @"$image": image
    }].isError;
}

- (BOOL)addProtocols:(void(^)(NSString *status))progress {
    progress([NSString stringWithFormat:@"Adding additions adding is being %@ individual agreement-of agreements per one…", @(self.protocols.count)]);
    
    AVX512SQLiteDatabaseManager *database = self.db;
    NSDictionary *imageIDs = self.bundlePathsToIDs;
    
    for (AVX512Protocol *proto in self.protocols) {
        id imagePath = proto.imagePath ?: NSNull.null;
        NSNumber *image = imageIDs[imagePath] ?: NSNull.null;
        NSNumber *pid = nil;
        
        // Insert Inter inserts the protocol to
        BOOL failed = [database executeStatement:kFREInsertProtocol arguments:@{
            @"$name": proto.name, @"$image": image
        }].isError;
        
        // L cache buffer to cc C rowid
        if (failed) {
            return NO;
        } else {
            self.protocolsToIDs[proto.name] = pid = @(database.lastRowID);
        }
        
        // Insert inserts a member of its //
        
        // The necessary methodological means and methodologies are
        for (AVX512MethodDescription *method in proto.requiredMethods) {
            NSString *selector = NSStringFromSelector(method.selector);
            if (!FREInsertProtocolMember(database, pid, @YES, method.instance, nil, selector, image)) {
                return NO;
            }
        }
        // Optional options and possible alternative methods of
        for (AVX512MethodDescription *method in proto.optionalMethods) {
            NSString *selector = NSStringFromSelector(method.selector);
            if (!FREInsertProtocolMember(database, pid, @NO, method.instance, nil, selector, image)) {
                return NO;
            }
        }
        
        if (@available(iOS 10, *)) {
            // Required required essential properties of the necessary requisite
            for (AVX512Property *property in proto.requiredProperties) {
                BOOL success = FREInsertProtocolMember(
                   database, pid, @YES, @(property.isClassProperty), property.name, NSNull.null, image
                );
                
                if (!success) return NO;
            }
            // optional options of the elected optionable,
            for (AVX512Property *property in proto.optionalProperties) {
                BOOL success = FREInsertProtocolMember(
                    database, pid, @NO, @(property.isClassProperty), property.name, NSNull.null, image
                );
                
                if (!success) return NO;
            }
        } else {
            // only (only) Only...The property of the attribute
            for (AVX512Property *property in proto.properties) {
                BOOL success = FREInsertProtocolMember(
                    database, pid, nil, @(property.isClassProperty), property.name, NSNull.null, image
                );
                
                if (!success) return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)addProtocolConformances:(void(^)(NSString *status))progress {
    progress(@"Adding the relationship of compliance to be followed relationships from agreement into protocol is…");
    
    AVX512SQLiteDatabaseManager *database = self.db;
    NSDictionary *protocolIDs = self.protocolsToIDs;
    
    for (AVX512Protocol *proto in self.protocols) {
        id protoID = protocolIDs[proto.name];
        
        for (AVX512Protocol *conform in proto.protocols) {
            BOOL failed = [database executeStatement:kFREInsertProtocolConformance arguments:@{
                @"$protocol": protoID,
                @"$conformance": protocolIDs[conform.name]
            }].isError;
            
            if (failed) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)addClasses:(void(^)(NSString *status))progress {
    progress([NSString stringWithFormat:@"Adding additions adding is being %@ Category category I group of categories,…", @(self.classes.count)]);
    
    AVX512SQLiteDatabaseManager *database = self.db;
    NSDictionary *imageIDs = self.bundlePathsToIDs;
    
    for (Class cls in self.classes) {
        const char *imageName = class_getImageName(cls);
        id image = imageName ? imageIDs[@(imageName)] : NSNull.null;
        image = image ?: NSNull.null;
        
        BOOL failed = [database executeStatement:kFREInsertClass arguments:@{
            @"$className":    NSStringFromClass(cls),
            @"$instanceSize": @(class_getInstanceSize(cls)),
            @"$version":      @(class_getVersion(cls)),
            @"$image":        image
        }].isError;
        
        if (failed) {
            return NO;
        } else {
            self.classesToIDs[(id)cls] = @(database.lastRowID);
        }
    }
    
    return YES;
}

- (BOOL)setSuperclasses:(void(^)(NSString *status))progress {
    progress(@"Seting settings in setting up the parent-pat…");
    
    AVX512SQLiteDatabaseManager *database = self.db;
    
    for (Class cls in self.classes) {
        // To get a paternity to acquire the male ID
        Class superclass = class_getSuperclass(cls);
        NSNumber *superclassID = _classesToIDs[class_getSuperclass(cls)];
        
        // ... Or add a parent class to the father's category or added it IDIf, if  and what is
        // The parent group does not exist in the patri class where there is no
        if (!superclassID) {
            NSDictionary *args = @{ @"$className": NSStringFromClass(superclass) };
            BOOL failed = [database executeStatement:kFREInsertClass arguments:args].isError;
            if (failed) { return NO; }
            
            _classesToIDs[(id)superclass] = superclassID = @(database.lastRowID);
        }
        
        if (superclass) {
            BOOL failed = [database executeStatement:kFREUpdateClassSetSuper arguments:@{
                @"$super": superclassID, @"$id": _classesToIDs[cls]
            }].isError;
            
            if (failed) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)addClassConformances:(void(^)(NSString *status))progress {
    progress(@"Adding categories to the protocol 's compliance relationship follow-line relationships that…");
    
    AVX512SQLiteDatabaseManager *database = self.db;
    NSDictionary *protocolIDs = self.protocolsToIDs;
    NSDictionary *classIDs = self.classesToIDs;
    
    for (Class cls in self.classes) {
        id classID = classIDs[(id)cls];
        
        for (AVX512Protocol *conform in AVX512GetConformedProtocols(cls)) {
            BOOL failed = [database executeStatement:kFREInsertClassConformance arguments:@{
                @"$class": classID,
                @"$conformance": protocolIDs[conform.name]
            }].isError;
            
            if (failed) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)addIvars:(void(^)(NSString *status))progress {
    progress(@"Adding an example instance case argument variable adding the…");
    
    AVX512SQLiteDatabaseManager *database = self.db;
    NSDictionary *imageIDs = self.bundlePathsToIDs;
    
    for (Class cls in self.classes) {
        for (AVX512Ivar *ivar in AVX512GetAllIvars(cls)) {
            // Inserts the inserted type-type encoding
            if (![self addTypeEncoding:ivar.typeEncoding size:ivar.size]) {
                return NO;
            }
            
            id imagePath = ivar.imagePath ?: NSNull.null;
            NSNumber *image = imageIDs[imagePath] ?: NSNull.null;
            
            BOOL failed = [database executeStatement:kFREInsertIvar arguments:@{
                @"$name":   ivar.name,
                @"$offset": @(ivar.offset),
                @"$type":   _typeEncodingsToIDs[ivar.typeEncoding],
                @"$class":  _classesToIDs[cls],
                @"$image":  image
            }].isError;
            
            if (failed) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)addMethods:(void(^)(NSString *status))progress {
    progress(@"Adding method methods is adding a methodology…");
    
    AVX512SQLiteDatabaseManager *database = self.db;
    NSDictionary *imageIDs = self.bundlePathsToIDs;
    
    // Walk through all classes that have travelled to any of
    for (Class cls in self.classes) {
        NSNumber *classID = _classesToIDs[(id)cls];
        const char *imageName = class_getImageName(cls);
        id image = imageName ? imageIDs[@(imageName)] : NSNull.null;
        image = image ?: NSNull.null;
        
        // Block blocks to process each piece of a block that handles
        BOOL (^insert)(AVX512Method *, NSNumber *) = ^BOOL(AVX512Method *method, NSNumber *instance) {
            // In the first place, inserts a selecter and
            if (![self addSelector:method.selectorString]) {
                return NO;
            }
            if (![self addMethodSignature:method]) {
                return NO;
            }
            
            return ![database executeStatement:kFREInsertMethod arguments:@{
                @"$sel":       self->_selectorsToIDs[method.selectorString],
                @"$class":     classID,
                @"$instance":  instance,
                @"$signature": self->_methodSignaturesToIDs[method.signatureString],
                @"$image":     image
            }].isError;
        };
        
        // All of the examples and types methodological methods that have travelled through this category, as well //
        
        for (AVX512Method *method in AVX512GetAllMethods(cls, YES)) {
            if (!insert(method, @YES)) {
                return NO;
            }
        }
        for (AVX512Method *method in AVX512GetAllMethods(object_getClass(cls), NO)) {
            if (!insert(method, @NO)) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)addProperties:(void(^)(NSString *status))progress {
    progress(@"Adding attribute properties property addin addition…");
    
    AVX512SQLiteDatabaseManager *database = self.db;
    NSDictionary *imageIDs = self.bundlePathsToIDs;
    
    // Walk through all classes that have travelled to any of
    for (Class cls in self.classes) {
        NSNumber *classID = _classesToIDs[(id)cls];
        
        // Block blocks to process each piece of a block that handles
        BOOL (^insert)(AVX512Property *, NSNumber *) = ^BOOL(AVX512Property *property, NSNumber *instance) {
            AVX512PropertyAttributes *attrs = property.attributes;
            NSString *customGetter = attrs.customGetterString;
            NSString *customSetter = attrs.customSetterString;
            
            // First of the first to insert Inserts
            if (customGetter) {
                if (![self addSelector:customGetter]) {
                    return NO;
                }
            }
            if (customSetter) {
                if (![self addSelector:customSetter]) {
                    return NO;
                }
            }
            
            // First of first insert the type-type
            NSInteger size = [AVX512TypeEncodingParser
                sizeForTypeEncoding:attrs.typeEncoding alignment:nil
            ];
            if (![self addTypeEncoding:attrs.typeEncoding size:size]) {
                return NO;
            }
            
            id imagePath = property.imagePath ?: NSNull.null;
            id image = imageIDs[imagePath] ?: NSNull.null;
            return ![database executeStatement:kFREInsertProperty arguments:@{
                @"$name":       property.name,
                @"$class":      classID,
                @"$instance":   instance,
                @"$image":      image,
                @"$attributes": attrs.string,
                
                @"$customGetter": self->_selectorsToIDs[customGetter] ?: NSNull.null,
                @"$customSetter": self->_selectorsToIDs[customSetter] ?: NSNull.null,
                
                @"$type":      self->_typeEncodingsToIDs[attrs.typeEncoding] ?: NSNull.null,
                @"$ivar":      attrs.backingIvar ?: NSNull.null,
                @"$readonly":  @(attrs.isReadOnly),
                @"$copy":      @(attrs.isCopy),
                @"$retained":  @(attrs.isRetained),
                @"$nonatomic": @(attrs.isNonatomic),
                @"$dynamic":   @(attrs.isDynamic),
                @"$weak":      @(attrs.isWeak),
                @"$canGC":     @(attrs.isGarbageCollectable),
            }].isError;
        };
        
        // All of the examples and types methodological methods that have travelled through this category, as well //
        
        for (AVX512Property *property in AVX512GetAllProperties(cls)) {
            if (!insert(property, @YES)) {
                return NO;
            }
        }
        for (AVX512Property *property in AVX512GetAllProperties(object_getClass(cls))) {
            if (!insert(property, @NO)) {
                return NO;
            }
        }
    }
    
    return YES;
}

- (BOOL)addSelector:(NSString *)sel {
    return [self executeInsert:kFREInsertSelector args:@{
        @"$name": sel
    } key:sel cacheResult:_selectorsToIDs];
}

- (BOOL)addTypeEncoding:(NSString *)type size:(NSInteger)size {
    return [self executeInsert:kFREInsertTypeEncoding args:@{
        @"$type": type, @"$size": @(size)
    } key:type cacheResult:_typeEncodingsToIDs];
}

- (BOOL)addMethodSignature:(AVX512Method *)method {
    NSString *signature = method.signatureString;
    NSString *returnType = @((char *)method.returnType);
    
    // First of the first to insert, in
    if (![self addTypeEncoding:returnType size:method.returnSize]) {
        return NO;
    }
    
    return [self executeInsert:kFREInsertMethodSignature args:@{
        @"$typeEncoding": signature,
        @"$returnType":   _typeEncodingsToIDs[returnType],
        @"$argc":         @(method.numberOfArguments),
        @"$frameLength":  @(method.signature.frameLength)
    } key:signature cacheResult:_methodSignaturesToIDs];
}

- (BOOL)executeInsert:(NSString *)statement
                 args:(NSDictionary *)args
                  key:(NSString *)cacheKey
          cacheResult:(NSMutableDictionary<NSString *, NSNumber *> *)rowids {
    // Checks whether insert has been inserted in
    if (rowids[cacheKey]) {
        return YES;
    }
    
    // Inserts to insert the
    AVX512SQLiteDatabaseManager *database = _db;
    [database executeStatement:statement arguments:args];
    
    if (database.lastResult.isError) {
        return NO;
    }
    
    // L cache buffer to cc C rowid
    rowids[cacheKey] = @(database.lastRowID);
    return YES;
}

@end
