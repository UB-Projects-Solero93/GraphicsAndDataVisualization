#if __VERSION__<130
#define IN attribute
#define OUT varying
#else
#define IN in
#define OUT out
#endif

#define MAXLLUM 1
#define NONE vec4(0.0,0.0,0.0,0.0)

IN vec4 vPosition;
IN vec4 vColor;
IN vec4 vNormal;

OUT vec4 color;

struct MaterialBuffer {
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float shininess;
};

uniform MaterialBuffer bufferMat;

struct LightsBuffer {
    vec4 position;
    vec4 direction;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
    float angle;
};

uniform LightsBuffer bufferLights[MAXLLUM];

vec4 calculateL(int);
vec4 calculateH(vec4);

void main()
{
  gl_Position = vPosition;

  float c[3];
  for (int i=0; i<3; i++){
      c[i] = 0.0;
  }
  vec4 L, H, N=vNormal;
  for (int i=0; i<3; i++){
    for (int j=0; j<MAXLLUM; j++){
        L = normalize(calculateL(j));
        H = normalize(calculateH(L));
        c[i] += bufferMat.diffuse[i] * bufferLights[j].diffuse[i] * max(dot(L,N),0.0) +
                bufferMat.specular[i] * bufferLights[j].specular[i] *
                pow(max(dot(N,H),0.0),bufferMat.shininess) +
                bufferMat.ambient[i] * bufferLights[j].ambient[i];
    }
  }
  color = vec4(c[0],c[1],c[2],1.0);
}

vec4 calculateL(int j){
    if (bufferLights[j].position == NONE){
        return - (vPosition + bufferLights[j].direction);
    } else if (bufferLights[j].angle == 0.0){
        return bufferLights[j].position - vPosition;
    } else {
        vec4 rayDirection = - normalize(vPosition + bufferLights[j].direction);

        vec4 coneDirection = normalize(bufferLights[j].direction);

        float lightToSurfaceAngle = degrees(acos(dot(rayDirection, coneDirection)));
        if(lightToSurfaceAngle > bufferLights[j].angle){
            return vec4(0.0, 0.0, 0.0, 0.0);
        }else{
        return vec4(0.50,0.50,0.50, 0.0); // TODO Fix
    }
}
}
vec4 calculateH(vec4 L){
    vec4 F = vec4(0.0, 0.0, 10.0, 1.0); // Focus de l'observador
    return L + (F - vPosition);
}