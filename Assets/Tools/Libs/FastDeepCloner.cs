using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Runtime.Serialization;

/// <summary>
/// 深拷贝对象
/// </summary>
public class FastDeepCloner
{

    #region Privat Properties
    private const BindingFlags Binding = BindingFlags.Instance |
    BindingFlags.NonPublic | BindingFlags.Public | BindingFlags.FlattenHierarchy;
    private readonly Type _primaryType;
    private readonly object _desireObjectToBeCloned;
    #endregion

    #region Contructure
    public FastDeepCloner(object desireObjectToBeCloned)
    {
        if (desireObjectToBeCloned == null)
            throw new Exception("The desire object to be cloned cant be NULL");
        _primaryType = desireObjectToBeCloned.GetType();
        _desireObjectToBeCloned = desireObjectToBeCloned;

    }
    #endregion

    #region Privat Method Deep Clone
    // Clone the object Properties and its children recursively
    private object DeepClone()
    {
        if (_desireObjectToBeCloned == null)
            return null;
        if (_primaryType.IsArray)
            return ((Array)_desireObjectToBeCloned).Clone();
        object tObject = _desireObjectToBeCloned as IList;
        if (tObject != null)
        {
            var properties = _primaryType.GetProperties();
            // Get the IList Type of the object
            var customList = typeof(List<>).MakeGenericType
                             ((properties[properties.Length - 1]).PropertyType);
            tObject = (IList)Activator.CreateInstance(customList);
            var list = (IList)tObject;
            // loop throw each object in the list and clone it
            foreach (var item in ((IList)_desireObjectToBeCloned))
            {
                if (item == null)
                    continue;
                var value = new FastDeepCloner(item).DeepClone();
                list?.Add(value);
            }
        }
        else
        {
            // if the item is a string then Clone it and return it directly.
            if (_primaryType == typeof(string))
                return (_desireObjectToBeCloned as string)?.Clone();

            // Create an empty object and ignore its construtore.
            tObject = FormatterServices.GetUninitializedObject(_primaryType);
            var fields = _desireObjectToBeCloned.GetType().GetFields(Binding);
            foreach (var property in fields)
            {
                if (property.IsInitOnly) // Validate if the property is a writable one.
                    continue;
                var value = property.GetValue(_desireObjectToBeCloned);
                if (property.FieldType.IsClass && property.FieldType != typeof(string))
                    tObject.GetType().GetField(property.Name, Binding)?.SetValue
                    (tObject, new FastDeepCloner(value).DeepClone());
                else
                    tObject.GetType().GetField(property.Name, Binding)?.SetValue(tObject, value);
            }
        }

        return tObject;
    }

    #endregion

    #region public Method Clone
    public object Clone()
    {
        return DeepClone();
    }
    public T Clone<T>()
    {
        return (T)DeepClone();
    }
    #endregion
}