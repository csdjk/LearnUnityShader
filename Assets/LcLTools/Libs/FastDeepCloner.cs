using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Runtime.Serialization;

namespace LcLTools
{

    /// <summary>
    /// 深拷贝对象
    /// </summary>
    public class FastDeepCloner
    {
        /// 
        /// Deep Copy using Refelection, Here object does not need to be serialize
        /// https://www.codeproject.com/Tips/1130717/Implementing-Deep-Cloning-using-Reflection
        /// https://code.msdn.microsoft.com/windowsdesktop/CSDeepCloneObject-8a53311e
        public static object Clone(object objectToBeCloned)
        {
            if (objectToBeCloned == null)
                throw new Exception("The desire object to be cloned cant be NULL");

            const BindingFlags _binding = BindingFlags.Instance |
                BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.FlattenHierarchy;

            var _primaryType = objectToBeCloned.GetType();
            var _desireObjectToBeCloned = objectToBeCloned;

            return DeepClone(_desireObjectToBeCloned, _primaryType, _binding);
        }

        private static object DeepClone(object objectToBeCloned, Type primaryType, BindingFlags binding)
        {
            if (objectToBeCloned == null)
                return null;

            if (primaryType.IsPrimitive || primaryType.IsEnum || primaryType == typeof(string))
            {
                // if the item is a string then Clone it and return it directly.
                if (primaryType == typeof(string))
                    return (objectToBeCloned as string)?.Clone();

                return objectToBeCloned;
            }

            if (primaryType.IsArray)
            {
                Type _typeElement = Type.GetType(primaryType.FullName.Replace("[]", string.Empty));
                var _array = objectToBeCloned as Array;
                Array _copiedArray = Array.CreateInstance(_typeElement, _array.Length);
                for (int i = 0; i < _array.Length; i++)
                {
                    // Get the deep clone of the element in the original array and astign the
                    // clone to the new array.
                    var _type = _array.GetValue(i).GetType();
                    _copiedArray.SetValue(DeepClone(_array.GetValue(i), _type, binding), i);
                }

                //return ((Array)objectToBeCloned).Clone();

                return _copiedArray;
            }

            object _tObject = objectToBeCloned as IList;

            if (_tObject != null)
            {
                var properties = primaryType.GetProperties();

                // Get the IList Type of the object
                var customList = typeof(List<>).MakeGenericType
                                 ((properties[properties.Length - 1]).PropertyType);
                _tObject = (IList)Activator.CreateInstance(customList);
                var list = (IList)_tObject;

                // loop throw each object in the list and clone it
                foreach (var item in ((IList)objectToBeCloned))
                {
                    if (item == null)
                        continue;
                    var _type = item.GetType();
                    var value = DeepClone(item, _type, binding);
                    list?.Add(value);
                }
            }
            else
            {
                // Create an empty object and ignore its construtore.
                _tObject = FormatterServices.GetUninitializedObject(primaryType);
                FieldInfo[] fields = objectToBeCloned.GetType().GetFields(binding);
                foreach (var field in fields)
                {
                    if (field.IsInitOnly) // Validate if the property is a writable one.
                        continue;
                    var value = field.GetValue(objectToBeCloned);
                    if (field.FieldType.IsClass && field.FieldType != typeof(string))
                    {
                        //Type _propertyType = property.FieldType;
                        //var shellPropertyType = value.GetType();
                        //var specificShellPropertyType = shellPropertyType.MakeGenericType(_propertyType);

                        //IList LObj = Clone(value);
                        //object obj = LObj.

                        _tObject.GetType().GetField(field.Name, binding)?.SetValue
                        (_tObject, value);
                    }
                    else
                        _tObject.GetType().GetField(field.Name, binding)?.SetValue(_tObject, value);
                }
            }

            return _tObject;
        }
    }
}
