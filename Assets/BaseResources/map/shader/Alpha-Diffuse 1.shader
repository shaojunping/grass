// Unity built-in shader source. Copyright (c) 2016 Unity Technologies. MIT license (see license.txt)

Shader "Shaojunping/Diffuse2222" {
Properties {
	_Color ("Main Color", Color) = (1,1,1,1)
	_MainTex ("Base (RGB) Trans (A)", 2D) = "white" {}
	_ColliderForce ("Collider Force(Control by Script)", float) = 1.0
}

SubShader {
	Tags {"Queue"="Transparent" "IgnoreProjector"="True" "RenderType"="Transparent"}
	LOD 200

CGPROGRAM
#pragma surface surf Lambert alpha:fade

sampler2D _MainTex;
fixed4 _Color;
float _ColliderForce;

struct Input {
	float2 uv_MainTex;
};

void surf (Input IN, inout SurfaceOutput o) {
	fixed4 c = tex2D(_MainTex, IN.uv_MainTex) * _Color;
	o.Albedo = c.rgb;
	o.Alpha = _ColliderForce;
}
ENDCG
}

Fallback "Legacy Shaders/Transparent/VertexLit"
}
