// FIXME Notenum 0 is C, up to B=6

static const int adjust8ve [7][7] =  {
       // C0, D1, E2, F3, G4, A5, B6
        {  0,  0,  0,  0, -1, -1, -1}, // C 0
        {  0,  0,  0,  0,  0, -1, -1}, // D 1
        {  0,  0,  0,  0,  0,  0, -1}, // E 2
        {  0,  0,  0,  0,  0,  0,  0}, // F 3
        {  0,  0,  0,  0,  0,  0,  0}, // G 4
        {  1,  1,  0,  0,  0,  0,  0}, // A 5
        {  1,  1,  1,  0,  0,  0,  0} // B 6
};

const int relativeAdjustOctave(const int last, const int current)
{
        // Don't adjust octave if last note is undefined.
        return last < 0 ? 0 : adjust8ve[last][current];
}
