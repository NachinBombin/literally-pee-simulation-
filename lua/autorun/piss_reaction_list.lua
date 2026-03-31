-- PUT THIS FILE IN "addons/postal2pissmod/lua/autorun"
-- I'll make a better system for this someday. Maybe. We'll see.



NPC_PISS_REACTIONS = {} -- empty NPC tables will force a redirect, or fail silently if it happens again
    NPC_PISS_REACTIONS["npc_barney"] = {
            "vo/npc/barney/ba_no01.wav",
            "vo/npc/barney/ba_no02.wav",
            "vo/npc/barney/ba_pain03.wav",
            "vo/npc/barney/ba_pain04.wav",
            "vo/npc/barney/ba_pain06.wav",
            "vo/npc/barney/ba_pain07.wav",
            "vo/npc/barney/ba_pain08.wav",
            "vo/npc/barney/ba_pain09.wav",
            "vo/k_lab/ba_guh.wav",
            "vo/k_lab/ba_getitoff01.wav",
            "vo/k_lab/ba_thingaway02.wav",
            "vo/npc/barney/ba_ohshit03.wav",
            "vo/npc/barney/ba_lookout.wav",
            "vo/npc/barney/ba_damnit.wav",
            "vo/npc/barney/ba_covermegord.wav", -- lol
            "vo/npc/barney/ba_openfiregord.wav", -- also lol
            "vo/npc/barney/ba_getaway.wav",
            "vo/k_lab/ba_notime.wav",
            "vo/k_lab/ba_pissinmeoff.wav",
            "vo/k_lab/ba_thingaway03.wav",
            "vo/k_lab2/ba_incoming.wav",
            "vo/streetwar/rubble/ba_damnitall.wav",
            "hl2_clips/ba_awman.wav",
            "hl2_clips/ba_fuckyou.wav",
    }

    NPC_PISS_REACTIONS["npc_alyx"] = {
        "vo/npc/alyx/gasp02.wav",
        "vo/npc/alyx/gasp03.wav",
        "vo/npc/alyx/coverme03.wav",
        "vo/npc/alyx/lookout01.wav",
        "vo/npc/alyx/lookout03.wav",
        "vo/npc/alyx/gordon_dist01.wav",
        "vo/npc/alyx/no01.wav",
        "vo/npc/alyx/no02.wav",
        "vo/npc/alyx/no03.wav",
        "vo/npc/alyx/ohgod01.wav",
        "vo/npc/alyx/ohno_startle01.wav",
        "vo/npc/alyx/ohno_startle03.wav",
        "vo/npc/alyx/uggh01.wav",
        "vo/npc/alyx/uggh02.wav",
        "vo/npc/alyx/watchout02.wav",
        "vo/eli_lab/al_dogairlock01.wav",
        "vo/eli_lab/al_soquickly01.wav",
        "vo/eli_lab/al_standbackdog.wav",
        "vo/citadel/al_notagain02.wav",
        "vo/citadel/al_struggle08.wav",
        "vo/k_lab2/al_notime.wav",
        "vo/novaprospekt/al_horrible01.wav",
        "vo/novaprospekt/al_nostop.wav",
        "vo/streetwar/alyx_gate/al_ahno.wav",
        "vo/streetwar/alyx_gate/al_no.wav",
    }

    NPC_PISS_REACTIONS["npc_breen"] = {
            "vo/citadel/br_failing11.wav",
            "vo/citadel/br_goback.wav",
            "vo/citadel/br_guards.wav",
            "vo/citadel/br_ohshit.wav",
            "vo/citadel/br_youfool.wav",
            "vo/citadel/br_mock05.wav",
            "vo/k_lab/br_tele_02.wav",
    }

    NPC_PISS_REACTIONS["npc_kleiner"] = {
            "vo/k_lab/kl_dearme.wav",
            "vo/k_lab/kl_hedyno03.wav",
            "vo/k_lab/kl_heremypet02.wav",
            "vo/k_lab/kl_interference.wav",
            "vo/k_lab2/kl_greatscott.wav",
            "vo/k_lab/kl_ahhhh.wav",
            "vo/k_lab/kl_fiddlesticks.wav",
            "vo/k_lab/kl_mygoodness01.wav",
            "vo/k_lab/kl_ohdear.wav",
            "vo/trainyard/kl_morewarn01.wav",
            "hl2_clips/kl_nono.wav",
    }

    NPC_PISS_REACTIONS["npc_eli"] = {
        "vo/eli_lab/eli_handle_b.wav",
        "vo/k_lab/eli_shutdown.wav",
        "vo/citadel/eli_goodgod.wav",
        "vo/citadel/eli_notobreen.wav",
        "hl2_clips/eli_cough.wav",
        "hl2_clips/eli_nonono.wav",
        "hl2_clips/eli_whatgoingon.wav",
    }

    NPC_PISS_REACTIONS["npc_gman"] = { -- gman really doesn't have a lot for me to work with
        "hl2_clips/gman_clearthroat.wav",
        "hl2_clips/gman_ew.wav",
        "m"
    }

    NPC_PISS_REACTIONS["npc_magnusson"] = {
        "m", -- when "m" or "f" is selected, the script will instead pull from the generic male/female lists at the bottom. this is good for characters that dont have a lot of good lines to pull from like magnusson or gman
    }
    
    NPC_PISS_REACTIONS["npc_mossman"] = {
        "f"
    }

    NPC_PISS_REACTIONS["npc_odessa"] = {
        "m"
    }
    NPC_PISS_REACTIONS["npc_monk"] = {
        "m"
    }

    NPC_PISS_REACTIONS["npc_vortigaunt"] = {
        "m" -- just use the default male list for now
    }
    NPC_PISS_REACTIONS["VortigauntSlave"] = NPC_PISS_REACTIONS["npc_vortigaunt"] -- refer to generic vortigaunt list
    NPC_PISS_REACTIONS["VortigauntUriah"] = NPC_PISS_REACTIONS["npc_vortigaunt"] -- ditto

    NPC_PISS_REACTIONS["m"] = {
        "vo/npc/male01/answer02.wav",
        "vo/npc/male01/answer03.wav",
        "vo/npc/male01/answer19.wav",
        "vo/npc/male01/answer20.wav",
        "vo/npc/male01/answer36.wav",
        "vo/npc/male01/answer39.wav",
        "vo/npc/male01/gethellout.wav",
        "vo/npc/male01/goodgod.wav",
        "vo/npc/male01/gordead_ans04.wav",
        "vo/npc/male01/gordead_ans05.wav",
        "vo/npc/male01/gordead_ans06.wav",
        "vo/npc/male01/gordead_ans19.wav",
        "vo/npc/male01/help01.wav",
        "vo/npc/male01/moan01.wav",
        "vo/npc/male01/moan02.wav",
        "vo/npc/male01/moan03.wav",
        "vo/npc/male01/moan04.wav",
        "vo/npc/male01/moan05.wav",
        "vo/npc/male01/no01.wav",
        "vo/npc/male01/no02.wav",
        "vo/npc/male01/notthemanithought01.wav",
        "vo/npc/male01/ohno.wav",
        "vo/npc/male01/pain01.wav",
        "vo/npc/male01/pain02.wav",
        "vo/npc/male01/pain03.wav",
        "vo/npc/male01/pain07.wav",
        "vo/npc/male01/pain08.wav",
        "vo/npc/male01/pain09.wav",
        "vo/npc/male01/runforyourlife01.wav",
        "vo/npc/male01/stopitfm.wav",
        "vo/npc/male01/takecover02.wav",
        "vo/npc/male01/uhoh.wav",
        "vo/npc/male01/vanswer01.wav",
        "vo/npc/male01/vanswer03.wav",
        "vo/npc/male01/vanswer04.wav",
        "vo/npc/male01/vanswer14.wav",
        "vo/npc/male01/vquestion02.wav",
        "vo/npc/male01/watchout.wav",
        "vo/npc/male01/watchwhat.wav",
        "vo/npc/male01/yeah02.wav",
        "hl2_clips/male01_p.wav",
    }

    NPC_PISS_REACTIONS["f"] = NPC_PISS_REACTIONS["m"] -- refer to the same list as male because the lines are all the same, but we'll change the path later


    PLAYERMODEL_TO_NPC_PISS_REACTIONS = {}
    PLAYERMODEL_TO_NPC_PISS_REACTIONS["models/player/kleiner.mdl"]="npc_kleiner"
    PLAYERMODEL_TO_NPC_PISS_REACTIONS["models/player/barney.mdl"]="npc_barney"
    PLAYERMODEL_TO_NPC_PISS_REACTIONS["models/player/breen.mdl"]="npc_breen"
    PLAYERMODEL_TO_NPC_PISS_REACTIONS["models/player/alyx.mdl"]="npc_alyx"
    PLAYERMODEL_TO_NPC_PISS_REACTIONS["models/player/eli.mdl"]="npc_eli"
    PLAYERMODEL_TO_NPC_PISS_REACTIONS["models/player/gman_high.mdl"]="npc_gman"
    PLAYERMODEL_TO_NPC_PISS_REACTIONS["models/player/monk.mdl"]="npc_monk"