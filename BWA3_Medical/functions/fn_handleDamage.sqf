/*
By: KoffeinFlummi

Called when some dude gets shot. Or stabbed. Or blown up. Or pushed off a cliff. Or hit by a car. Or burnt. Or poisoned. Or gassed. Or cut. You get the idea.

Arguments:
0: Unit that got hit (Object)
1: Name of the selection that was hit (String); "" for structural damage
2: Amount of damage inflicted (Number)
3: Shooter (Object); Null for explosion damage, falling, fire etc.
4: Projectile (Object)

Return value:
Damage value to be inflicted (optional)
*/

_unit = _this select 0;
_selectionName = _this select 1;
_damage = _this select 2;
_source = _this select 3;
_projectile = _this select 4;

// Code to be executed AFTER damage was dealt
_unit spawn {
  sleep 0.001;

  // Reset "unused" hitpoints.
  _this setHitPointDamage ["HitLegs", 0];
  _this setHitPointDamage ["HitHands", 0];

  // Check if unit is already dead
  if (damage _unit == 1) then {
    // Determine if unit is revivable.
    if (_unit getHitPointDamage "HitHead" < 0.5 or _unit getHitPointDamage "HitBody" < 1 and _unit getVariable "BWA3_Blood" > 0.2) then {
      _unit setVariable ["BWA3_CPR", 1];
    } else {
      _unit setVariable ["BWA3_CPR", 0];
    };
  };

  // Handle leg damage symptoms
  #define LEGDAMAGETRESHOLD 0.6;
  if (_this getHitPointDamage "HitLeftUpLeg" > LEGDAMAGETRESHOLD or
      _this getHitPointDamage "HitLeftLeg" > LEGDAMAGETRESHOLD or
      _this getHitPointDamage "HitLeftFoot" > LEGDAMAGETRESHOLD or
      _this getHitPointDamage "HitRightUpLeg" > LEGDAMAGETRESHOLD or
      _this getHitPointDamage "HitRightLeg" > LEGDAMAGETRESHOLD or
      _this getHitPointDamage "HitRightFoot" > LEGDAMAGETRESHOLD) then {

    // Render unit unable to walk.
    _this setHitPointDamage ["HitLegs", 1];
  };

  // Handle arm damage symptoms
  #define ARMDAMAGETRESHOLD 0.7;
  if (_this getHitPointDamage "HitLeftShoulder" > ARMDAMAGETRESHOLD or
      _this getHitPointDamage "HitLeftArm" > ARMDAMAGETRESHOLD or
      _this getHitPointDamage "HitLeftForeArm" > ARMDAMAGETRESHOLD or
      _this getHitPointDamage "HitRightShoulder" > ARMDAMAGETRESHOLD or
      _this getHitPointDamage "HitRightArm" > ARMDAMAGETRESHOLD or
      _this getHitPointDamage "HitRightForeArm" > ARMDAMAGETRESHOLD) then {

    // Drop weapon (later)
    _this setHitPointDamage ["HitHands", 1];
  }

  // Pain
  #define PAINKILLERTRESHOLD 0.1;
  #define PAINTRESHOLD 0;
  _this spawn {
    while {_this getVariable "BWA3_Pain" > PAINTRESHOLD and _this getVariable "BWA3_Painkiller" > PAINKILLERTRESHOLD} do {
      //Pain effect (later)
      hintSilent format ["Pain: %1 \n Painkillers: %2", _this getVariable "BWA3_Pain", _this getVariable "BWA3_Painkiller"];
      sleep 5;
    };
  };

  // Bleeding
  #define BLOODTRESHOLD1 0.4; // Treshold for unconsciousness
  #define BLOODTRESHOLD2 0.2; // Treshold for death
  #define BLOODLOSSRATE 0.02;
  _this spawn {
    while {_this getVariable "BWA3_Blood" > 0} do {
      _blood = _this getVariable "BWA3_Blood";
      _blood = _blood - BLOODLOSSRATE * damage _this;
      _this setVariable ["BWA3_Blood", _blood];
      if (_blood < BLOODTRESHOLD1) then {
        [_this] call BWA3_Medical_fnc_knockOut;
      };
      if (_blood < BLOODTRESHOLD2) then {
        _this setDamage 1;
      };
      sleep 10;
    };
  };

};