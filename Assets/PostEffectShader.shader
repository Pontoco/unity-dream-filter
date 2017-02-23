Shader "Hidden/PostEffectShader"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
	}

    CGINCLUDE
    
    #include "UnityCG.cginc"

    sampler2D _MainTex;

    uniform float4 _MainTex_TexelSize;

    sampler2D _NoiseTex;

    uniform float4 _NoiseTex_TexelSize;

    uniform float _NoiseMean;

    uniform float _NoiseMapScale;

    uniform float _NoiseCoordScale;

    uniform float _Quantization;

    uniform float _SampleAngleDegrees;

    ENDCG

	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = mul(UNITY_MATRIX_MVP, v.vertex);
				o.uv = v.uv;
				return o;
			}         

			fixed4 frag (v2f i) : SV_Target
			{  
                // Get two offset noise samples.
                float2 noiseOffset = float2(_Time.x * 3, 0);
                float2 noiseUV_a = i.uv * _NoiseCoordScale + noiseOffset.xy;
                float2 noiseUV_b = i.uv * _NoiseCoordScale - noiseOffset.yx;
                float2 noiseSample = (tex2D(_NoiseTex, noiseUV_a) + tex2D(_NoiseTex, noiseUV_b)) * .5;

                // Use scaled noise samples to perturb the original UV.
                float2 imageUV = i.uv + ((noiseSample - _NoiseMean) * _NoiseMapScale);

                // Scale coordinates to image pixels so we can work with equal axes.
                float2 imagePixels = imageUV * _MainTex_TexelSize.zw;

                // Generate rotation matrices for sampling in a rotated grid.
                const float radT = radians(_SampleAngleDegrees);
                const float cosT = cos(radT);
                const float sinT = sin(radT);
                const float2x2 rotateCCW = { cosT, -sinT, sinT, cosT };
                const float2x2 rotateCW = { cosT, sinT, -sinT, cosT };

                // Rotate, quantize, then un-rotate.
                imagePixels = mul(rotateCCW, imagePixels);
                imagePixels = round(imagePixels * _Quantization) / _Quantization;
                imagePixels = mul(rotateCW, imagePixels);

                // Sample imput image at modified UV.
                imageUV = imagePixels * _MainTex_TexelSize.xy;
                return tex2D(_MainTex, imageUV);
			}
			ENDCG
		}
	}
}
