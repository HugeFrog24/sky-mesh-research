#version 460

layout(binding = 2, std140) uniform _96_98
{
    vec4 _m0;
    vec4 _m1;
    vec4 _m2;
    vec4 _m3;
    vec4 _m4;
    vec4 _m5;
    mat4 _m6;
    mat4 _m7;
    mat4 _m8;
    mat4 _m9;
    mat4 _m10;
    mat4 _m11;
    vec4 _m12;
    vec4 _m13;
    vec4 _m14;
    vec4 _m15;
    vec3 _m16;
    float _m17;
    vec3 _m18;
    float _m19;
    float _m20;
    float _m21;
    float _m22;
    float _m23;
    float _m24;
    float _m25;
    float _m26;
    vec3 _m27;
    float _m28;
    vec3 _m29;
    float _m30;
    vec2 _m31;
    vec2 _m32;
    vec3 _m33;
    vec3 _m34;
    vec3 _m35;
    vec4 _m36;
    vec2 _m37;
    vec3 _m38;
    float _m39;
    vec4 _m40;
    vec3 _m41;
    float _m42;
    vec3 _m43;
    float _m44;
    vec3 _m45;
    float _m46;
    vec3 _m47;
    vec3 _m48;
    vec3 _m49;
    vec4 _m50;
    vec4 _m51;
    vec3 _m52;
    vec4 _m53;
    vec4 _m54;
    vec4 _m55;
    vec4 _m56;
    vec3 _m57;
    vec3 _m58;
    vec3 _m59;
    vec3 _m60;
    vec4 _m61;
    vec4 _m62;
    vec4 _m63;
    vec4 _m64;
    vec4 _m65;
    vec4 _m66;
    vec3 _m67;
    vec3 _m68;
    vec4 _m69;
    vec4 _m70;
    vec4 _m71;
    vec4 _m72;
    vec3 _m73;
    float _m74;
    vec3 _m75;
    float _m76;
    vec3 _m77;
    vec3 _m78;
    vec3 _m79;
    vec3 _m80;
    vec3 _m81;
    vec3 _m82;
} _98;

layout(binding = 1, std140) uniform _297_299
{
    vec4 _m0;
} _299;

layout(binding = 0, std140) uniform _611_613
{
    float _m0;
} _613;

layout(binding = 3) uniform sampler2D _322;
layout(binding = 4) uniform sampler2D _364;
layout(binding = 7) uniform sampler2D _550;
layout(binding = 5) uniform sampler2D _587;
layout(binding = 6) uniform sampler2D _597;

layout(location = 0) in vec3 _545;
layout(location = 8) in vec4 _552;
layout(location = 7) in vec3 _589;
layout(location = 3) in vec4 _617;
layout(location = 1) in vec3 _672;
layout(location = 4) in vec4 _684;
layout(location = 5) in vec4 _686;
layout(location = 6) in vec4 _688;
layout(location = 2) in vec4 _723;
layout(location = 0) out vec4 _790;

void main()
{
    vec3 _540 = _98._m16 - _545;
    vec2 _549 = (texture(_550, _552.zw).xy * 2.0) - vec2(1.0);
    vec3 _560 = texture(_550, _552.xy).xyz;
    vec2 _574 = ((_560.xy - vec2(0.5)) * _549) + vec2(0.5);
    _560 = vec3(_574.x, _574.y, _560.z);
    float _577 = _560.z;
    vec2 _580 = (_560.xy * 2.0) - vec2(1.0);
    vec3 _586 = texture(_587, _589.xy * 0.25).xyz;
    vec3 _596 = texture(_597, (_589.xy * vec2(0.5, 0.25)) - (_560.xy * 0.00999999977648258209228515625)).xyz;
    float _610 = _613._m0;
    float _616 = _617.w;
    vec2 _621 = texture(_597, (_589.xy - (_560.xy * 0.125)) + (_596.xy * 0.02999999932944774627685546875)).xy;
    vec2 _637 = (mix(_596.xy, _621, vec2(_577)) * 2.0) - vec2(1.0);
    vec2 _647 = (((_637 * (3.0 - (2.0 * _610))) + ((_580 * _577) * 0.5)) * _577) * ((_586.y * 2.0) + 0.25);
    vec3 _665 = vec3(_647.x, 0.0, _647.y);
    vec3 _671 = _672 + (_665 * 0.5);
    vec3 _677 = _672 + (_665 * 1.25);
    float _1327 = _686.x;
    vec3 _1324 = _684.xyz + (_98._m60 * _684.w);
    vec3 _1333 = _1324;
    float _1336 = _1327;
    vec3 _1346 = _1333;
    float _1349 = _1336;
    float _830 = 0.89999997615814208984375;
    vec3 _1267 = vec3(0.0);
    vec3 _1268 = vec3(0.0);
    float _1270 = 1.0;
    float _835 = 0.0;
    float _836 = _98._m13.w;
    float _837 = 1.0 / _836;
    vec3 _838 = _540 + ((_672 - _677) * 0.20000000298023223876953125);
    ivec2 _839 = ivec2(floor(gl_FragCoord.xy * (vec2(32.0, 16.0) * _299._m0.zw)));
    int _840 = (_839.y * 32) + _839.x;
    ivec4 _841 = ivec4(texelFetch(_322, ivec2(0, _840), 0));
    bool _895 = _841.x == _840;
    bool _903;
    if (_895)
    {
        _903 = _841.y == (512 - _840);
    }
    else
    {
        _903 = _895;
    }
    if (_903)
    {
        int _842 = 1;
        while (_841.z > 0)
        {
            vec4 _844 = texelFetch(_322, ivec2(_842, _840), 0);
            vec3 _983 = ((_98._m11[3].xyz + (_98._m11[0].xyz * _844.x)) + (_98._m11[1].xyz * _844.y)) + (_98._m11[2].xyz * _844.z);
            vec4 _984 = vec4(_983, _844.w);
            vec4 _843 = _984;
            vec4 _845 = texelFetch(_364, ivec2(_842, _840), 0);
            vec4 _846 = _843;
            vec4 _847 = _845;
            vec3 _848 = _540;
            vec3 _849 = _677;
            vec3 _1285 = _1267;
            vec3 _1286 = _1268;
            float _1288 = _1270;
            float _1017 = _847.w;
            float _1018 = _846.w;
            vec3 _1019 = _846.xyz - _848;
            float _1020 = dot(_1019, _1019);
            float _1021 = _1017 * _1020;
            float _1022 = clamp((_1021 - _1018) / (_1021 - _1020), 0.0, 1.0);
            float _1023 = max(dot(_849, _1019) * inversesqrt(_1020), 0.0);
            _1286 += (_847.xyz * _1022);
            _1285 += ((_847.xyz * _1023) * _1022);
            _1267 = _1285;
            _1268 = _1286;
            _1270 = _1288;
            _842++;
            _841.z--;
        }
        while ((_841.w > 0) && (_835 < 1.0))
        {
            vec4 _852 = texelFetch(_322, ivec2(_842, _840), 0);
            vec3 _1072 = ((_98._m11[3].xyz + (_98._m11[0].xyz * _852.x)) + (_98._m11[1].xyz * _852.y)) + (_98._m11[2].xyz * _852.z);
            vec4 _1073 = vec4(_1072, _852.w);
            vec4 _851 = _1073;
            vec4 _853 = _851;
            vec3 _854 = _838;
            float _855 = _836;
            float _856 = _837;
            float _857 = _835;
            vec3 _1106 = _853.xyz - _854;
            vec3 _1107 = _98._m13.xyz * dot(_98._m13.xyz, _1106);
            float _1108 = 1.0 / dot(_1106, _1106);
            float _1109 = dot(_1106 - _1107, _1106 - _1107) * _1108;
            float _1110 = _853.w * _1108;
            float _1111 = clamp(((_1109 - _1110) - _855) / (_1110 * (-2.0)), 0.0, 1.0);
            float _1112 = (_1111 * _1111) * (3.0 - (2.0 * _1111));
            float _1113 = (_1110 * _856) * _1112;
            _857 = max(_857, _1113);
            _835 = _857;
            _842++;
            _841.w--;
        }
        _1267 = mix(_1268, _1267, vec3(_830));
        _1270 = clamp(1.0 + (_835 * _98._m13.y), 0.0, 1.0);
    }
    vec3 _1298 = _1267;
    float _1301 = _1270;
    vec3 _1311 = _1298;
    float _1314 = _1301;
    vec3 _1352 = _1311;
    float _1353 = _1314;
    _1346 += _1352;
    _1349 *= _1353;
    vec3 _708 = -_98._m38;
    vec3 _713 = normalize(_545);
    float _716 = max(0.0, dot(_677, _708));
    vec3 _721 = vec3(0.0);
    vec3 _722 = (_723.xyz * _616) * _716;
    vec3 _731 = _713;
    vec3 _733 = _671;
    vec3 _735 = _708;
    float _737 = _610;
    vec3 _739 = _617.xyz;
    vec3 _1169 = normalize(_731 + _735);
    float _1170 = _737;
    float _1171 = _1170 * _1170;
    float _1172 = max(dot(_733, _731), 0.0);
    float _1173 = max(dot(_733, _735), 0.0);
    float _1174 = max(dot(_733, _1169), 0.0);
    float _1175 = ((_1174 * _1174) * (_1171 - 1.0)) + 1.0;
    float _1176 = _1171 / (_1175 * _1175);
    float _1177 = _1172 + sqrt(((_1172 - (_1172 * _1171)) * _1172) + _1171);
    float _1178 = _1173 + sqrt(((_1173 - (_1173 * _1171)) * _1173) + _1171);
    float _1179 = _1176 / (_1177 * _1178);
    vec3 _1180 = mix(_739, vec3(1.0), vec3(pow(clamp(1.0 - dot(_731, _1169), 0.0, 0.999000012874603271484375), 5.0)));
    vec3 _1181 = _1180 * (_1173 * _1179);
    vec3 _1182 = _1181;
    vec3 _730 = _1182;
    _721 += ((_98._m41 * _1349) * (_722 + _730));
    float _755 = 3.0 * exp2(((4.0 * _610) - 10.0) * max(0.0, dot(_677, _713)));
    vec3 _769 = _723.xyz * (_616 + _755);
    _721 += ((_1346 * _769) * min((_1353 * 0.25) + 0.75, 1.0));
    float _796 = 1.0 / gl_FragCoord.w;
    float _797 = 1000.0;
    float _1260 = max(0.0, _796 * (_797 * 6.6666667407844215631484985351562e-05));
    _790 = vec4(_721, _1260);
}

