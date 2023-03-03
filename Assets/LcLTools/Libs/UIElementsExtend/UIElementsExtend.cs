using System.CodeDom.Compiler;
using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.UIElements;

namespace LcLTools
{
    public class ToggleMinMaxSlider : MinMaxSlider
    {
        public bool Active
        {
            get
            {
                return activeToggle.value;
            }
            set
            {
                activeToggle.value = value;
            }
        }
        private Toggle activeToggle;
        private FloatField minValueField;
        private FloatField maxValueField;
        private VisualElement sliderElement;

        public ToggleMinMaxSlider(string label, Vector2 defaultValue, Vector2 range, bool active = false) : base(label)
        {
            this.value = defaultValue;
            this.lowLimit = range.x;
            this.highLimit = range.y;
            activeToggle = new Toggle() { value = active };
            minValueField = new FloatField() { value = defaultValue.x };
            minValueField.AddToClassList("min-max-slider-input");
            maxValueField = new FloatField() { value = defaultValue.y };
            maxValueField.AddToClassList("min-max-slider-input");

            this.Insert(1, activeToggle);
            this.Insert(2, minValueField);
            this.Add(maxValueField);
            sliderElement = this.ElementAt(3);
            SetActive(active);

            activeToggle.RegisterCallback<ChangeEvent<bool>>((evt) =>
            {
                SetActive(evt.newValue);
            });
            maxValueField.RegisterCallback<ChangeEvent<float>>((evt) =>
            {
                this.maxValue = evt.newValue;
            });
            minValueField.RegisterCallback<ChangeEvent<float>>((evt) =>
            {
                this.minValue = evt.newValue;
            });
            this.RegisterCallback<ChangeEvent<Vector2>>((evt) =>
            {
                minValueField.value = evt.newValue.x;
                maxValueField.value = evt.newValue.y;
            });
        }

        private void SetActive(bool v)
        {
            minValueField.SetEnabled(v);
            sliderElement.SetEnabled(v);
            maxValueField.SetEnabled(v);
        }
    }

    /// <summary>
    /// 有Value显示的Slider
    /// </summary>
    public class SliderWithValue : Slider
    {

        public new class UxmlFactory : UxmlFactory<SliderWithValue, UxmlTraits> { }

        private readonly FloatField _integerElement;

        public override float value
        {
            set
            {
                base.value = value;

                if (_integerElement != null)
                {
                    _integerElement.SetValueWithoutNotify(base.value);
                }
            }
        }

        // ---------------------------------------------------------
        public SliderWithValue() : this(null, 0, 10)
        {

        }

        // ---------------------------------------------------------
        public SliderWithValue(float start, float end, SliderDirection direction = SliderDirection.Horizontal, float pageSize = 0)
            : this(null, start, end, direction, pageSize)
        {
        }

        // ---------------------------------------------------------
        public SliderWithValue(string label, float start = 0, float end = 10, SliderDirection direction = SliderDirection.Horizontal, float pageSize = 0)
            : base(label, start, end, direction, pageSize)
        {

            _integerElement = new FloatField();
            _integerElement.style.flexGrow = 0f;
            _integerElement.RegisterValueChangedCallback(evt =>
            {
                value = evt.newValue;
            });

            Add(_integerElement);

            _integerElement.SetValueWithoutNotify(value);
        }
    }


    /// <summary>
    /// 有Value显示的IntSlider 
    /// </summary>
    public class SliderIntWithValue : SliderInt
    {
        public new class UxmlFactory : UxmlFactory<SliderIntWithValue, UxmlTraits> { }

        private readonly IntegerField _integerElement;

        public override int value
        {
            set
            {
                base.value = value;

                if (_integerElement != null)
                {
                    _integerElement.SetValueWithoutNotify(base.value);
                }
            }
        }

        // ---------------------------------------------------------
        public SliderIntWithValue() : this(null, 0, 10)
        {

        }

        // ---------------------------------------------------------
        public SliderIntWithValue(int start, int end, SliderDirection direction = SliderDirection.Horizontal, int pageSize = 0)
            : this(null, start, end, direction, pageSize)
        {
        }

        // ---------------------------------------------------------
        public SliderIntWithValue(string label, int start = 0, int end = 10, SliderDirection direction = SliderDirection.Horizontal, float pageSize = 0)
            : base(label, start, end, direction, pageSize)
        {

            _integerElement = new IntegerField();
            _integerElement.style.flexGrow = 0f;
            _integerElement.RegisterValueChangedCallback(evt =>
            {
                value = evt.newValue;
            });

            Add(_integerElement);

            _integerElement.SetValueWithoutNotify(value);
        }
    }

    /// <summary>
    /// RadioButton
    /// </summary>
    public class TableButton : BaseField<int>
    {
        private const string stylesResource = "Assets/Editor/Render/Elements/UIElementsExtend.uss";
        private const string ussFieldInput = "table-container";
        private const string ussUnityButton = "unity-button";
        private const string ussTableButton = "table-button";

        private const string ussTableButtonChild = "table-button-child";

        private int currentIndex = 0;
        // public int defaultIndex = 0;
        private List<RadioButton> list = new List<RadioButton>();

        private int m_DefaultIndex;
        public int defaultIndex
        {
            get { return m_DefaultIndex; }
            set
            {
                m_DefaultIndex = value;
                for (int i = 0; i < list.Count; i++)
                {
                    list[i].SetValueWithoutNotify(i == defaultIndex);
                }
            }
        }

        private Action<int> m_Callback;

        // public TableButton() : this(null, null) { }

        // ---------------------------------------------------------
        public TableButton(string[] labels, int defaultIndex = 0) : base(null, null)
        {
            styleSheets.Add(AssetDatabase.LoadAssetAtPath<StyleSheet>(stylesResource));
            this.AddToClassList(ussFieldInput);
            this.RemoveAt(0);
            this.Init(labels);
            this.defaultIndex = defaultIndex;
        }

        void Init(string[] labels)
        {
            float width = 1.0f / (float)labels.Length;
            for (int i = 0; i < labels.Length; i++)
            {
                var index = i;
                var label = labels[index];
                var radio = new RadioButton() { text = label };
                radio.style.flexGrow = width;
                radio.AddToClassList(ussUnityButton);
                radio.AddToClassList(ussTableButton);
                radio.ElementAt(0).AddToClassList(ussTableButtonChild);
                radio.RegisterValueChangedCallback((ChangeEvent<bool> evt) =>
                {
                    if (evt.newValue)
                    {
                        using (var changeEvent = ChangeEvent<int>.GetPooled(currentIndex, index))
                        {
                            changeEvent.target = this;
                            this.SendEvent(changeEvent);
                        }
                        currentIndex = index;
                        this.SetValueWithoutNotify(currentIndex);
                    }
                });
                this.Add(radio);
                list.Add(radio);
            }
        }
        public override void SetValueWithoutNotify(int index)
        {
            base.SetValueWithoutNotify(index);
        }
    }


}
#endif
