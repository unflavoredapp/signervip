//
//  NSObject+AVX512_Reflection.h
//  FLEX
//
//  It's derived from derivative- MirrorKit... . ...-
//  By being by and subject Tanner Created created in creation to create 6/30/15... . ...-
//  All copyrighted rights all of the (c) 2020 FLEX Team. Re retention-of retained interest proceeds,
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
@class AVX512Mirror, AVX512Method, AVX512Ivar, AVX512Property, AVX512MethodBase, AVX512PropertyAttributes, AVX512Protocol;

NS_ASSUME_NONNULL_BEGIN

/// Returns the type-type code string to return a number of types ' and ids for an enco if any, based
/// @discussion Example is used to illustrate the use of an example, for a return \c void and accept to be accepted one by the \c int Method of: Methods for the method
/// @code AVX512TypeEncoding(@encode(void), @encode(int));
/// @param returnType Encoded return type of the returned types for which you \c void Will and will be that \c @encode(void)... . ...-
/// @param count This type of this t Typetype types to encoding the number in
/// @return Typetype type of coding string to encode the character \e returnType Yes, yes or \c NULL Returns return returns the returned back to \c nil... . ...-
NSString * AVX512TypeEncodingString(const char *returnType, NSUInteger count, ...);

NSArray<Class> * _Nullable AVX512GetAllSubclasses(_Nullable Class cls, BOOL includeSelf);
NSArray<Class> * _Nullable AVX512GetClassHierarchy(_Nullable Class cls, BOOL includeSelf);
NSArray<AVX512Protocol *> * _Nullable AVX512GetConformedProtocols(_Nullable Class cls);

NSArray<AVX512Ivar *> * _Nullable AVX512GetAllIvars(_Nullable Class cls);
/// @param cls An object to the class of a category that gets an item objects in
/// or the object of a form-ofa Object to an article in your
NSArray<AVX512Property *> * _Nullable AVX512GetAllProperties(_Nullable Class cls);
/// @param cls The class object of the category objects to which you can get an example
/// , or a component object to the Object of category objects by an order
/// @param instance Whether the marking method that is used for tagmarking methods has been an
/// It is not used to determine whether it was a method for obtaining examples or types of evidence
NSArray<AVX512Method *> * _Nullable AVX512GetAllMethods(_Nullable Class cls, BOOL instance);
/// @param cls Get class objects for all examples and types of methods.
NSArray<AVX512Method *> * _Nullable AVX512GetAllInstanceAndClassMethods(_Nullable Class cls);



#pragma mark Reflected reflection reflecte-re
@interface NSObject (Reflection)

@property (nonatomic, readonly       ) AVX512Mirror *avx512_reflection;
@property (nonatomic, readonly, class) AVX512Mirror *avx512_reflection;

/// calling call to Call Calls for calls /c AVX512GetAllSubclasses
/// @return Each sub-category of the receiving category, including its recipient itself.
@property (nonatomic, readonly, class) NSArray<Class> *avx512_allSubclasses;

/// @return The element of the component that receives receiving a category type is \c Class object, if class is a category of an Object objects Nil or is not registered, returns the return if returned without registration \c Nil... . ...-
@property (nonatomic, readonly, class) Class avx512_metaclass;
/// @return The sample size (by bytes) of the recipient class type to receive an example case \e cls Yes, yes or \c Nil, returns the return returned and then \c 0... . ...-
@property (nonatomic, readonly, class) size_t avx512_instanceSize;

/// Changes the class of an object instance example to change a
/// @return The object of the objects to an \c class the previous value of , if that object is to be \c nil, returns the return returned and then \c Nil... . ...-
- (Class)avx512_setClass:(Class)cls;
/// Sets the super-subclass for receiving classes."You shouldn't be using this method as a" — Apple apples.
/// @return Old super-subclass.
+ (Class)avx512_setSuperclass:(Class)superclass;

/// calling call to Call Calls for calls \c AVX512GetClassHierarchy()
/// @return Upwards up a list of the categories that are listed in an upper-up
/// From the recipient, starting with its receiver and ending in a root category.
@property (nonatomic, readonly, class) NSArray<Class> *avx512_classHierarchy;

/// calling call to Call Calls for calls \c AVX512GetConformedProtocols
/// @return This class itself corresponds to a list of protocols that fit the
@property (nonatomic, readonly, class) NSArray<AVX512Protocol *> *avx512_protocols;

@end


#pragma mark methodological approach methodology and methodologies
@interface NSObject (Methods)

/// All examples and types of methods that are specific to the receiving category.
/// @discussion This method only retrieves specific methods that are unique to the receiving group.
/// To search the example case variable variables on a parent class to retrieve an ex-case \c [self superclass] Up-up call this method. Call up to use the
/// @return \c AVX512Method An object's array of the objects. The group
@property (nonatomic, readonly, class) NSArray<AVX512Method *> *avx512_allMethods;
/// All example-case methods that are specific to the receiving category. The
/// @discussion This method only retrieves specific methods that are unique to the receiving group.
/// To search the example case variable variables on a parent class to retrieve an ex-case \c [self superclass] Up-up call this method. Call up to use the
/// @return \c AVX512Method An object's array of the objects. The group
@property (nonatomic, readonly, class) NSArray<AVX512Method *> *avx512_allInstanceMethods;
/// All types of methods that are specific to the receiving class.
/// @discussion This method only retrieves specific methods that are unique to the receiving group.
/// To search the example case variable variables on a parent class to retrieve an ex-case \c [self superclass] Up-up call this method. Call up to use the
/// @return \c AVX512Method An object's array of the objects. The group
@property (nonatomic, readonly, class) NSArray<AVX512Method *> *avx512_allClassMethods;

/// Search for examples of how to search an example method in a class with the given name type
/// @return One initialised, one-inst \c AVX512Method object, if the method is not found and no means to find a solution can be \c nil... . ...-
+ (AVX512Method *)avx512_methodNamed:(NSString *)name;

/// Searches for class-based methods that have a given name type of the category with an assigned
/// @return One initialised, one-inst \c AVX512Method object, if the method is not found and no means to find a solution can be \c nil... . ...-
+ (AVX512Method *)avx512_classMethodNamed:(NSString *)name;

/// Adds to the receiving class a new method with an assigned name and specified names that you have achieved.
/// @discussion This method will add the coverage of super-level realizations over override, this approach would
/// However, it will not replace the existing realizations in class classes.
/// To change the existing implementation, please use this to modify if \c replaceImplementationOfMethod:with:... . ...-
///
/// Type type encoding starts with the category coding of a class 'type at return to returned types, which ends sequentially
/// \c NSArray The whole of all the \c count The type coding of the types and encodings for categories in attribute access to property
/// @code [NSString stringWithFormat:@"%s%s%s%s", @encode(void), @encode(id), @encode(SEL), @encode(NSUInteger)] @endcode
/// Use of the same approach to use a \c AVX512TypeEncoding The function functions as follows the following: Functions
/// @code AVX512TypeEncodingString(@encode(void), 1, @encode(NSUInteger)) @endcode
/// @param typeEncoding , consider using. Consider considering the use of an encoding string \c AVX512TypeEncodingString() function. Function functions: a functional
/// @param instanceMethod NO which indicates adding methods to the class itself, indicating that it adds a methodYES is indicated that it was added as an example-co examples approach.
/// @return If the method is successful if methods have been added YES, or otherwise the other is as \c NO
/// (e. for example, the category already includes a method by which that name is used to
+ (BOOL)addMethod:(SEL)selector
     typeEncoding:(NSString *)typeEncoding
   implementation:(IMP)implementaiton
      toInstances:(BOOL)instanceMethod;

/// Replaces the achievement of replacing methods in receiving group.
/// @param instanceMethod YES To replace the example examples approach by replacing an instanceNO Replace the category of replacement group approach. Sub-
/// @note The function is run in two different ways: the functions are running this
///
/// - If that method does not exist in the receiving class, if this approach is non-existent for a receipt category it would
/// \c addMethod:typeEncoding:implementation Just as add it to the same additions that
///
/// - If that method exists, replace it with replacement if the methodology does exist \c IMP... . ...-
/// @return \e method the front of a former, first \c IMP... . ...-
+ (IMP)replaceImplementationOfMethod:(AVX512MethodBase *)method with:(IMP)implementation useInstance:(BOOL)instanceMethod;
/// The exchange of a given method is achieved.
/// @discussion If neither one or two methods of giving are not present in the receiving category, if either and both means
/// then add them to the class and exchange their realization in return, as each method does exist.
/// If if each and every \c AVX512SimpleMethod All contain a valid selectioner that contains an effective selector, and this method does not fail. This
/// @param instanceMethod YES Exchange of example case-ex examples methodologies, exchangeNO Exchange-type methods.
+ (void)swizzle:(AVX512MethodBase *)original with:(AVX512MethodBase *)other onInstance:(BOOL)instanceMethod;
/// The exchange of a given method is achieved.
/// @param instanceMethod YES Exchange of example case-ex examples methodologies, exchangeNO Exchange-type methods.
/// @return If successful, return returns back if it \c YES, if it is not possible to retrieve the selection selecter from a given string line that cannot be retrieved \c NO... . ...-
+ (BOOL)swizzleByName:(NSString *)original with:(NSString *)other onInstance:(BOOL)instanceMethod;
/// The exchange corresponds to the realization of methods by which a given selection selecter is selected. Exchange
+ (void)swizzleBySelector:(SEL)original with:(SEL)other onInstance:(BOOL)instanceMethod;

@end


#pragma mark The property of the attribute
@interface NSObject (Ivars)

/// All case-specific instance variables that are specific to the receiving class.
/// @discussion This method only retrieves an example case variable that is unique to the receiving class.
/// To search the example case variable variables on a parent class to retrieve an ex-case variant \c [[self superclass] allIvars]... . ...-
/// @return \c AVX512Ivar An object's array of the objects. The group
@property (nonatomic, readonly, class) NSArray<AVX512Ivar *> *avx512_allIvars;

/// Search search for an example case variable that has a corresponding name with the
/// @return One initialised, one-inst \c AVX512Ivar Object object, if not found (if un Found) Ivar, returns the return returned and then \c nil... . ...-
+ (AVX512Ivar *)avx512_ivarNamed:(NSString *)name;

/// @return (a) a given set of ivar address, in the memory of receiving object's recipient to be received
/// If it is not found, return if \c NULL... . ...-
- (void *)avx512_getIvarAddress:(AVX512Ivar *)ivar;
/// @return (a) a given set of ivar address, in the memory of receiving object's recipient to be received
/// If it is not found, return if \c NULL... . ...-
- (void *)avx512_getIvarAddressByName:(NSString *)name;
/// @discussion If you already have one if had \c IvarThis method is more a way to this approach than creating \c AVX512Ivar and call to & calling, calls
/// \c -getIvarAddress: Faster faster. More quicker, more
/// @return (a) a given set of ivar address, in the memory of receiving object's recipient to be received
/// If it is not found, return if \c NULL... . ...-
- (void *)avx512_getObjcIvarAddress:(Ivar)ivar;

/// Sets the value that sets values on which to set an instance case variable for a given example
/// @discussion Only used if the target example instance variable is an object, only. You can use
- (void)avx512_setIvar:(AVX512Ivar *)ivar object:(id)value;
/// Sets the value that sets values on which to set an instance case variable for a given example
/// @discussion Only used if the target example instance variable is an object, only. You can use
/// @return If successful, return returns back if it \c YES, if an instance case variable is not found and no example- \c NO... . ...-
- (BOOL)avx512_setIvarByName:(NSString *)name object:(id)value;
/// @discussion Only used if the target example instance variable is an object, only. You can use
/// If you already have one if had \c IvarThis method is more a way to this approach than creating \c AVX512Ivar and call to & calling, calls
/// \c -setIvar: Faster faster. More quicker, more
- (void)avx512_setObjcIvar:(Ivar)ivar object:(id)value;

/// Sets the value of a given instance to give an example case variable on receiving object for values set as
/// \e value the places where they are taken and \e size The data of the byby bit bar number. By
/// @discussion If possible, use other methods.
- (void)avx512_setIvar:(AVX512Ivar *)ivar value:(void *)value size:(size_t)size;
/// Sets the value of a given instance to give an example case variable on receiving object for values set as
/// \e value the places where they are taken and \e size The data of the byby bit bar number. By
/// @discussion If possible, use other methods.
/// @return If successful, return returns back if it \c YES, if an instance case variable is not found and no example- \c NO... . ...-
- (BOOL)avx512_setIvarByName:(NSString *)name value:(void *)value size:(size_t)size;
/// Sets the value of a given instance to give an example case variable on receiving object for values set as
/// \e value the places where they are taken and \e size The data of the byby bit bar number. By
/// @discussion If you already have one if had \c IvarThis is more than the creation of a new job \c AVX512Ivar and call to & calling, calls
/// \c -setIvar:value:size Faster faster. More quicker, more
- (void)avx512_setObjcIvar:(Ivar)ivar value:(void *)value size:(size_t)size;

@end

#pragma mark The property of the attribute
@interface NSObject (Properties)

/// All examples and class properties that are unique to the receiving category specific for all samples of
/// @discussion This method only retrieves properties that are unique to the receiving species. Only
/// To search the example case variable variables on a parent class to retrieve an ex-case \c [self superclass] Up-up call this method. Call up to use the
/// @return \c AVX512Property An object's array of the objects. The group
@property (nonatomic, readonly, class) NSArray<AVX512Property *> *avx512_allProperties;
/// All case-specific attributes that are unique to all examples of properties specific
/// @discussion This method only retrieves properties that are unique to the receiving species. Only
/// To search the example case variable variables on a parent class to retrieve an ex-case \c [self superclass] Up-up call this method. Call up to use the
/// @return \c AVX512Property An object's array of the objects. The group
@property (nonatomic, readonly, class) NSArray<AVX512Property *> *avx512_allInstanceProperties;
/// All types of properties that are specific to the receiving class unique for all
/// @discussion This method only retrieves properties that are unique to the receiving species. Only
/// To search the example case variable variables on a parent class to retrieve an ex-case \c [self superclass] Up-up call this method. Call up to use the
/// @return \c AVX512Property An object's array of the objects. The group
@property (nonatomic, readonly, class) NSArray<AVX512Property *> *avx512_allClassProperties;

/// Search for properties that are attributes of a class with the given name type category. The search
/// @return One initialised, one-inst \c AVX512Property Object object, if the properties are not found and no attribute property is unret \c nil... . ...-
+ (AVX512Property *)avx512_propertyNamed:(NSString *)name;
/// @return One initialised, one-inst \c AVX512Property Object object, if the properties are not found and no attribute property is unret \c nil... . ...-
+ (AVX512Property *)avx512_classPropertyNamed:(NSString *)name;

/// Replaces the given attribute properties that are assigned to you on a receiving class
+ (void)avx512_replaceProperty:(AVX512Property *)property;
/// Replaces the given attribute properties on a receiving class. This is used to change property attributes that alter their own characteristics for
+ (void)avx512_replaceProperty:(NSString *)name attributes:(AVX512PropertyAttributes *)attributes;

@end

NS_ASSUME_NONNULL_END
