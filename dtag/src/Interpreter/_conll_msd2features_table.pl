
my $conll_msd2features_table = {
    # adjective
    'A' => [
        # position 3
        [ 'degree',
          { 'A' => 'abs',
            'C' => 'comp',
            'P' => 'pos',
            'S' => 'sup' } ],
        # position 4
        [ 'gender',
          { 'C' => 'common',
            'N' => 'neuter' } ],
        # position 5
        [ 'number',
          { 'S' => 'sing',
            'P' => 'plur' } ],
        # position 6
        [ 'case',
          { 'G' => 'gen',
            'U' => 'unmarked' } ],
        # position 7
        'none',
        # position 8
        [ 'def',
          { 'D' => 'def',
            'I' => 'indef' }],
        # position 9
        [ 'transcat',
          { 'R' => 'adverbial',
            'U' => 'unmarked' } ] ],
    
    # noun
    'N' => [
        # position 3
        [ 'gender',
          { 'C' => 'common',
            'N' => 'neuter' } ],
        # position 4
        [ 'number',
          { 'S' => 'sing',
            'P' => 'plur' } ],
        # position 5
        [ 'case',
          { 'G' => 'gen',
            'U' => 'unmarked' } ],
        # position 6
        'none',
        # position 7
        'none',
        # position 8
        [ 'def',
          { 'D' => 'def',
            'I' => 'indef' } ] ],
    
    # pronoun
    'P' => [
        # position 3
        [ 'person',
          { '1' => '1',
            '2' => '2',
            '3' => '3' } ],
        # position 4
        [ 'gender',
          { 'C' => 'common',
            'N' => 'neuter' } ],
        # position 5
        [ 'number',
          { 'S' => 'sing',
            'P' => 'plur' } ],
        # position 6
        [ 'case',
          { 'N' => 'nom',
            'G' => 'gen',
            'U' => 'unmarked' } ],
        # position 7
        [ 'possessor',
          { 'S' => 'sing',
            'P' => 'plur' } ],
        # position 8
        [ 'reflexive',
          { 'N' => 'no',
            'Y' => 'yes' } ],
        # position 9
        [ 'register',
          { 'U' => 'unmarked',
            'O' => 'obsolete',
            'F' => 'formal',
            'P' => 'polite' } ],
        ],
    
    # adverb
    'RG' => [
        # position 3
        [ 'degree',
          { 'A' => 'abs',
            'C' => 'comp',
            'P' => 'pos',
            'S' => 'sup',
            'U' => 'unmarked' } ] ],
    
    # verb
    'V' => [
        # position 3
        [ 'mood',
          { 'D' => 'indic',
            'M' => 'imper',
            'P' => 'partic',
            'G' => 'gerund',
            'F' => 'infin' } ],
        # position 4
        [ 'tense',
          { 'R' => 'present',
            'A' => 'past' } ],
        # position 5
        [ 'person',
          { '1' => '1',
            '2' => '2',
            '3' => '3' } ],
        # position 6
        [ 'number',
          { 'S' => 'sing',
            'P' => 'plur' } ],
        # position 7
        [ 'gender',
          { 'C' => 'common',
            'N' => 'neuter' } ],
        # position 8
        [ 'definiteness',
          { 'D' => 'def',
            'I' => 'indef' } ],
        # position 9
        [ 'transcat',
          { 'A' => 'adject',
            'R' => 'adverb',
            'U' => 'unmarked' } ],
        # position 10
        [ 'voice',
          { 'A' => 'active',
            'P' => 'passive' } ],
        # position 11
        [ 'case',
          { 'N' => 'nom',
            'G' => 'gen',
            'U' => 'unmarked' } ] ]
    };

