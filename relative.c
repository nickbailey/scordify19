static const int adjust8ve [7][7] =  {
       // A0 B1 C2, D3, E4, F5, G6 
        {  0,  0,  1,  1,  0,  0,  0}, // A 0
        {  0,  0,  1,  1,  1,  0,  0}, // B 1
        { -1, -1,  0,  0,  0,  0, -1}, // C 2
        { -1, -1,  0,  0,  0,  0,  0}, // D 3
        {  0, -1,  0,  0,  0,  0,  0}, // E 4
        {  0,  0,  0,  0,  0,  0,  0}, // F 5
        {  0,  0,  0,  0,  0,  0,  0}  // G 6
};

const int relativeAdjustOctave(int last, int current)
{
        // Don't adjust octave if last note is undefined.
        return last < 0 ? 0 : adjust8ve[last][current];
}
