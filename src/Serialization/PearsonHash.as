
namespace Serialization
{
    const uint8[] PearsonHashTable = {198,220,199,236,77,161,247,108,243,229,252,250,126,180,86,146,67,213,15,209,166,130,101,133,211,190,0,98,124,189,121,83,163,105,174,235,148,164,16,56,136,102,240,223,132,4,87,208,10,117,69,64,65,217,253,45,57,210,85,212,13,81,175,233,36,62,154,116,127,170,160,72,203,35,238,194,18,214,110,91,3,197,241,31,43,63,255,107,155,53,206,39,38,112,84,109,179,122,201,70,66,99,73,119,100,123,92,118,29,59,195,51,138,26,147,76,6,219,234,1,142,54,137,182,68,153,104,193,173,222,169,227,215,52,131,183,90,191,141,232,60,225,7,120,24,184,172,96,103,89,205,44,167,32,226,94,88,145,135,156,5,14,41,114,242,2,181,20,23,106,248,143,48,47,254,129,221,249,61,144,140,37,186,157,55,152,78,204,113,30,28,93,50,27,9,168,188,187,19,128,151,159,21,40,12,8,246,34,17,177,22,171,216,202,150,176,231,196,134,251,230,165,244,42,97,95,218,80,239,58,71,115,25,158,11,139,224,192,74,207,228,200,149,185,33,245,125,49,79,178,82,111,162,75,237,46};
    // Pearson Hash
    // Ref: https://en.wikipedia.org/wiki/Pearson_hashing
    uint8 Hash8(const string&in input)
    {
        uint8 hash = input.Length % 256;
        for (int i = 0; i < input.Length; i++)
        {
            hash = PearsonHashTable[hash ^ uint8(input[i])];
        }
        return hash;
    }
    uint8 Hash8(const uint8[]&in input)
    {
        uint8 hash = input.Length % 256;
        for (uint i = 0; i < input.Length; i++)
        {
            hash = PearsonHashTable[hash ^ uint8(input[i])];
        }
        return hash;
    }
    // Pearson Hash
    // Ref: https://en.wikipedia.org/wiki/Pearson_hashing
    uint16 Hash16(const string&in input)
    {
        uint16 hash = 0;
        for (uint j = 0; j < 2; j++)
        {
            uint8 hash_byte = PearsonHashTable[(input[0] + j) % 256];
            for (int i = 0; i < input.Length; i++)
            {
                hash_byte = PearsonHashTable[hash_byte ^ uint8(input[i])];
            }
            hash = ((hash << 8) | hash_byte);
        }
        return hash;
    }
}
