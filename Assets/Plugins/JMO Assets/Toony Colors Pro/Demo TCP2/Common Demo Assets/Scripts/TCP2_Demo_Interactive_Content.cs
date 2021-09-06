using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

namespace ToonyColorsPro
{
	public class TCP2_Demo_Interactive_Content : MonoBehaviour
	{
		public Transform pivot;
		public Transform textBox;
		[Space]
		[TextArea] public string Text = "This is the text inside the text box.";
	}
}