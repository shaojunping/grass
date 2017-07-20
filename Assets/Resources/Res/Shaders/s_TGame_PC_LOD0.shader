// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'


// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
/*
	TGame - PlayerCharacter - Lod0
	玩家角色，服装变色，外轮廓发光
	Unlit / Lambert + Normal + Blinn + MatCap + Rim x2 + MaskColor + OutGlow

	Lod0
	计算自身阴影 
	计算法线
	计算光照
	计算高光

	不计算雾
	Rim x2

	Pass x2，第2个Pass主要做外轮廓发光燃烧效果（FuryMode）



*/
Shader "TGame/CharacterNEW/PC_LOD0" 
{
	Properties 
	{

		//_Color 		("Color", Color) = (1, 1, 1, 1)
		_MainTex 	("Main Tex", 2D) = "grey" {}		
        _DiffuseMultiplier ("Diff-Mulitplier",Range(0,3)) = 1.0

        // Lighting
  	 	[KeywordEnum(Unlit, Lambert )] _LightingModel ("LightModel", Float) = 0
  	 	[Enum(UnityEngine.Rendering.CullMode)] _Cull ("Cull Mode", Float) = 2
  	 	_AmbientImpactFactor ("Ambient Impact Factor",Range(0,0.75)) = 0.5

		[Space(5)]
		[Header(Diffuse Alpha Cutoff)]
		[MaterialToggle(DIFFALPHACUTOUT)] _DiffAlphaCutout("Diff-Alpha CutOut", Float) = 0
		_Cutoff ("Cutoff Factor", Range(0,1)) = 0.5

        // GrayBalance
		[Space(5)]
		[Header(Diffuse GrayBalance Fixing)]
		[MaterialToggle(PREVIEW_GRAYSCALE)] _PreviewGrayScale("Preview GrayScale", Float) = 0
		_GrayBalance ("GrayBalanceFixer, Use R,G,B to fix diffuse gray",Color) = (1,1,1,1)

		// Mask & Color
       	[Space(5)]
		[Header(MaskRGB And Colors)]
		[MaterialToggle(ENABLE_MASKCOLOR)] _EnableMaskColor("Enable Mask Color", Float) = 0
        _Mask	  ("Mask", 2D) = "black" {}  
		_ColorR ("Color-R",Color) =  (1,1,1,1)
		_ColorG ("Color-G",Color) =  (1,1,1,1)
		_ColorB ("Color-B , or MatCap Color",Color) =  (1,1,1,1)

		// Specular 
       	[Space(5)]
		[Header(Specular)]
		[MaterialToggle(LIGHTINGMODEL_BLINN)] _EnableSpecular ("Enable Specular", Float) = 0
		_SpecularColor ("Specular", Color) = (1, 1, 1, 1)
		_Gloss ("Gloss", Range(0.1, 20)) = 2
		_SpecularMultiplier ("Multiplier", Range(0, 10)) = 1
		_SpecularMap 	("Specular(RGB-Color,A-Gloss)", 2D)	= "white" {}

		// MatCap
		[Space(5)]
		[Header(MatCap)]
		[MaterialToggle(USE_MATCAP)] _UseMatCap("MaskB-MatCap (Will Override Mask-B-Color)", Float) = 0
		_MatCap 	("MatCap (RGB)", 2D)	= "white" {}	
		 _MatCapMulti 	("MatCap-Multiplier",Range(0,5)) = 1

		// Normal
		_BumpMap ("Normal Map", 2D) = "bump" {}

		// Extrusion
		[Space(5)]
    	[Header(FuryMode)]
    	[MaterialToggle(ENABLE_FURYMODE)] _EnableFuryMode("Enable FuryMode", Float) = 0

		_FlowMap 	("FlowMap", 2D) = "white" {}
		_FlowSpeed  ("FlowSpeed", Range(0, 50)) = 10
		_Tiling ("Texture Scale",float) = 1
		_Extrusion ("Extrusion", Range(0, 3)) = 1

		_RimColor 		("RimColor", Color) = (1, 1, 1, 1)
		_RimPower		("RimPower", Range(0, 12.5)) = 10
		_RimMulitpiler  ("RimMultipiler", Range(0, 30)) = 10


    	[Space(5)]
    	[Header(Rim1)]
		 // Rim
        _RimColor1   ("Rim1 Color", Color) = (1, 1, 1, 1)
        _RimPower1   ("Rim1 Power", Range(0.1, 6)) = 6 
        _RimMultiplier1 ("Rim1 Multi", Range(0, 10)) = 1
        _RimDir1		("Rim1 Direction ( W>0 DirRim,Or FullRim )", Vector ) = (1,0,0,1)

    	[Space(5)]
    	[Header(Rim1)]
        _RimColor2   ("Rim2 Color", Color) = (1, 1, 1, 1)
        _RimPower2   ("Rim2 Power", Range(0.1, 6)) = 6 
        _RimMultiplier2   ("Rim2 Multi", Range(0, 10)) = 1
        _RimDir2	 ("Rim2 Direction2 ( W>0 DirRim,Or FullRim )", Vector ) = (-1,0,0,1)


	}

	SubShader 
	{
		Pass 
		{
			LOD 400
	   		Cull [_Cull]

			//Tags { "LightMode"="ForwardBase" "RenderType"="Opaque" }
			Tags {"LightMode"="ForwardBase" "Queue"="AlphaTest" "IgnoreProjector" = "True" "RenderType"="TransparentCutout" }

			CGPROGRAM
			#pragma multi_compile_fwdbase	
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "AutoLight.cginc"

			// Fog
			#pragma multi_compile_fog
			#pragma multi_compile _LIGHTINGMODEL_UNLIT _LIGHTINGMODEL_LAMBERT
			#pragma multi_compile __ LIGHTINGMODEL_BLINN

			#pragma multi_compile __ PREVIEW_GRAYSCALE
			#pragma multi_compile __ USE_MATCAP
			#pragma multi_compile __ ENABLE_MASKCOLOR
			#pragma multi_compile __ ENABLE_FURYMODE
			#pragma multi_compile __ DIFFALPHACUTOUT 

			//fixed4 _Color;
			sampler2D	_MainTex;
			float4		_MainTex_ST;
			fixed _DiffuseMultiplier;
			fixed _AmbientImpactFactor;

			fixed _Cutoff;
			
			// Mask And Colors
	        sampler2D _Mask;
	       	half4 _GrayBalance;
			fixed4 _ColorR;
			fixed4 _ColorG;
			fixed4 _ColorB;

			// Specular
			fixed4 _SpecularColor;
			fixed _Gloss;
			sampler2D _SpecularMap;
			fixed _SpecularMultiplier;

			// Normal
			sampler2D 	_BumpMap;

			// Rim
			fixed4 _RimColor;
			fixed _RimPower;
			fixed _RimMulitpiler;

			// Extrusion
			half _Extrusion;

			// MatCap
			sampler2D _MatCap;
			fixed _MatCapMulti;

			// Flow
			sampler2D _FlowMap;
			float4 _FlowMap_ST;
			fixed _FlowSpeed;
			fixed _Tiling;

			// Rim
            fixed4 	_RimColor1;
            fixed  	_RimPower1;
            fixed 	_RimMultiplier1;
			fixed4  _RimDir1;

          	fixed4 	_RimColor2;
          	fixed 	_RimPower2;
            fixed  	_RimMultiplier2;
			fixed4  _RimDir2;
	
			struct appdata 
			{
				float4 vertex 	: POSITION;
				float3 normal 	: NORMAL;
				float4 tangent 	: TANGENT;
				float4 texcoord : TEXCOORD0;
				
			};
			
			struct v2f 
			{
				float4 pos 	: SV_POSITION;
				float2 uv	: TEXCOORD0;

				float3 worldNormal 	: TEXCOORD1;
				float3 worldPos 	: TEXCOORD2;

				// Normal
				float3 lightDir: TEXCOORD3;
				float3 viewDir : TEXCOORD4;
				
				// FogCoord
				//UNITY_FOG_COORDS(5)

				// Shadow
				SHADOW_COORDS(5)

				// MatCap
				fixed3 c0 : TEXCOORD6;
				fixed3 c1 : TEXCOORD7;

			};
			

			v2f vert(appdata v) 
			{
			 	v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);
			 	// 投射空间的顶点位置
			 	o.pos 			= mul(UNITY_MATRIX_MVP, v.vertex); 
			 	o.uv.xy 		= v.texcoord.xy * _MainTex_ST.xy + _MainTex_ST.zw;
				o.worldPos		= mul (unity_ObjectToWorld, v.vertex).xyz;
                o.worldNormal 	= unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z;

				// Fog
				//UNITY_TRANSFER_FOG(o,o.pos);

				// Shadow
				TRANSFER_SHADOW(o);	

				// Normal And MatCap
				TANGENT_SPACE_ROTATION;
				
				// 视图向量与灯光向量转到 切线空间
				o.lightDir	= mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;
				o.viewDir	= mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;

				// MatCap
				v.normal 	= normalize(v.normal);
				v.tangent 	= normalize(v.tangent);
				o.c0 = mul(rotation, normalize(UNITY_MATRIX_IT_MV[0].xyz));
				o.c1 = mul(rotation, normalize(UNITY_MATRIX_IT_MV[1].xyz));

			 	return o;
			}
			
			fixed4 frag(v2f i) : SV_Target 
			{

				// 在切线空间计算法线
				fixed3 tangentLightDir 	= normalize(i.lightDir);
				fixed3 tangentViewDir 	= normalize(i.viewDir);
				fixed4 packedNormal 	= tex2D(_BumpMap, i.uv);
				fixed3 tangentNormal;
				tangentNormal		= UnpackNormal(packedNormal);
				tangentNormal.z 	= sqrt(1.0 - saturate(dot(tangentNormal.xy, tangentNormal.xy)));

				// MatCap
				#ifdef USE_MATCAP
		
					half2 matCapUV = half2(dot(i.c0, tangentNormal), dot(i.c1, tangentNormal));
               		fixed4 mc = tex2D(_MatCap, matCapUV*0.5+0.5);

				#endif

				// Diffuse贴图采样
				fixed4 diff = tex2D(_MainTex, i.uv);
				fixed3 mask = tex2D(_Mask,i.uv).rgb;
	

				// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
				// 光照计算		

				// Shadow
				UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos);	
				fixed attenMask = saturate(pow(atten,10.0)); // 做一个阴影区域遮罩

				// Lambert
				#ifdef _LIGHTINGMODEL_LAMBERT

					fixed3 ambient	= lerp(fixed3(1,1,1),UNITY_LIGHTMODEL_AMBIENT.xyz,_AmbientImpactFactor);
					fixed lambert =  saturate(dot(tangentNormal, tangentLightDir)) * 0.7 + 0.3;		
					fixed3 final = (_LightColor0.rgb * diff.rgb * lambert * 0.75) + (diff.rgb * ambient);

				// Unit
				#else

					fixed3 ambient	= lerp(fixed3(1,1,1),UNITY_LIGHTMODEL_AMBIENT.xyz,_AmbientImpactFactor * 0.5);
					fixed3 final = diff.rgb * 1.2 * ambient;
				#endif

				// 颜色倍乘
				final *= _DiffuseMultiplier * saturate(pow(atten,1));

				// Specular
				#ifdef LIGHTINGMODEL_BLINN

               	 	fixed3 halfDir 	= normalize(tangentLightDir + tangentViewDir);
					fixed3 specular = _LightColor0.rgb * _SpecularColor.rgb * pow(saturate(dot(tangentNormal, halfDir)), _Gloss);
					fixed3 specularMapping = tex2D(_SpecularMap, i.uv).rgb;
	
					final += specular * specularMapping * _SpecularMultiplier;// * atten;
				#endif

			// Diffuse灰度明度校正
			fixed grayBalance = _GrayBalance.r * final.r + _GrayBalance.g * final.g + _GrayBalance.b * final.b;
			grayBalance /= 2;

			// 预览灰度校正
			#ifdef PREVIEW_GRAYSCALE
				final = fixed3(grayBalance,grayBalance,grayBalance);

			#else

				// MaskColorArea
				half3 areaR = grayBalance * _ColorR.rgb * mask.r ;
				half3 areaG = grayBalance * _ColorG.rgb * mask.g ;

				#ifdef ENABLE_MASKCOLOR

					// 如果使用MatCap，盖掉B通道颜色 
					#ifdef USE_MATCAP
						half3 areaB = mc.rgb * mask.b * final * _ColorB.rgb * _MatCapMulti; 
					#else
						half3 areaB = grayBalance * _ColorB.rgb * mask.b;
					#endif
				
					half unmask = saturate(1- (mask.r + mask.g + mask.b));
					half3 area = areaR + areaG + areaB;
					final = lerp(area,final,unmask);

				#else 
					
					// MatCap
					#ifdef USE_MATCAP
               			final =  (final * mc.rgb * mask.b * _MatCapMulti) + ((1-mask.b) * final); 
					#endif

				#endif
			#endif	
				

			// 添加边缘光
			#ifdef ENABLE_FURYMODE

				// FlowMap 				
				// 做世界空间的 至下而上的 流动贴图
				fixed2 xUV = i.worldPos.zy / _Tiling;
				fixed2 zUV = i.worldPos.xy / _Tiling;
			
                xUV.x += _SinTime.r * _FlowSpeed;
                zUV.x += _SinTime.r * _FlowSpeed;
                xUV.y +=  _Time * -_FlowSpeed;
                zUV.y +=  _Time * -_FlowSpeed;
  
				// 采样贴图
				half3 xDiff = tex2D (_FlowMap, xUV);
				half3 zDiff = tex2D (_FlowMap, zUV);
  
  				// 通过模型的世界法线信息来计算3个投射面之间的混合权重
				half3 blendWeights = pow (abs(i.worldNormal), 2);
				
				// 混合权重
				blendWeights = blendWeights / (blendWeights.x + blendWeights.y + blendWeights.z);
				
				// 混合3个面的颜色 // 目前只用 x/z 两个面
				fixed3 flow = xDiff * blendWeights.x + zDiff * blendWeights.z;

				// Rim 
				fixed rimGlow	= saturate(dot(tangentNormal, tangentViewDir));
				fixed rimPow	= (12.5 - _RimPower);		// 取了RimPower最大值反向，
				fixed rimMulti	= _RimMulitpiler * 0.35;	// 
				fixed3 rimColor = pow((1- rimGlow),rimPow) * _RimColor * rimMulti * flow;

				final += rimColor;

			#endif


				// Rim x2
				fixed3 	rim1 		= pow((1- saturate(dot(tangentNormal, tangentViewDir))),_RimPower1);
				fixed 	rimMask1 	= _RimDir1.w>0 	? saturate(dot(i.worldNormal, _RimDir1.xyz)) 	: 1;    
				fixed3 	rimColor1  	= lerp(fixed3(0,0,0),rim1 * _RimColor1 * rimMask1 * _RimMultiplier1,attenMask);

				fixed3 	rim2 		= pow((1- saturate(dot(tangentNormal, tangentViewDir))),_RimPower2);
				fixed 	rimMask2 	= _RimDir2.w>0 	? saturate(dot(i.worldNormal, _RimDir2.xyz)) 	: 1;  
				fixed3 	rimColor2  	= lerp(fixed3(0,0,0),rim2 * _RimColor2 * rimMask2 * _RimMultiplier2,attenMask);

				// 最终
				final += rimColor1 + rimColor2;

				// 剔除	
				#ifdef DIFFALPHACUTOUT

					fixed4 finalColor = fixed4(final,diff.a);
					if(finalColor.a <= _Cutoff) 
		            {
		                discard;
		            }
	            #else

	            	fixed4 finalColor = fixed4(final,1.0);
	            #endif

	            // Fog
				//UNITY_APPLY_FOG(i.fogCoord, finalColor);
	            return finalColor;

			}			
			ENDCG
		}
		

		// -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
		// 第2个Pass，用作外轮廓发光 
		// 如何关闭pass?，否则在未开启状态ENABLE_FURYMODE状态下是否浪费一个DP??
		pass
		{
		    Tags { "LightMode" = "Always" "Queue"="Transparent+100" "IgnoreProjector"="True"}
		    ZWrite Off
		    Lighting Off
		  	Cull Front
		  	Blend OneMinusDstColor One //Soft Additive

			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag		
			#include "UnityCG.cginc"

			#pragma multi_compile __ ENABLE_FURYMODE

			fixed4 	_RimColor;
			fixed 	_RimPower;
			fixed 	_RimMulitpiler;
			fixed 	_Extrusion;

			// Flow
			sampler2D 	_FlowMap;
			float4 		_FlowMap_ST;
			fixed 		_FlowSpeed;
			fixed 		_Tiling;

				
			struct appdata
			{
				float4 vertex   : POSITION;  
				float3 normal   : NORMAL;    
				float4 texcoord : TEXCOORD0; 

			};

			struct v2f
			{
                float4 pos			: SV_POSITION;
                #ifdef ENABLE_FURYMODE
                    //float4 pos			: SV_POSITION;
					float3 worldNormal 	: TEXCOORD1;
					float3 worldPos 	: TEXCOORD2;

                #endif
			};
					
			v2f vert (appdata v)
			{
                v2f o;
                UNITY_INITIALIZE_OUTPUT(v2f,o);
				// 将顶点沿着法线方向向外推
				v.vertex.xyz += v.normal * (_RimPower * 0.01) * _Extrusion;


				#ifdef ENABLE_FURYMODE
					o.pos = mul (UNITY_MATRIX_MVP, v.vertex);	
					o.worldPos		= mul (unity_ObjectToWorld, v.vertex).xyz;
	                o.worldNormal = unity_WorldToObject[0].xyz * v.normal.x + unity_WorldToObject[1].xyz * v.normal.y + unity_WorldToObject[2].xyz * v.normal.z;
	 
                #endif

				return o;
			}
			
			float4 frag (v2f i) : COLOR
			{

				#ifdef ENABLE_FURYMODE

					// 世界空间三面投射
					fixed2 xUV = i.worldPos.zy / _Tiling;
					fixed2 zUV = i.worldPos.xy / _Tiling;
					xUV.x += _SinTime.r * _FlowSpeed;
	                zUV.x += _SinTime.r * _FlowSpeed;
	                xUV.y +=  _Time * -_FlowSpeed;
	                zUV.y +=  _Time * -_FlowSpeed;
					half3 xDiff = tex2D (_FlowMap, xUV);
					half3 zDiff = tex2D (_FlowMap, zUV);
	  
	  				// 计算混合权重
					half3 blendWeights = pow (abs(i.worldNormal), 2);
					blendWeights = blendWeights / (blendWeights.x + blendWeights.y + blendWeights.z);
					
					// 混合3个面的颜色 // 目前只用 x/z 两个面
					fixed3 flow = xDiff * blendWeights.x + zDiff * blendWeights.z;

					// 计算Rim
					fixed3 	worldNormal = normalize(i.worldNormal);
					fixed3 	viewDir 	= normalize(_WorldSpaceCameraPos.xyz - i.worldPos.xyz);

					// 这里对Rim倍乘做了调整，否则Rim会显得非常亮
					fixed 	rimMulti 	= _RimMulitpiler * 0.001f;		

					fixed 	fresnel 	= 1 - dot(worldNormal, viewDir);
					fixed3 	fresnelColor = pow(fresnel,_RimPower) * _RimColor.rgb * rimMulti;

					// Final
					fixed3 final = fresnelColor * flow.r;	

				#else

					fixed3 final = fixed3(0,0,0);
				#endif

				return fixed4(final,1.0);
			}
			ENDCG
		}	
	}

	
	CustomEditor "TGamePCShaderEditor"
	FallBack "Specular"
}


