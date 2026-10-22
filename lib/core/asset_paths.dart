class AssetPaths {
  static const images = 'assets/images';

  static const bgSplash = '$images/bg_splash.png';
  static const bgOnboarding = '$images/bg_onboarding.png';
  static const bgMainMenu = '$images/bg_main_menu.png';
  static const bgMapAct1 = '$images/bg_map_act1.png';
  static const bgMapAct2 = '$images/bg_map_act2.png';
  static const bgMapAct3 = '$images/bg_map_act3.png';
  static const bgMapGold = '$images/bg_map_gold.png';
  static const bgStoreGold = '$images/bg_store_gold.png';
  static const bgEndingFree = '$images/bg_ending_free.png';
  static const bgEndingGold = '$images/bg_ending_gold.png';
  static const logo = '$images/logo_jokers_trap.png';
  static const jokerMenu = '$images/joker_menu.png';
  static const jokerMenuBlink = '$images/joker_menu_blink.png';
  static const jokerAct1 = '$images/joker_act1.png';
  static const jokerAct2 = '$images/joker_act2.png';
  static const jokerAct3 = '$images/joker_act3.png';
  static const jokerGold = '$images/joker_gold.png';
  static const jokerReactionWin = '$images/joker_reaction_win.png';
  static const jokerReactionLose = '$images/joker_reaction_lose.png';
  static const jokerReactionBow = '$images/joker_reaction_bow.png';
  static const jokerEndingUnmasked = '$images/joker_ending_unmasked.png';
  static const jokerEndingBow = '$images/joker_ending_bow.png';
  static const onboardingAnchor = '$images/onboarding_anchor.png';
  static const onboardingFlip = '$images/onboarding_flip.png';
  static const onboardingRecover = '$images/onboarding_recover.png';
  static const buttonPrimary = '$images/ui_button_primary.png';
  static const buttonSecondary = '$images/ui_button_secondary.png';
  static const buttonGold = '$images/ui_button_gold.png';
  static const panelRule = '$images/panel_rule.png';
  static const panelRuleOption = '$images/panel_rule_option.png';
  static const panelResult = '$images/panel_result.png';
  static const dialogFrame = '$images/dialog_frame.png';
  static const cardFaceRed = '$images/card_face_red.png';
  static const cardFaceBlack = '$images/card_face_black.png';
  static const cardBack = '$images/card_back.png';
  static const cardBackRule = '$images/card_back_rule.png';
  static const cardSelectionAnchor = '$images/card_selection_anchor.png';
  static const cardSelectionNormal = '$images/card_selection_normal.png';
  static const suitHearts = '$images/suit_hearts.png';
  static const suitDiamonds = '$images/suit_diamonds.png';
  static const suitClubs = '$images/suit_clubs.png';
  static const suitSpades = '$images/suit_spades.png';
  static const mapPath = '$images/map_path.png';
  static const nodeUnlocked = '$images/node_unlocked.png';
  static const nodeCleared = '$images/node_cleared.png';
  static const nodeLocked = '$images/node_locked.png';
  static const goldenTicketHero = '$images/golden_ticket_hero.png';
  static const fxConfetti = '$images/fx_confetti.png';
  static const fxRedVignette = '$images/fx_red_vignette.png';
  static const iconMask = '$images/icon_mask_silhouette.png';

  static const musicMain = 'audio/music_main_theme.m4a';
  static const musicAct1 = 'audio/music_act1.m4a';
  static const musicAct2 = 'audio/music_act2.m4a';
  static const musicAct3 = 'audio/music_act3.m4a';
  static const musicGolden = 'audio/music_golden_act.m4a';
  static const musicEndingFree = 'audio/music_ending_free.m4a';
  static const musicEndingGold = 'audio/music_ending_gold.m4a';

  static const sfxButton = 'audio/sfx_button_tap.wav';
  static const sfxDeal = 'audio/sfx_card_deal.wav';
  static const sfxSelect = 'audio/sfx_card_select.wav';
  static const sfxDeselect = 'audio/sfx_card_deselect.wav';
  static const sfxRuleFlip = 'audio/sfx_rule_flip.wav';
  static const sfxObjection = 'audio/sfx_objection.wav';
  static const sfxTimer = 'audio/sfx_timer_warning.wav';
  static const sfxWin = 'audio/sfx_round_win.wav';
  static const sfxLoss = 'audio/sfx_round_loss.wav';
  static const sfxLaugh1 = 'audio/sfx_joker_laugh_1.wav';
  static const sfxLaugh2 = 'audio/sfx_joker_laugh_2.wav';
  static const sfxShock = 'audio/sfx_joker_shock.wav';
  static const sfxShowClear = 'audio/sfx_show_clear.wav';
  static const sfxShowFail = 'audio/sfx_show_fail.wav';
  static const sfxLocked = 'audio/sfx_locked.wav';
  static const sfxPurchase = 'audio/sfx_purchase_success.wav';
  static const sfxCurtain = 'audio/sfx_curtain_open.wav';
  static const sfxConfetti = 'audio/sfx_confetti.wav';
  static const sfxError = 'audio/sfx_error_soft.wav';

  static String mapBackground(int act) {
    return switch (act) {
      0 => bgMapAct1,
      1 => bgMapAct2,
      2 => bgMapAct3,
      _ => bgMapGold,
    };
  }

  static String actJoker(int act) {
    return switch (act) {
      0 => jokerAct1,
      1 => jokerAct2,
      2 => jokerAct3,
      _ => jokerGold,
    };
  }

  static String musicForAct(int act) {
    return switch (act) {
      0 => musicAct1,
      1 => musicAct2,
      2 => musicAct3,
      _ => musicGolden,
    };
  }

  static String suitAsset(String suitName) {
    return switch (suitName) {
      'hearts' => suitHearts,
      'diamonds' => suitDiamonds,
      'clubs' => suitClubs,
      _ => suitSpades,
    };
  }
}
