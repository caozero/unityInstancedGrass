using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class cyclone : MonoBehaviour {

	// Use this for initialization
	private float scale = 0.01f;
	public float maxScale = 10;
	public float scaleSpeed = 10;
	private Material mat;
	void Start ()
	{
		mat = transform.Find("cyclone").gameObject.GetComponent<MeshRenderer>().material;
	}
	
	// Update is called once per frame
	void Update ()
	{
		scale += Time.deltaTime * scaleSpeed;
		scale = scale >= maxScale ? 0.01f : scale;
		transform.localScale=new Vector3(scale,scale,scale);
		mat.SetFloat("_Alpha",1-scale/maxScale);
	}
}
