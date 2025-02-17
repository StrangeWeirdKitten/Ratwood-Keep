/datum/mutation/human/olfaction
	name = "Transcendent Olfaction"
	desc = ""
	quality = POSITIVE
	difficulty = 12
	text_gain_indication = span_notice("Smells begin to make more sense...")
	text_lose_indication = span_notice("My sense of smell goes back to normal.")
	power = /obj/effect/proc_holder/spell/targeted/olfaction
	instability = 30
	synchronizer_coeff = 1
	var/reek = 200

/datum/mutation/human/olfaction/modify()
	if(power)
		var/obj/effect/proc_holder/spell/targeted/olfaction/S = power
		S.sensitivity = GET_MUTATION_SYNCHRONIZER(src)

/obj/effect/proc_holder/spell/targeted/olfaction
	name = "Remember the Scent"
	desc = ""
	charge_max = 100
	clothes_req = FALSE
	range = -1
	include_user = TRUE
	action_icon_state = "nose"
	var/mob/living/carbon/tracking_target
	var/list/mob/living/carbon/possible = list()
	var/sensitivity = 1

/obj/effect/proc_holder/spell/targeted/olfaction/cast(list/targets, mob/living/user = usr)
	//can we sniff? is there miasma in the air?
	var/datum/gas_mixture/air = user.loc.return_air()
	var/list/cached_gases = air.gases

	if(cached_gases[/datum/gas/miasma])
		user.adjust_disgust(sensitivity * 45)
		to_chat(user, span_warning("With my overly sensitive nose, you get a whiff of stench and feel sick! Try moving to a cleaner area!"))
		return

	var/atom/sniffed = user.get_active_held_item()
	if(sniffed)
		var/old_target = tracking_target
		possible = list()
		var/list/prints = sniffed.return_fingerprints()
		for(var/mob/living/carbon/C in GLOB.carbon_list)
			if(prints[md5(C.dna.uni_identity)])
				possible |= C
		if(!length(possible))
			to_chat(user,span_warning("Despite my best efforts, there are no scents to be found on [sniffed]..."))
			return
		tracking_target = input(user, "Choose a scent to remember.", "Scent Tracking") as null|anything in sortNames(possible)
		if(!tracking_target)
			if(!old_target)
				to_chat(user,span_warning("I decide against remembering any scents. Instead, you notice my own nose in my peripheral vision. This goes on to remind you of that one time you started breathing manually and couldn't stop. What an awful day that was."))
				return
			tracking_target = old_target
			on_the_trail(user)
			return
		to_chat(user,span_notice("I pick up the scent of [tracking_target]. The hunt begins."))
		on_the_trail(user)
		return

	if(!tracking_target)
		to_chat(user,span_warning("You're not holding anything to smell, and you haven't smelled anything you can track. You smell my skin instead; it's kinda salty."))
		return

	on_the_trail(user)

/obj/effect/proc_holder/spell/targeted/olfaction/proc/on_the_trail(mob/living/user)
	if(!tracking_target)
		to_chat(user,span_warning("You're not tracking a scent, but the game thought you were. Something's gone wrong! Report this as a bug."))
		return
	if(tracking_target == user)
		to_chat(user,span_warning("I smell out the trail to myself. Yep, it's you."))
		return
	if(usr.z < tracking_target.z)
		to_chat(user,span_warning("The trail leads... way up above you? Huh. They must be really, really far away."))
		return
	else if(usr.z > tracking_target.z)
		to_chat(user,span_warning("The trail leads... way down below you? Huh. They must be really, really far away."))
		return
	var/direction_text = "[dir2text(get_dir(usr, tracking_target))]"
	if(direction_text)
		to_chat(user,span_notice("I consider [tracking_target]'s scent. The trail leads <b>[direction_text].</b>"))

/datum/mutation/human/firebreath
	name = "Fire Breath"
	desc = ""
	quality = POSITIVE
	difficulty = 12
	locked = TRUE
	text_gain_indication = span_notice("My throat is burning!")
	text_lose_indication = span_notice("My throat is cooling down.")
	power = /obj/effect/proc_holder/spell/aimed/firebreath
	instability = 30
	energy_coeff = 1
	power_coeff = 1

/datum/mutation/human/firebreath/modify()
	if(power)
		var/obj/effect/proc_holder/spell/aimed/firebreath/S = power
		S.strength = GET_MUTATION_POWER(src)

/obj/effect/proc_holder/spell/aimed/firebreath
	name = "Fire Breath"
	desc = ""
	school = "evocation"
	charge_max = 600
	clothes_req = FALSE
	range = 20
	projectile_type = /obj/projectile/magic/aoe/fireball/firebreath
	base_icon_state = "fireball"
	action_icon_state = "fireball0"
	sound = 'sound/blank.ogg' //horrifying lizard noises
	active_msg = "You built up heat in my mouth."
	deactive_msg = "You swallow the flame."
	var/strength = 1

/obj/effect/proc_holder/spell/aimed/firebreath/before_cast(list/targets)
	. = ..()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(C.is_mouth_covered())
			C.adjust_fire_stacks(2)
			C.IgniteMob()
			to_chat(C,span_warning("Something in front of my mouth caught fire!"))
			return FALSE

/obj/effect/proc_holder/spell/aimed/firebreath/ready_projectile(obj/projectile/P, atom/target, mob/user, iteration)
	if(!istype(P, /obj/projectile/magic/aoe/fireball))
		return
	var/obj/projectile/magic/aoe/fireball/F = P
	switch(strength)
		if(1 to 3)
			F.exp_light = strength-1
		if(4 to INFINITY)
			F.exp_heavy = strength-3
	F.exp_fire += strength

/obj/projectile/magic/aoe/fireball/firebreath
	name = "fire breath"
	exp_heavy = 0
	exp_light = 0
	exp_flash = 0
	exp_fire= 4

/datum/mutation/human/self_amputation
	name = "Autotomy"
	desc = ""
	quality = POSITIVE
	text_gain_indication = span_notice("My joints feel loose.")
	instability = 30
	power = /obj/effect/proc_holder/spell/self/self_amputation

	energy_coeff = 1
	synchronizer_coeff = 1

/obj/effect/proc_holder/spell/self/self_amputation
	name = "Drop a limb"
	desc = ""
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 100
	action_icon_state = "autotomy"

/obj/effect/proc_holder/spell/self/self_amputation/cast(mob/user = usr)
	if(!iscarbon(user))
		return

	var/mob/living/carbon/C = user
	if(HAS_TRAIT(C, TRAIT_NODISMEMBER))
		return

	var/list/parts = list()
	for(var/X in C.bodyparts)
		var/obj/item/bodypart/BP = X
		if(BP.body_part != HEAD && BP.body_part != CHEST)
			if(BP.dismemberable)
				parts += BP
	if(!parts.len)
		to_chat(usr, span_notice("I can't shed any more limbs!"))
		return

	var/obj/item/bodypart/BP = pick(parts)
	BP.dismember()
