//These mutations change my overall "form" somehow, like size

//Epilepsy gives a very small chance to have a seizure every life tick, knocking you unconscious.
/datum/mutation/human/epilepsy
	name = "Epilepsy"
	desc = ""
	quality = NEGATIVE
	text_gain_indication = span_danger("I get a headache.")
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/human/epilepsy/on_life()
	if(prob(1 * GET_MUTATION_SYNCHRONIZER(src)) && owner.stat == CONSCIOUS)
		owner.visible_message(span_danger("[owner] starts having a seizure!"), span_danger("I have a seizure!"))
		owner.Unconscious(200 * GET_MUTATION_POWER(src))
		owner.Jitter(1000 * GET_MUTATION_POWER(src))
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "epilepsy", /datum/mood_event/epilepsy)
		addtimer(CALLBACK(src, PROC_REF(jitter_less)), 90)

/datum/mutation/human/epilepsy/proc/jitter_less()
	if(owner)
		owner.jitteriness = 10


//Unstable DNA induces random mutations!
/datum/mutation/human/bad_dna
	name = "Unstable DNA"
	desc = ""
	quality = NEGATIVE
	text_gain_indication = span_danger("I feel strange.")
	locked = TRUE

/datum/mutation/human/bad_dna/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	to_chat(owner, text_gain_indication)
	var/mob/new_mob
	if(prob(95))
		if(prob(50))
			new_mob = owner.easy_randmut(NEGATIVE + MINOR_NEGATIVE)
		else
			new_mob = owner.randmuti()
	else
		new_mob = owner.easy_randmut(POSITIVE)
	if(new_mob && ismob(new_mob))
		owner = new_mob
	. = owner
	on_losing(owner)


//Cough gives you a chronic cough that causes you to drop items.
/datum/mutation/human/cough
	name = "Cough"
	desc = ""
	quality = MINOR_NEGATIVE
	text_gain_indication = span_danger("I start coughing.")
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/human/cough/on_life()
	if(prob(5 * GET_MUTATION_SYNCHRONIZER(src)) && owner.stat == CONSCIOUS)
		owner.drop_all_held_items()
		owner.emote("cough")
		if(GET_MUTATION_POWER(src) > 1)
			var/cough_range = GET_MUTATION_POWER(src) * 4
			var/turf/target = get_ranged_target_turf(owner, turn(owner.dir, 180), cough_range)
			owner.throw_at(target, cough_range, GET_MUTATION_POWER(src))

/datum/mutation/human/paranoia
	name = "Paranoia"
	desc = ""
	quality = NEGATIVE
	text_gain_indication = span_danger("I feel screams echo through my mind...")
	text_lose_indication = "<span class'notice'>The screaming in my mind fades.</span>"

/datum/mutation/human/paranoia/on_life()
	if(prob(5) && owner.stat == CONSCIOUS)
		owner.emote("scream")
		if(prob(25))
			owner.hallucination += 20

//Dwarfism shrinks my body and lets you pass tables.
/datum/mutation/human/dwarfism
	name = "Dwarfism"
	desc = ""
	quality = POSITIVE
	difficulty = 16
	instability = 5
	conflicts = list(GIGANTISM)
	locked = TRUE    // Default intert species for now, so locked from regular pool.

/datum/mutation/human/dwarfism/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.transform = owner.transform.Scale(1, 0.8)
	passtable_on(owner, GENETIC_MUTATION)
	owner.visible_message(span_danger("[owner] suddenly shrinks!"), span_notice("Everything around you seems to grow.."))

/datum/mutation/human/dwarfism/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.transform = owner.transform.Scale(1, 1.25)
	passtable_off(owner, GENETIC_MUTATION)
	owner.visible_message(span_danger("[owner] suddenly grows!"), span_notice("Everything around you seems to shrink.."))


//Clumsiness has a very large amount of small drawbacks depending on item.
/datum/mutation/human/clumsy
	name = "Clumsiness"
	desc = ""
	quality = MINOR_NEGATIVE
	text_gain_indication = span_danger("I feel lightheaded.")

/datum/mutation/human/clumsy/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_CLUMSY, GENETIC_MUTATION)

/datum/mutation/human/clumsy/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_CLUMSY, GENETIC_MUTATION)


//Tourettes causes you to randomly stand in place and shout.
/datum/mutation/human/tourettes
	name = "Tourette's Syndrome"
	desc = "" //definitely needs rewriting
	quality = NEGATIVE
	text_gain_indication = span_danger("I twitch.")
	synchronizer_coeff = 1

/datum/mutation/human/tourettes/on_life()
	if(prob(10 * GET_MUTATION_SYNCHRONIZER(src)) && owner.stat == CONSCIOUS && !owner.IsStun())
		owner.Stun(200)
		switch(rand(1, 3))
			if(1)
				owner.emote("twitch")
			if(2 to 3)
				owner.say("[prob(50) ? ";" : ""][pick("SHIT", "PISS", "FUCK", "CUNT", "COCKSUCKER", "MOTHERFUCKER", "TITS")]", forced="tourette's syndrome")
		var/x_offset_old = owner.pixel_x
		var/y_offset_old = owner.pixel_y
		var/x_offset = owner.pixel_x + rand(-2,2)
		var/y_offset = owner.pixel_y + rand(-1,1)
		animate(owner, pixel_x = x_offset, pixel_y = y_offset, time = 1)
		animate(owner, pixel_x = x_offset_old, pixel_y = y_offset_old, time = 1)


//Deafness makes you deaf.
/datum/mutation/human/deaf
	name = "Deafness"
	desc = ""
	quality = NEGATIVE
	text_gain_indication = span_danger("I can't seem to hear anything.")

/datum/mutation/human/deaf/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_DEAF, GENETIC_MUTATION)

/datum/mutation/human/deaf/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_DEAF, GENETIC_MUTATION)


//Monified turns you into a monkey.
/datum/mutation/human/race
	name = "Monkified"
	desc = ""
	quality = NEGATIVE
	time_coeff = 2
	locked = TRUE //Species specific, keep out of actual gene pool

/datum/mutation/human/race/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	. = owner.monkeyize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSTUNS | TR_KEEPREAGENTS | TR_KEEPSE)

/datum/mutation/human/race/on_losing(mob/living/carbon/monkey/owner)
	if(owner && istype(owner) && owner.stat != DEAD && (owner.dna.mutations.Remove(src)))
		. = owner.humanize(TR_KEEPITEMS | TR_KEEPIMPLANTS | TR_KEEPORGANS | TR_KEEPDAMAGE | TR_KEEPVIRUS | TR_KEEPSTUNS | TR_KEEPREAGENTS | TR_KEEPSE)

/datum/mutation/human/strong
	name = "Strength"
	desc = ""
	quality = POSITIVE
	text_gain_indication = span_notice("I feel strong.")
	difficulty = 16

/datum/mutation/human/insulated
	name = "Insulated"
	desc = ""
	quality = POSITIVE
	text_gain_indication = span_notice("My fingertips go numb.")
	text_lose_indication = span_notice("My fingertips regain feeling.")
	difficulty = 16
	instability = 25

/datum/mutation/human/insulated/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_SHOCKIMMUNE, "genetics")

/datum/mutation/human/insulated/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_SHOCKIMMUNE, "genetics")

/datum/mutation/human/fire
	name = "Fiery Sweat"
	desc = ""
	quality = NEGATIVE
	text_gain_indication = span_warning("I feel hot.")
	text_lose_indication = "<span class'notice'>I feel a lot cooler.</span>"
	difficulty = 14
	synchronizer_coeff = 1
	power_coeff = 1

/datum/mutation/human/fire/on_life()
	if(prob((1+(100-dna.stability)/10)) * GET_MUTATION_SYNCHRONIZER(src))
		owner.adjust_fire_stacks(2 * GET_MUTATION_POWER(src))
		owner.IgniteMob()

/datum/mutation/human/fire/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.physiology.burn_mod *= 0.5

/datum/mutation/human/fire/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.physiology.burn_mod *= 2

/datum/mutation/human/badblink
	name = "Spatial Instability"
	desc = ""
	quality = NEGATIVE
	text_gain_indication = span_warning("The space around you twists sickeningly.")
	text_lose_indication = "<span class'notice'>The space around you settles back to normal.</span>"
	difficulty = 18//high so it's hard to unlock and abuse
	instability = 10
	synchronizer_coeff = 1
	energy_coeff = 1
	power_coeff = 1
	var/warpchance = 0

/datum/mutation/human/badblink/on_life()
	if(prob(warpchance))
		var/warpmessage = pick(
		span_warning("With a sickening 720-degree twist of [owner.p_their()] back, [owner] vanishes into thin air."),
		span_warning("[owner] does some sort of strange backflip into another dimension. It looks pretty painful."),
		span_warning("[owner] does a jump to the left, a step to the right, and warps out of reality."),
		span_warning("[owner]'s torso starts folding inside out until it vanishes from reality, taking [owner] with it."),
		span_warning("One moment, you see [owner]. The next, [owner] is gone."))
		owner.visible_message(warpmessage, span_danger("I feel a wave of nausea as you fall through reality!"))
		var/warpdistance = rand(10,15) * GET_MUTATION_POWER(src)
		do_teleport(owner, get_turf(owner), warpdistance, channel = TELEPORT_CHANNEL_FREE)
		owner.adjust_disgust(GET_MUTATION_SYNCHRONIZER(src) * (warpchance * warpdistance))
		warpchance = 0
		owner.visible_message(span_danger("[owner] appears out of nowhere!"))
	else
		warpchance += 0.25 * GET_MUTATION_ENERGY(src)

/datum/mutation/human/acidflesh
	name = "Acidic Flesh"
	desc = ""
	quality = NEGATIVE
	text_gain_indication = span_danger("A horrible burning sensation envelops you as my flesh turns to acid!")
	text_lose_indication = "<span class'notice'>A feeling of relief fills you as my flesh goes back to normal.</span>"
	difficulty = 18//high so it's hard to unlock and use on others
	var/msgcooldown = 0

/datum/mutation/human/acidflesh/on_life()
	if(prob(25))
		if(world.time > msgcooldown)
			to_chat(owner, span_danger("My acid flesh bubbles..."))
			msgcooldown = world.time + 200
		if(prob(15))
			owner.acid_act(rand(30,50), 10)
			owner.visible_message(span_warning("[owner]'s skin bubbles and pops."), span_danger("My bubbling flesh pops! It burns!"))
			playsound(owner,'sound/blank.ogg', 50, TRUE)

/datum/mutation/human/gigantism
	name = "Gigantism"//negative version of dwarfism
	desc = ""
	quality = MINOR_NEGATIVE
	difficulty = 12
	conflicts = list(DWARFISM)

/datum/mutation/human/gigantism/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	owner.resize = 1.25
	owner.update_transform()
	owner.visible_message(span_danger("[owner] suddenly grows!"), span_notice("Everything around you seems to shrink.."))

/datum/mutation/human/gigantism/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	owner.resize = 0.8
	owner.update_transform()
	owner.visible_message(span_danger("[owner] suddenly shrinks!"), span_notice("Everything around you seems to grow.."))

/datum/mutation/human/spastic
	name = "Spastic"
	desc = ""
	quality = NEGATIVE
	text_gain_indication = span_warning("I flinch.")
	text_lose_indication = "<span class'notice'>My flinching subsides.</span>"
	difficulty = 16

/datum/mutation/human/spastic/on_acquiring()
	if(..())
		return
	owner.apply_status_effect(STATUS_EFFECT_SPASMS)

/datum/mutation/human/spastic/on_losing()
	if(..())
		return
	owner.remove_status_effect(STATUS_EFFECT_SPASMS)

/datum/mutation/human/extrastun
	name = "Two Left Feet"
	desc = ""
	quality = NEGATIVE
	text_gain_indication = span_warning("My right foot feels... left.")
	text_lose_indication = "<span class'notice'>My right foot feels alright.</span>"
	difficulty = 16
	var/stun_cooldown = 0

/datum/mutation/human/extrastun/on_life()
	if(world.time > stun_cooldown)
		if(owner.AmountKnockdown() || owner.AmountStun())
			owner.SetKnockdown(owner.AmountKnockdown()*2)
			owner.SetStun(owner.AmountStun()*2)
			owner.visible_message(span_danger("[owner] tries to stand up, but trips!"), span_danger("I trip over my own feet!"))
			stun_cooldown = world.time + 300
