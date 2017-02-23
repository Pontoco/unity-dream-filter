using System;
using UnityEngine;

namespace AssemblyCSharpfirstpass
{
    [ExecuteInEditMode]
    public class PostEffect : UnityStandardAssets.ImageEffects.ImageEffectBase
    {
        public Texture2D noiseTexture;

        [Range(0.0f, 1f)]
        public float noiseMean = 0.5f;

        [Range(0f, 0.5f)]
        public float noiseMapScale = 0.05f;

        [Range(0.2f, 10f)]
        public float noiseCoordScale = 1f;

        [Range(0f, 1f)]
        public float quantization = 0.05f;

        [Range(0f, 90f)]
        public float sampleAngleDegrees = 0f;

        // Called by camera to apply image effect
        void OnRenderImage (RenderTexture source, RenderTexture destination) {
            material.SetTexture("_NoiseTex", noiseTexture);
            material.SetFloat("_NoiseMean", noiseMean);
            material.SetFloat("_NoiseMapScale", noiseMapScale);
            material.SetFloat("_NoiseCoordScale", noiseCoordScale);
            material.SetFloat("_Quantization", quantization);
            material.SetFloat("_SampleAngleDegrees", sampleAngleDegrees);
            Graphics.Blit (source, destination, material);
        }
    }
}

