using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[RequireComponent(typeof(Camera))]
public class Stamp : MonoBehaviour
{
	public Transform CameraTr;
	private Camera camera;
	private float height;
	public Material stampMat;
	public float Size = 100;

	public Vector3 Center
	{
		get { return transform.position; }
	}

	public RenderTexture GetTex()
	{
		
		return camera!=null?camera.targetTexture:null;
	}
	void Start ()
	{
		camera = GetComponent<Camera>();
		height = camera.farClipPlane * .9f;
		if (CameraTr == null) CameraTr = Camera.main.transform;
	}

	private void LateUpdate()
	{
		transform.position = CameraTr.position+new Vector3(0,500,0);
	}
	
}
