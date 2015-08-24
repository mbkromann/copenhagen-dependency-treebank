## Search Algorithm ##

The search algorithm is given as follows:

  * 0. Take as input a constraint C.
  * 1. Rewrite the constraint C in disjunctive normal form p1 \/ ... \/ pN, where each pI is a conjunction cI1 /\ ... /\ cIM of simple terms or negated simple terms, by applying the following reductions until no further reduction is possible:
    * rewrite ~(~X) as X
    * rewrite ~(X /\ Y) as (~X) \/ (~Y)
    * rewrite ~(X \/ Y) as (~X) /\ (~Y)
    * rewrite X /\ (Y \/ Z) as (X /\ Y) \/ (X /\ Z)
    * rewrite (X \/ Y) /\ Z as (X /\ Z) \/ (Y /\ Z)
  * 2. Solve each subproblem pI in p1,...,pN separately, with pI = c1 /\ ... /\ cM where c1,...,cM are either simple constraints or negated simple constraints, using steps 3-4, and return the union of possible variable instantiations for problems p1,...,pN.
  * 3. Given p = c1 /\ ... /\ cM and prior variable assignments V, pick the constraint cI with the smallest number of minimal solutions (ie, variable assignments to unassigned variables that occur in the constraint); pick a minimal constraint randomly if more than one constraint is minimal.
  * 4. For each vJ in v1,...,vA, let p' be the conjunction of all c1,...,cM except for cI, and let V' be the variable assignment V plus vJ, and solve the modified problem (p',V') recursively, using steps 3-4.

```

function solve(constraint C) {
    # 1. Rewrite the constraint C in disjunctive normal form p1 \/
    # ... \/ pN.
    ($p1,...,$pN) = reduce_dnf(C);

    # 2. Solve each subproblem pI in p1,...,pN separately, with
    # pI = c1 /\ ... /\ cM where c1,...,cM are either simple
    # constraints or negated simple constraints, and return the
    # union of possible variable instantiations for
    # problems p1,...,pN.

    @solutions = ();
    foreach $p (@p) {
        find ($c1,...,$cM) so that $p = $c1 /\ ... /\ $cM
        @s = ($s1,...,$sK) = solve_simple({}, ($c1,...,$cM));
        push @solutions, @s;
    }

    # 3. Return union of all solutions to subproblems p1,...,pN
    return @solutions;
}

function reduce_dnf(constraint C) {
    # Return constraint C in disjunctive normal form p1 \/ ... \/ pN,
    # where each pI is a conjunction cI1 /\ ... /\ cIM of
    # simple terms or negated simple terms, by applying the
    # following reductions until no further reduction is possible:
    #
    #   - rewrite  ~(~X)  as  X
    #   - rewrite  ~(X /\ Y)  as  (~X) \/ (~Y)
    #   - rewrite  ~(X \/ Y)  as  (~X) /\ (~Y)
    #   - rewrite  X /\ (Y \/ Z)  as  (X /\ Y) \/ (X /\ Z)
    #   - rewrite  (X \/ Y) /\ Z  as  (X /\ Z) \/ (Y /\ Z)

    if ($C == ~(~($X))) {
        return reduce_dnf($X);
    } elsif ($C == ~($X /\ $Y)) {
        return reduce_dnf(~$X) \/ reduce_dnf(~$Y);
    } elsif ($C == ~($X \/ $Y)) {
        return reduce_dnf(reduce_dnf(~X) /\ reduce_dnf(~Y));
    } elsif ($C == X /\ (Y \/ Z)) {
        return reduce_dnf(X /\ Y) \/ reduce_dnf(X /\ Z);
    } elsif ($C == (X \/ Y ) /\ Z) {
        return reduce_dnf(X /\ Z) \/ reduce_dnf(Y /\ Z);
    } elsif ($C == (X /\ Y)) {
        return reduce_dnf(reduce_dnf($X) /\ reduce_dnf($Y));
    } elsif ($C == (X \/ Y)) {
        return reduce_dnf($X) \/ reduce_dnf($Y);
    } else {
        return $C;
    }
}

function solve_simple(conjuncts (c1,..., cN), vars V) {
    # Find constraint with smallest number of solutions
    my $best = 0;
    while (! $best) {
        find $i in 1,...,N such that $count[$i] is minimal
        find next solution $sol = $c[i]-&gt;next_solution() for $c[i]
        if (! $sol) {
            $best = $i;
        } else {
            ++$count[$i];
        }
    }

    # Find all possible values for minimal constraint
    @values = $c[$best]-&gt;values();

    # Find solutions for each value setting
    @cnew = splice(@c, $best, 1);
    foreach $v (@values) {
        %Vnew = union(%V, %$v);
        if (! @cnew) {
            push @solutions, $Vnew;
        } else {
            push @solutions, solve_simple(@cnew, %Vnew);
        }
    }

    # Return solutions
    return @solutions;
}

```


#### See also ####

