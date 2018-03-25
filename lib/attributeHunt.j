/**
 属性 - 伤害
*/
globals
    hAttrHunt hattrHunt
endglobals

struct hAttrHuntBean

    public static unit fromUnit = null
    public static unit toUnit = null
    public static string huntEff = null
    public static real damage = 0
    public static string huntKind = null
    public static string huntType = null
    public static string isBreak = null
    public static boolean isNoAvoid = false
    public static boolean isEffect = false

    public static group whichGroup = null
    public static group whichGroupRepeat = null
    public static string whichGroupHuntEff = null
    public static location whichGroupHuntEffLoc = null

    static method create takes nothing returns hAttrHuntBean
        local hAttrHuntBean x
        set x = hAttrHuntBean.allocate()
        set x.fromUnit = null
        set x.toUnit = null
        set x.huntEff = null
        set x.damage = 0
        set x.huntKind = null
        set x.huntType = null
        set x.isBreak = null
        set x.isNoAvoid = false
        set x.isEffect = false
        set x.whichGroup = null
        set x.whichGroupRepeat = null
        set x.whichGroupHuntEff = null
        set x.whichGroupHuntEffLoc = null
        return x
    endmethod
    method destroy takes nothing returns nothing
        set fromUnit = null
        set toUnit = null
        set huntEff = null
        set damage = 0
        set huntKind = null
        set huntType = null
        set isBreak = null
        set isNoAvoid = false
        set isEffect = false
        set whichGroupHuntEff = null
        if(whichGroup!=null)then
            call GroupClear(whichGroup)
            call DestroyGroup(whichGroup)
            set whichGroup = null
        endif
        if(whichGroupRepeat!=null)then
            call GroupClear(whichGroupRepeat)
            call DestroyGroup(whichGroupRepeat)
            set whichGroupRepeat = null
        endif
        if(whichGroupHuntEffLoc!=null)then
            call RemoveLocation(whichGroupHuntEffLoc)
            set whichGroupHuntEffLoc = null
        endif
    endmethod
endstruct

struct hAttrHunt

	/**
     * 伤害单位
     * heffect 特效
     * bean.huntKind伤害方式: 
     		attack 攻击
     		skill 技能
     		item 物品
     		special 特殊（如分裂，攻击特效的爆炸、闪电链之类的）
     * bean.huntType伤害类型: 
     		physical 物理伤害则无视护甲<享受物理暴击加成，受护甲影响>
     		magic 魔法<享受魔法暴击加成，受魔抗影响>
            fire    火
            soil    土
            water   水 
            ice     冰 
            wind    风
            light   光 
            dark    暗
            wood    木
            thunder 雷
            poison  毒
     		real 真实
     		absolute 绝对
     * isBreak是否无视：true | false 物理伤害则无视护甲 | 魔法伤害则无视魔抗
     * isNoAvoid是否无法回避：true | false
     * isEffect是否触发伤害特效：true | false 攻击默认强制设为true
     */
    public static method huntUnit takes hAttrHuntBean bean returns nothing
    	
        local unit fromUnit = bean.fromUnit
        local unit toUnit = bean.toUnit
    	local real realDamage = 0
        local string realDamageString = ""
        local string realDamageStringColor = "d9d9d9"
        local real punishEffectRatio = 0
        local real punishEffect = 0

        local real fromUnitPunishHeavy = 1
        local boolean isEffect = bean.isEffect
        local boolean isAvoid = false
        local boolean isKnocking = false
        local boolean isViolence = false

    	local location loc = null
    	local group g = null
    	local unit u = null
        local integer tempInt = 0
        local real tempReal = 0
        local hFilter filter
        local hAttrHuntBean huntBean

        //获取单位属性
    	local real fromUnitAttackPhysical = 0.0
        local real fromUnitAttackMagic = 0.0
        local real fromUnitAttackPhysicalPercent = 0.0
        local real fromUnitAttackMagicPercent = 0.0
    	local real fromUnitAim = 0.0
    	local real fromUnitKnocking = 0.0
    	local real fromUnitViolence = 0.0
    	local real fromUnitHemophagia = 0.0
    	local real fromUnitHemophagiaSkill = 0.0
        local real fromUnitSplit = 0.0
    	local real fromUnitSplitRange = 0.0
    	local real fromUnitLuck = 0.0
        local real fromUnitHuntAmplitude = 0.0
        local real fromUnitNaturalFire = 0.0
        local real fromUnitNaturalSoil = 0.0
        local real fromUnitNaturalWater = 0.0
        local real fromUnitNaturalIce = 0.0
        local real fromUnitNaturalWind = 0.0
        local real fromUnitNaturalLight = 0.0
        local real fromUnitNaturalDark = 0.0
        local real fromUnitNaturalWood = 0.0
        local real fromUnitNaturalThunder = 0.0
    	local real fromUnitNaturalPoison = 0.0
        //获取攻击/伤害特效
		local real fromUnitHuntEffectLifeBackVal = 0.0
        local real fromUnitHuntEffectLifeBackDuring = 0.0
        local real fromUnitHuntEffectManaBackVal = 0.0
        local real fromUnitHuntEffectManaBackDuring = 0.0
        local real fromUnitHuntEffectAttackSpeedVal = 0.0
        local real fromUnitHuntEffectAttackSpeedDuring = 0.0
        local real fromUnitHuntEffectAttackPhysicalVal = 0.0
        local real fromUnitHuntEffectAttackPhysicalDuring = 0.0
        local real fromUnitHuntEffectAttackMagicVal = 0.0
        local real fromUnitHuntEffectAttackMagicDuring = 0.0
        local real fromUnitHuntEffectMoveVal = 0.0
        local real fromUnitHuntEffectMoveDuring = 0.0
        local real fromUnitHuntEffectAimVal = 0.0
        local real fromUnitHuntEffectAimDuring = 0.0
        local real fromUnitHuntEffectStrVal = 0.0
        local real fromUnitHuntEffectStrDuring = 0.0
        local real fromUnitHuntEffectAgiVal = 0.0
        local real fromUnitHuntEffectAgiDuring = 0.0
        local real fromUnitHuntEffectIntVal = 0.0
        local real fromUnitHuntEffectIntDuring = 0.0
        local real fromUnitHuntEffectKnockingVal = 0.0
        local real fromUnitHuntEffectKnockingDuring = 0.0
        local real fromUnitHuntEffectViolenceVal = 0.0
        local real fromUnitHuntEffectViolenceDuring = 0.0
        local real fromUnitHuntEffectHemophagiaVal = 0.0
        local real fromUnitHuntEffectHemophagiaDuring = 0.0
        local real fromUnitHuntEffectHemophagiaSkillVal = 0.0
        local real fromUnitHuntEffectHemophagiaSkillDuring = 0.0
        local real fromUnitHuntEffectSplitVal = 0.0
        local real fromUnitHuntEffectSplitDuring = 0.0
        local real fromUnitHuntEffectLuckVal = 0.0
        local real fromUnitHuntEffectLuckDuring = 0.0
        local real fromUnitHuntEffectHuntAmplitudeVal = 0.0
        local real fromUnitHuntEffectHuntAmplitudeDuring = 0.0
        local real fromUnitHuntEffectPoisonVal = 0.0
        local real fromUnitHuntEffectPoisonDuring = 0.0
        local real fromUnitHuntEffectFireVal = 0.0
        local real fromUnitHuntEffectFireDuring = 0.0
        local real fromUnitHuntEffectDryVal = 0.0
        local real fromUnitHuntEffectDryDuring = 0.0
        local real fromUnitHuntEffectFreezeVal = 0.0
        local real fromUnitHuntEffectFreezeDuring = 0.0
        local real fromUnitHuntEffectColdVal = 0.0
        local real fromUnitHuntEffectColdDuring = 0.0
        local real fromUnitHuntEffectBluntVal = 0.0
        local real fromUnitHuntEffectBluntDuring = 0.0
        local real fromUnitHuntEffectMuggleVal = 0.0
        local real fromUnitHuntEffectMuggleDuring = 0.0
        local real fromUnitHuntEffectCorrosionVal = 0.0
        local real fromUnitHuntEffectCorrosionDuring = 0.0
        local real fromUnitHuntEffectChaosVal = 0.0
        local real fromUnitHuntEffectChaosDuring = 0.0
        local real fromUnitHuntEffectTwineVal = 0.0
        local real fromUnitHuntEffectTwineDuring = 0.0
        local real fromUnitHuntEffectBlindVal = 0.0
        local real fromUnitHuntEffectBlindDuring = 0.0
        local real fromUnitHuntEffectTortuaVal = 0.0
        local real fromUnitHuntEffectTortuaDuring = 0.0
        local real fromUnitHuntEffectWeakVal = 0.0
        local real fromUnitHuntEffectWeakDuring = 0.0
        local real fromUnitHuntEffectAstrictVal = 0.0
        local real fromUnitHuntEffectAstrictDuring = 0.0
        local real fromUnitHuntEffectFoolishVal = 0.0
        local real fromUnitHuntEffectFoolishDuring = 0.0
        local real fromUnitHuntEffectDullVal = 0.0
        local real fromUnitHuntEffectDullDuring = 0.0
        local real fromUnitHuntEffectDirtVal = 0.0
        local real fromUnitHuntEffectDirtDuring = 0.0
        local real fromUnitHuntEffectSwimOdds = 0.0
        local real fromUnitHuntEffectSwimDuring = 0.0
        local real fromUnitHuntEffectHeavyOdds = 0.0
        local real fromUnitHuntEffectHeavyVal = 0.0
        local real fromUnitHuntEffectBreakOdds = 0.0
        local real fromUnitHuntEffectBreakDuring = 0.0
        local real fromUnitHuntEffectUnluckVal = 0.0
        local real fromUnitHuntEffectUnluckDuring = 0.0
        local real fromUnitHuntEffectSilentOdds = 0.0
        local real fromUnitHuntEffectSilentDuring = 0.0
        local real fromUnitHuntEffectUnarmOdds = 0.0
        local real fromUnitHuntEffectUnarmDuring = 0.0
        local real fromUnitHuntEffectFetterOdds = 0.0
        local real fromUnitHuntEffectFetterDuring = 0.0
        local real fromUnitHuntEffectBombVal = 0.0
        local real fromUnitHuntEffectBombRange = 0.0
        local string fromUnitHuntEffectBombModel = ""
        local real fromUnitHuntEffectLightningChainVal = 0.0
        local real fromUnitHuntEffectLightningChainOdds = 0.0
        local real fromUnitHuntEffectLightningChainQty = 0.0
        local real fromUnitHuntEffectLightningChainReduce = 0.0
        local string fromUnitHuntEffectLightningChainModel = ""
        local real fromUnitHuntEffectCrackFlyVal = 0.0
        local real fromUnitHuntEffectCrackFlyOdds = 0.0
        local real fromUnitHuntEffectCrackFlyDistance = 0.0
        local real fromUnitHuntEffectCrackFlyHigh = 0.0
        //获取受伤单位抵抗属性
    	local real toUnitDefend = 0.0
    	local real toUnitResistance = 0.0
    	local real toUnitToughness = 0.0
    	local real toUnitAvoid = 0.0
    	local real toUnitMortalOppose = 0.0
    	local real toUnitSwimOppose = 0.0
    	local real toUnitLuck = 0.0
    	local real toUnitInvincible = 0.0
    	local real toUnitHuntRebound = 0.0
    	local real toUnitCure = 0.0
        local real toUnitPunishOppose = 0.0
        local real toUnitNaturalFireOppose = 0.0
        local real toUnitNaturalSoilOppose = 0.0
        local real toUnitNaturalWaterOppose = 0.0
        local real toUnitNaturalIceOppose = 0.0
        local real toUnitNaturalWindOppose = 0.0
        local real toUnitNaturalLightOppose = 0.0
        local real toUnitNaturalDarkOppose = 0.0
        local real toUnitNaturalWoodOppose = 0.0
        local real toUnitNaturalThunderOppose = 0.0
        local real toUnitNaturalPoisonOppose = 0.0

        if(bean.damage<0.2)then
            call hconsole.warning("伤害太小被忽略")
            return
        endif
        if(fromUnit==null)then
            call hconsole.warning("伤害源不存在")
            return
        endif
        if(toUnit==null)then
            call hconsole.warning("目标不存在")
            return
        endif
        if(his.alive(toUnit)==false)then
            call hconsole.warning("目标已死亡")
            return
        endif

    	if( bean.huntEff != null and bean.huntEff != "" ) then
    		set loc = GetUnitLoc( toUnit )
			call heffect.toLoc(bean.huntEff,loc,0)
            call RemoveLocation( loc )
    	endif

        //获取单位属性
    	set fromUnitAttackPhysical = hattr.getAttackPhysical(fromUnit)
        set fromUnitAttackMagic = hattr.getAttackMagic(fromUnit)
        set fromUnitAttackPhysicalPercent = 0
        set fromUnitAttackMagicPercent = 0
    	set fromUnitAim = hattr.getAim(fromUnit)
    	set fromUnitKnocking = hattr.getKnocking(fromUnit)
    	set fromUnitViolence = hattr.getViolence(fromUnit)
    	set fromUnitHemophagia = hattr.getHemophagia(fromUnit)
    	set fromUnitHemophagiaSkill = hattr.getHemophagiaSkill(fromUnit)
        set fromUnitSplit = hattr.getSplit(fromUnit)
    	set fromUnitSplitRange = hattr.getSplitRange(fromUnit)
    	set fromUnitLuck = hattr.getLuck(fromUnit)
        set fromUnitHuntAmplitude = hattr.getHuntAmplitude(fromUnit)
        set fromUnitNaturalFire = hattrNatural.getFire(fromUnit)
        set fromUnitNaturalSoil = hattrNatural.getSoil(fromUnit)
        set fromUnitNaturalWater = hattrNatural.getWater(fromUnit)
        set fromUnitNaturalIce = hattrNatural.getIce(fromUnit)
        set fromUnitNaturalWind = hattrNatural.getWind(fromUnit)
        set fromUnitNaturalLight = hattrNatural.getLight(fromUnit)
        set fromUnitNaturalDark = hattrNatural.getDark(fromUnit)
        set fromUnitNaturalWood = hattrNatural.getWood(fromUnit)
        set fromUnitNaturalThunder = hattrNatural.getThunder(fromUnit)
    	set fromUnitNaturalPoison = hattrNatural.getPoison(fromUnit)
        //获取攻击/伤害特效
		set fromUnitHuntEffectLifeBackVal = hAttrEffect.getLifeBackVal(fromUnit)
        set fromUnitHuntEffectLifeBackDuring = hAttrEffect.getLifeBackDuring(fromUnit)
        set fromUnitHuntEffectManaBackVal = hAttrEffect.getManaBackVal(fromUnit)
        set fromUnitHuntEffectManaBackDuring = hAttrEffect.getManaBackDuring(fromUnit)
        set fromUnitHuntEffectAttackSpeedVal = hAttrEffect.getAttackSpeedVal(fromUnit)
        set fromUnitHuntEffectAttackSpeedDuring = hAttrEffect.getAttackSpeedDuring(fromUnit)
        set fromUnitHuntEffectAttackPhysicalVal = hAttrEffect.getAttackPhysicalVal(fromUnit)
        set fromUnitHuntEffectAttackPhysicalDuring = hAttrEffect.getAttackPhysicalDuring(fromUnit)
        set fromUnitHuntEffectAttackMagicVal = hAttrEffect.getAttackMagicVal(fromUnit)
        set fromUnitHuntEffectAttackMagicDuring = hAttrEffect.getAttackMagicDuring(fromUnit)
        set fromUnitHuntEffectMoveVal = hAttrEffect.getMoveVal(fromUnit)
        set fromUnitHuntEffectMoveDuring = hAttrEffect.getMoveDuring(fromUnit)
        set fromUnitHuntEffectAimVal = hAttrEffect.getAimVal(fromUnit)
        set fromUnitHuntEffectAimDuring = hAttrEffect.getAimDuring(fromUnit)
        set fromUnitHuntEffectStrVal = hAttrEffect.getStrVal(fromUnit)
        set fromUnitHuntEffectStrDuring = hAttrEffect.getStrDuring(fromUnit)
        set fromUnitHuntEffectAgiVal = hAttrEffect.getAgiVal(fromUnit)
        set fromUnitHuntEffectAgiDuring = hAttrEffect.getAgiDuring(fromUnit)
        set fromUnitHuntEffectIntVal = hAttrEffect.getIntVal(fromUnit)
        set fromUnitHuntEffectIntDuring = hAttrEffect.getIntDuring(fromUnit)
        set fromUnitHuntEffectKnockingVal = hAttrEffect.getKnockingVal(fromUnit)
        set fromUnitHuntEffectKnockingDuring = hAttrEffect.getKnockingDuring(fromUnit)
        set fromUnitHuntEffectViolenceVal = hAttrEffect.getViolenceVal(fromUnit)
        set fromUnitHuntEffectViolenceDuring = hAttrEffect.getViolenceDuring(fromUnit)
        set fromUnitHuntEffectHemophagiaVal = hAttrEffect.getHemophagiaVal(fromUnit)
        set fromUnitHuntEffectHemophagiaDuring = hAttrEffect.getHemophagiaDuring(fromUnit)
        set fromUnitHuntEffectHemophagiaSkillVal = hAttrEffect.getHemophagiaSkillVal(fromUnit)
        set fromUnitHuntEffectHemophagiaSkillDuring = hAttrEffect.getHemophagiaSkillDuring(fromUnit)
        set fromUnitHuntEffectSplitVal = hAttrEffect.getSplitVal(fromUnit)
        set fromUnitHuntEffectSplitDuring = hAttrEffect.getSplitDuring(fromUnit)
        set fromUnitHuntEffectLuckVal = hAttrEffect.getLuckVal(fromUnit)
        set fromUnitHuntEffectLuckDuring = hAttrEffect.getLuckDuring(fromUnit)
        set fromUnitHuntEffectHuntAmplitudeVal = hAttrEffect.getHuntAmplitudeVal(fromUnit)
        set fromUnitHuntEffectHuntAmplitudeDuring = hAttrEffect.getHuntAmplitudeDuring(fromUnit)
        set fromUnitHuntEffectPoisonVal = hAttrEffect.getPoisonVal(fromUnit)
        set fromUnitHuntEffectPoisonDuring = hAttrEffect.getPoisonDuring(fromUnit)
        set fromUnitHuntEffectFireVal = hAttrEffect.getFireVal(fromUnit)
        set fromUnitHuntEffectFireDuring = hAttrEffect.getFireDuring(fromUnit)
        set fromUnitHuntEffectDryVal = hAttrEffect.getDryVal(fromUnit)
        set fromUnitHuntEffectDryDuring = hAttrEffect.getDryDuring(fromUnit)
        set fromUnitHuntEffectFreezeVal = hAttrEffect.getFreezeVal(fromUnit)
        set fromUnitHuntEffectFreezeDuring = hAttrEffect.getFreezeDuring(fromUnit)
        set fromUnitHuntEffectColdVal = hAttrEffect.getColdVal(fromUnit)
        set fromUnitHuntEffectColdDuring = hAttrEffect.getColdDuring(fromUnit)
        set fromUnitHuntEffectBluntVal = hAttrEffect.getBluntVal(fromUnit)
        set fromUnitHuntEffectBluntDuring = hAttrEffect.getBluntDuring(fromUnit)
        set fromUnitHuntEffectMuggleVal = hAttrEffect.getMuggleVal(fromUnit)
        set fromUnitHuntEffectMuggleDuring = hAttrEffect.getMuggleDuring(fromUnit)
        set fromUnitHuntEffectCorrosionVal = hAttrEffect.getCorrosionVal(fromUnit)
        set fromUnitHuntEffectCorrosionDuring = hAttrEffect.getCorrosionDuring(fromUnit)
        set fromUnitHuntEffectChaosVal = hAttrEffect.getChaosVal(fromUnit)
        set fromUnitHuntEffectChaosDuring = hAttrEffect.getChaosDuring(fromUnit)
        set fromUnitHuntEffectTwineVal = hAttrEffect.getTwineVal(fromUnit)
        set fromUnitHuntEffectTwineDuring = hAttrEffect.getTwineDuring(fromUnit)
        set fromUnitHuntEffectBlindVal = hAttrEffect.getBlindVal(fromUnit)
        set fromUnitHuntEffectBlindDuring = hAttrEffect.getBlindDuring(fromUnit)
        set fromUnitHuntEffectTortuaVal = hAttrEffect.getTortuaVal(fromUnit)
        set fromUnitHuntEffectTortuaDuring = hAttrEffect.getTortuaDuring(fromUnit)
        set fromUnitHuntEffectWeakVal = hAttrEffect.getWeakVal(fromUnit)
        set fromUnitHuntEffectWeakDuring = hAttrEffect.getWeakDuring(fromUnit)
        set fromUnitHuntEffectAstrictVal = hAttrEffect.getAstrictVal(fromUnit)
        set fromUnitHuntEffectAstrictDuring = hAttrEffect.getAstrictDuring(fromUnit)
        set fromUnitHuntEffectFoolishVal = hAttrEffect.getFoolishVal(fromUnit)
        set fromUnitHuntEffectFoolishDuring = hAttrEffect.getFoolishDuring(fromUnit)
        set fromUnitHuntEffectDullVal = hAttrEffect.getDullVal(fromUnit)
        set fromUnitHuntEffectDullDuring = hAttrEffect.getDullDuring(fromUnit)
        set fromUnitHuntEffectDirtVal = hAttrEffect.getDirtVal(fromUnit)
        set fromUnitHuntEffectDirtDuring = hAttrEffect.getDirtDuring(fromUnit)
        set fromUnitHuntEffectSwimOdds = hAttrEffect.getSwimOdds(fromUnit)
        set fromUnitHuntEffectSwimDuring = hAttrEffect.getSwimDuring(fromUnit)
        set fromUnitHuntEffectHeavyOdds = hAttrEffect.getHeavyOdds(fromUnit)
        set fromUnitHuntEffectHeavyVal = hAttrEffect.getHeavyVal(fromUnit)
        set fromUnitHuntEffectBreakOdds = hAttrEffect.getBreakOdds(fromUnit)
        set fromUnitHuntEffectBreakDuring = hAttrEffect.getBreakDuring(fromUnit)
        set fromUnitHuntEffectUnluckVal = hAttrEffect.getUnluckVal(fromUnit)
        set fromUnitHuntEffectUnluckDuring = hAttrEffect.getUnluckDuring(fromUnit)
        set fromUnitHuntEffectSilentOdds = hAttrEffect.getSilentOdds(fromUnit)
        set fromUnitHuntEffectSilentDuring = hAttrEffect.getSilentDuring(fromUnit)
        set fromUnitHuntEffectUnarmOdds = hAttrEffect.getUnarmOdds(fromUnit)
        set fromUnitHuntEffectUnarmDuring = hAttrEffect.getUnarmDuring(fromUnit)
        set fromUnitHuntEffectFetterOdds = hAttrEffect.getFetterOdds(fromUnit)
        set fromUnitHuntEffectFetterDuring = hAttrEffect.getFetterDuring(fromUnit)
        set fromUnitHuntEffectBombVal = hAttrEffect.getBombVal(fromUnit)
        set fromUnitHuntEffectBombRange = hAttrEffect.getBombRange(fromUnit)
        set fromUnitHuntEffectBombModel = hAttrEffect.getBombModel(fromUnit)
        set fromUnitHuntEffectLightningChainVal = hAttrEffect.getLightningChainVal(fromUnit)
        set fromUnitHuntEffectLightningChainOdds = hAttrEffect.getLightningChainOdds(fromUnit)
        set fromUnitHuntEffectLightningChainQty = hAttrEffect.getLightningChainQty(fromUnit)
        set fromUnitHuntEffectLightningChainReduce = hAttrEffect.getLightningChainReduce(fromUnit)
        set fromUnitHuntEffectLightningChainModel = hAttrEffect.getLightningChainModel(fromUnit)
        set fromUnitHuntEffectCrackFlyVal = hAttrEffect.getCrackFlyVal(fromUnit)
        set fromUnitHuntEffectCrackFlyOdds = hAttrEffect.getCrackFlyOdds(fromUnit)
        set fromUnitHuntEffectCrackFlyDistance = hAttrEffect.getCrackFlyDistance(fromUnit)
        set fromUnitHuntEffectCrackFlyHigh = hAttrEffect.getCrackFlyHigh(fromUnit)
        //获取受伤单位抵抗属性
    	set toUnitDefend = hattr.getDefend(toUnit)
    	set toUnitResistance = hattr.getResistance(toUnit)
    	set toUnitToughness = hattr.getToughness(toUnit)
    	set toUnitAvoid = hattr.getAvoid(toUnit)
    	set toUnitMortalOppose = hattr.getMortalOppose(toUnit)
    	set toUnitSwimOppose = hattr.getSwimOppose(toUnit)
    	set toUnitLuck = hattr.getLuck(toUnit)
    	set toUnitInvincible = hattr.getInvincible(toUnit)
    	set toUnitHuntRebound = hattr.getHuntRebound(toUnit)
    	set toUnitCure = hattr.getCure(toUnit)
        set toUnitPunishOppose = hattr.getPunishOppose(toUnit)
        set toUnitNaturalFireOppose = hattrNatural.getFireOppose(toUnit)
        set toUnitNaturalSoilOppose = hattrNatural.getSoilOppose(toUnit)
        set toUnitNaturalWaterOppose = hattrNatural.getWaterOppose(toUnit)
        set toUnitNaturalIceOppose = hattrNatural.getIceOppose(toUnit)
        set toUnitNaturalWindOppose = hattrNatural.getWindOppose(toUnit)
        set toUnitNaturalLightOppose = hattrNatural.getLightOppose(toUnit)
        set toUnitNaturalDarkOppose = hattrNatural.getDarkOppose(toUnit)
        set toUnitNaturalWoodOppose = hattrNatural.getWoodOppose(toUnit)
        set toUnitNaturalThunderOppose = hattrNatural.getThunderOppose(toUnit)
        set toUnitNaturalPoisonOppose = hattrNatural.getPoisonOppose(toUnit)

        //计算硬直抵抗
        set punishEffectRatio = 0.99
        if(toUnitPunishOppose>0)then
            set punishEffectRatio = punishEffectRatio-toUnitPunishOppose*0.01
            if(punishEffectRatio<0.100)then
                set punishEffectRatio = 0.100
            endif
        endif

        //*重要* hjass必须设定护甲因子为0，这里为了修正魔兽负护甲依然因子保持0.06的bug
        //当护甲x为负时，最大-20,公式2-(1-a)^abs(x)
        if(toUnitDefend<0 and toUnitDefend>=-20)then
            set bean.damage =  bean.damage / (2-Pow(0.94,hmath.rabs(toUnitDefend)))
        elseif(toUnitDefend<0 and toUnitDefend<-20)then
            set bean.damage =  bean.damage / (2-Pow(0.94,20))
        endif

        //赋值伤害
        set realDamage = bean.damage

        //计算物理攻击和魔法攻击的占比
        if(fromUnitAttackPhysical+fromUnitAttackMagic>0)then
            set fromUnitAttackPhysicalPercent = fromUnitAttackPhysical/(fromUnitAttackPhysical+fromUnitAttackMagic)
            set fromUnitAttackMagicPercent = fromUnitAttackMagic/(fromUnitAttackPhysical+fromUnitAttackMagic)
        endif

        //判断伤害方式
        if( bean.huntKind=="attack" )then
            if(his.unarm(fromUnit)==true)then
                return
            endif
            set isEffect = true
        elseif( bean.huntKind=="skill" )then
            if(his.silent(fromUnit)==true)then
                return
            endif
        elseif( bean.huntKind=="item" )then
        elseif( bean.huntKind=="special" )then
        else
            call hconsole.error("伤害单位错误：bean.huntKind")
            return
        endif
        //判断伤害类型
        if( bean.huntType=="physical" )then
            set fromUnitViolence = 0
        elseif( bean.huntType=="magic" )then
            set fromUnitKnocking = 0
        elseif( bean.huntType=="real" )then
            set fromUnitViolence = 0
            set fromUnitKnocking = 0
        elseif( bean.huntType=="absolute" )then
            set fromUnitViolence = 0
            set fromUnitKnocking = 0
        endif

        //call console.info("bean.huntType:"+bean.huntType)

        //判断无视Break 分为 null defend resistance both
        if( bean.isBreak == "defend" ) then
            //@触发无视护甲事件
            set hevtBean = hEvtBean.create()
            set hevtBean.triggerKey = "breakDefend"
            set hevtBean.triggerUnit = fromUnit
            set hevtBean.targetUnit = toUnit
            set hevtBean.breakType = bean.isBreak
            set hevtBean.value = toUnitDefend
            call hevt.triggerEvent(hevtBean)
            call hevtBean.destroy()
            //@触发被无视护甲事件
            set hevtBean = hEvtBean.create()
            set hevtBean.triggerKey = "beBreakDefend"
            set hevtBean.triggerUnit = toUnit
            set hevtBean.sourceUnit = fromUnit
            set hevtBean.breakType = bean.isBreak
            set hevtBean.value = toUnitDefend
            call hevt.triggerEvent(hevtBean)
            call hevtBean.destroy()
            //
            if(toUnitDefend>0) then
                set toUnitDefend = 0
            endif
            set realDamageString = realDamageString+"无视护甲"
            set realDamageStringColor = "f97373"
        elseif( bean.isBreak == "resistance" ) then
            //@触发无视魔抗事件
            set hevtBean = hEvtBean.create()
            set hevtBean.triggerKey = "breakResistance"
            set hevtBean.triggerUnit = fromUnit
            set hevtBean.targetUnit = toUnit
            set hevtBean.breakType = bean.isBreak
            set hevtBean.value = toUnitResistance
            call hevt.triggerEvent(hevtBean)
            call hevtBean.destroy()
            //@触发被无视魔抗事件
            set hevtBean = hEvtBean.create()
            set hevtBean.triggerKey = "beBreakResistance"
            set hevtBean.triggerUnit = toUnit
            set hevtBean.sourceUnit = fromUnit
            set hevtBean.breakType = bean.isBreak
            set hevtBean.value = toUnitResistance
            call hevt.triggerEvent(hevtBean)
            call hevtBean.destroy()
            //
            if(toUnitResistance>0) then
                set toUnitResistance = 0
            endif
            set realDamageString = realDamageString+"无视魔抗"
            set realDamageStringColor = "6fa8dc"
        elseif( bean.isBreak == "both" ) then
            //@触发同时无视护甲和魔抗事件
            set hevtBean = hEvtBean.create()
            set hevtBean.triggerKey = "breakDefendAndResistance"
            set hevtBean.triggerUnit = fromUnit
            set hevtBean.targetUnit = toUnit
            set hevtBean.breakType = bean.isBreak
            set hevtBean.value = toUnitDefend
            set hevtBean.value2 = toUnitResistance
            call hevt.triggerEvent(hevtBean)
            call hevtBean.destroy()
            //@触发被同时无视护甲和魔抗事件
            set hevtBean = hEvtBean.create()
            set hevtBean.triggerKey = "beBreakDefendAndResistance"
            set hevtBean.triggerUnit = toUnit
            set hevtBean.sourceUnit = fromUnit
            set hevtBean.breakType = bean.isBreak
            set hevtBean.value = toUnitDefend
            set hevtBean.value2 = toUnitResistance
            call hevt.triggerEvent(hevtBean)
            call hevtBean.destroy()
            //
            if(toUnitDefend>0) then
                set toUnitDefend = 0
            endif
            if(toUnitResistance>0) then
                set toUnitResistance = 0
            endif
            set realDamageString = realDamageString+"无视护抗"
            set realDamageStringColor = "8e7cc3"
        endif
        //判断无视回避
        if( bean.isNoAvoid == true ) then
            set toUnitAvoid = 0
            set realDamageString = realDamageString+"无视回避"
            set realDamageStringColor = "76a5af"
        endif
        //计算伤害增幅
        if( fromUnitHuntAmplitude != 0 ) then
            set realDamage = realDamage * (1+fromUnitHuntAmplitude*0.01)
        endif

        //计算自然属性
        set fromUnitNaturalFire = fromUnitNaturalFire-toUnitNaturalFireOppose
        set fromUnitNaturalSoil = fromUnitNaturalSoil-toUnitNaturalSoilOppose
        set fromUnitNaturalWater = fromUnitNaturalWater-toUnitNaturalWaterOppose
        set fromUnitNaturalIce = fromUnitNaturalIce-toUnitNaturalIceOppose
        set fromUnitNaturalWind = fromUnitNaturalWind-toUnitNaturalWindOppose
        set fromUnitNaturalLight = fromUnitNaturalLight-toUnitNaturalLightOppose
        set fromUnitNaturalDark = fromUnitNaturalDark-toUnitNaturalDarkOppose
        set fromUnitNaturalWood = fromUnitNaturalWood-toUnitNaturalWoodOppose
        set fromUnitNaturalThunder = fromUnitNaturalThunder-toUnitNaturalThunderOppose
        set fromUnitNaturalPoison = fromUnitNaturalPoison-toUnitNaturalPoisonOppose
        if(fromUnitNaturalFire < -100)then
            set fromUnitNaturalFire = -100
        endif
        if(fromUnitNaturalSoil < -100)then
            set fromUnitNaturalSoil = -100
        endif
        if(fromUnitNaturalWater < -100)then
            set fromUnitNaturalWater = -100
        endif
        if(fromUnitNaturalIce < -100)then
            set fromUnitNaturalIce = -100
        endif
        if(fromUnitNaturalWind < -100)then
            set fromUnitNaturalWind = -100
        endif
        if(fromUnitNaturalLight < -100)then
            set fromUnitNaturalLight = -100
        endif
        if(fromUnitNaturalDark < -100)then
            set fromUnitNaturalDark = -100
        endif
        if(fromUnitNaturalWood < -100)then
            set fromUnitNaturalWood = -100
        endif
        if(fromUnitNaturalThunder < -100)then
            set fromUnitNaturalThunder = -100
        endif
            if(fromUnitNaturalPoison < -100)then
            set fromUnitNaturalPoison = -100
        endif
        if( hmath.strpos(bean.huntType,"fire")!=-1 and fromUnitNaturalFire!=0 )then
            set realDamage = realDamage * (1.0+fromUnitNaturalFire*0.01)
            set fromUnitHuntEffectFireVal = fromUnitHuntEffectFireVal * (1.0+fromUnitNaturalFire*0.01)
            //set fromUnitHuntEffectBombVal = fromUnitHuntEffectBombVal * (1.0+fromUnitNaturalFire*0.01)
            set realDamageString = realDamageString+"火"
            set realDamageStringColor = "f45454"
        endif
        if( hmath.strpos(bean.huntType,"soil")!=-1 and fromUnitNaturalSoil!=0 )then
            set realDamage = realDamage * (1.0+fromUnitNaturalSoil*0.01)
            set fromUnitHuntEffectDirtVal = fromUnitHuntEffectDirtVal * (1.0+fromUnitNaturalSoil*0.01)
            set fromUnitHuntEffectHeavyVal = fromUnitHuntEffectHeavyVal * (1.0+fromUnitNaturalSoil*0.01)
            set realDamageString = realDamageString+"土"
            set realDamageStringColor = "dbb745"
        endif
        if( hmath.strpos(bean.huntType,"water")!=-1 and fromUnitNaturalWater!=0 )then
            set realDamage = realDamage * (1.0+fromUnitNaturalWater*0.01)
            set fromUnitHuntEffectFreezeDuring = fromUnitHuntEffectFreezeDuring * (1.0+fromUnitNaturalWater*0.01)
            set fromUnitHuntEffectColdDuring = fromUnitHuntEffectColdDuring * (1.0+fromUnitNaturalWater*0.01)
            set realDamageString = realDamageString+"水"
            set realDamageStringColor = "85adee"
        endif
        if( hmath.strpos(bean.huntType,"ice")!=-1 and fromUnitNaturalIce!=0 )then
            set realDamage = realDamage * (1.0+fromUnitNaturalIce*0.01)
            set fromUnitHuntEffectFreezeVal = fromUnitHuntEffectFreezeVal * (1.0+fromUnitNaturalIce*0.01)
            set fromUnitHuntEffectColdVal = fromUnitHuntEffectColdVal * (1.0+fromUnitNaturalIce*0.01)
            set realDamageString = realDamageString+"冰"
            set realDamageStringColor = "85f4f4"
        endif
        if( hmath.strpos(bean.huntType,"wind")!=-1 and fromUnitNaturalWind!=0 )then
            set realDamage = realDamage * (1.0+fromUnitNaturalWind*0.01)
            set fromUnitHuntEffectCrackFlyVal = fromUnitHuntEffectCrackFlyVal * (1.0+fromUnitNaturalWind*0.01)
            set fromUnitHuntEffectSwimDuring = fromUnitHuntEffectSwimDuring * (1.0+fromUnitNaturalWind*0.01)
            set realDamageString = realDamageString+"风"
            set realDamageStringColor = "b6d7a8"
        endif
        if( hmath.strpos(bean.huntType,"light")!=-1 and fromUnitNaturalLight!=0 )then
            set realDamage = realDamage * (1.0+fromUnitNaturalLight*0.01)
            set fromUnitHuntEffectBlindDuring = fromUnitHuntEffectBlindDuring * (1.0+fromUnitNaturalLight*0.01)
            set realDamageString = realDamageString+"光"
            set realDamageStringColor = "f9f99c"
        endif
        if( hmath.strpos(bean.huntType,"dark")!=-1 and fromUnitNaturalDark!=0 )then
            set realDamage = realDamage * (1.0+fromUnitNaturalDark*0.01)
            set fromUnitHuntEffectCorrosionDuring = fromUnitHuntEffectCorrosionDuring * (1.0+fromUnitNaturalDark*0.01)
            set fromUnitHuntEffectChaosDuring = fromUnitHuntEffectChaosDuring * (1.0+fromUnitNaturalDark*0.01)
            set realDamageString = realDamageString+"暗"
            set realDamageStringColor = "383434"
        endif
        if( hmath.strpos(bean.huntType,"wood")!=-1 and fromUnitNaturalWood!=0 )then
            set realDamage = realDamage * (1.0+fromUnitNaturalWood*0.01)
            set fromUnitHuntEffectTwineDuring = fromUnitHuntEffectTwineDuring * (1.0+fromUnitNaturalWood*0.01)
            set realDamageString = realDamageString+"木"
            set realDamageStringColor = "7cbd60"
        endif
        if( hmath.strpos(bean.huntType,"thunder")!=-1 and fromUnitNaturalThunder!=0 )then
            set realDamage = realDamage * (1.0+fromUnitNaturalThunder*0.01)
            set fromUnitHuntEffectLightningChainVal = fromUnitHuntEffectLightningChainVal * (1.0+fromUnitNaturalThunder*0.01)
            set realDamageString = realDamageString+"雷"
            set realDamageStringColor = "7cbd60"
        endif
        if( hmath.strpos(bean.huntType,"poison")!=-1 and fromUnitNaturalPoison!=0 )then
            set realDamage = realDamage * (1.0+fromUnitNaturalPoison*0.01)
            set fromUnitHuntEffectPoisonVal = fromUnitHuntEffectPoisonVal * (1.0+fromUnitNaturalPoison*0.01)
            set fromUnitHuntEffectWeakDuring = fromUnitHuntEffectWeakDuring * (1.0+fromUnitNaturalPoison*0.01)
            set realDamageString = realDamageString+"毒"
            set realDamageStringColor = "45f7f7"
        endif

        //计算物理暴击,满30000
        if( hmath.strpos(bean.huntType,"physical")!=-1 and (fromUnitKnocking-toUnitMortalOppose)>0 and GetRandomInt(1, 1000)<=R2I((fromUnitKnocking-toUnitMortalOppose)/30) ) then
            set realDamage = realDamage * (1+fromUnitAttackPhysicalPercent * (fromUnitKnocking-toUnitMortalOppose)*0.0004)
            set toUnitAvoid = toUnitAvoid * 0.9//触发暴击，回避减少10%
            set isKnocking = true
            //@触发物理暴击事件
            set hevtBean = hEvtBean.create()
            set hevtBean.triggerKey = "knocking"
            set hevtBean.triggerUnit = fromUnit
            set hevtBean.targetUnit = toUnit
            set hevtBean.damage = realDamage
            set hevtBean.value = fromUnitKnocking/300
            set hevtBean.value2 = fromUnitKnocking*0.05
            call hevt.triggerEvent(hevtBean)
            call hevtBean.destroy()
            //@触发被物理暴击事件
            set hevtBean = hEvtBean.create()
            set hevtBean.triggerKey = "beKnocking"
            set hevtBean.triggerUnit = toUnit
            set hevtBean.sourceUnit = fromUnit
            set hevtBean.damage = realDamage
            set hevtBean.value = fromUnitKnocking/300
            set hevtBean.value2 = fromUnitKnocking*0.05
            call hevt.triggerEvent(hevtBean)
            call hevtBean.destroy()
        endif

        //计算魔法暴击,满20000
        if( hmath.strpos(bean.huntType,"magic")!=-1 and (fromUnitViolence-toUnitMortalOppose)>0 and GetRandomInt(1, 1000)<=R2I((fromUnitViolence-toUnitMortalOppose)/20)) then
            set realDamage = realDamage * (1+fromUnitAttackMagicPercent * (fromUnitViolence-toUnitMortalOppose)*0.0002)
            set toUnitAvoid = toUnitAvoid * 0.9//触发暴击，回避减少10%
            set isViolence = true
            //@触发魔法暴击事件
            set hevtBean = hEvtBean.create()
            set hevtBean.triggerKey = "violence"
            set hevtBean.triggerUnit = fromUnit
            set hevtBean.targetUnit = toUnit
            set hevtBean.damage = realDamage
            set hevtBean.value = fromUnitKnocking/200
            set hevtBean.value2 = fromUnitKnocking*0.03
            call hevt.triggerEvent(hevtBean)
            call hevtBean.destroy()
            //@触发被魔法暴击事件
            set hevtBean = hEvtBean.create()
            set hevtBean.triggerKey = "beViolence"
            set hevtBean.triggerUnit = toUnit
            set hevtBean.sourceUnit = fromUnit
            set hevtBean.damage = realDamage
            set hevtBean.value = fromUnitKnocking/200
            set hevtBean.value2 = fromUnitKnocking*0.03
            call hevt.triggerEvent(hevtBean)
            call hevtBean.destroy()
        endif
            //如果遇到真实伤害，减少50%的回避效果
        if( hmath.strpos(bean.huntType,"real")!=-1 )then
            set toUnitAvoid = toUnitAvoid * 0.8
        endif
        //如果遇到绝对伤害，减少50%的回避效果
        if( hmath.strpos(bean.huntType,"absolute")!=-1 )then
            set toUnitAvoid = toUnitAvoid * 0.5
        endif
        //计算回避 X 命中
        if( bean.huntKind == "attack" and realDamage<(hunit.getMaxLife(toUnit)*0.25) and R2I(toUnitAvoid-fromUnitAim)>0 and GetRandomInt(1, 100)<=R2I(toUnitAvoid-fromUnitAim))then
            set isAvoid = true
            set realDamage = 0
            call hmsg.style(  hmsg.ttg2Unit(toUnit,"回避",6.00,"5ef78e",10,1.00,10.00)  ,"scale",0,0.2)
            //@触发回避事件
            set hevtBean = hEvtBean.create()
            set hevtBean.triggerKey = "avoid"
            set hevtBean.triggerUnit = toUnit
            set hevtBean.attacker = fromUnit
            call hevt.triggerEvent(hevtBean)
            call hevtBean.destroy()
            //@触发被回避事件
            set hevtBean = hEvtBean.create()
            set hevtBean.triggerKey = "beAvoid"
            set hevtBean.triggerUnit = fromUnit
            set hevtBean.attacker = fromUnit
            set hevtBean.targetUnit = toUnit
            call hevt.triggerEvent(hevtBean)
            call hevtBean.destroy()
            return
        endif

        //计算混合了物理的杂乱伤害，护甲效果减弱
        if( bean.huntType!="physical" and hmath.strpos(bean.huntType,"physical")!=-1 and toUnitDefend>0 )then
            set toUnitDefend = toUnitDefend * fromUnitAttackPhysicalPercent
        endif
        //计算护甲
        if( hmath.strpos(bean.huntType,"physical")!=-1 and toUnitDefend!=0 )then
            if(toUnitDefend>0)then
                set realDamage = realDamage * (1-toUnitDefend/(toUnitDefend+200))
            else
                set tempReal = 1+I2R(R2I(RAbsBJ(toUnitDefend)+149)/100)
                set realDamage = realDamage * (tempReal-Pow(0.99, RAbsBJ(toUnitDefend)-(tempReal-2)*100))
            endif
        endif
        //计算混合了魔法的杂乱伤害，魔抗效果减弱
        if( bean.huntType!="magic" and hmath.strpos(bean.huntType,"magic")!=-1 and toUnitResistance>0 )then
            set toUnitResistance = toUnitResistance * fromUnitAttackMagicPercent
        endif
        //计算魔抗
        if( hmath.strpos(bean.huntType,"magic")!=-1 )then
            if( toUnitResistance!=0 )then
                if(toUnitResistance>=100)then
                    set realDamage = 0
                    call hunit.subLife(fromUnit,realDamage*(toUnitResistance-100)*0.01)
                else
                    set realDamage = realDamage * (1-toUnitResistance*0.01)
                endif
            endif
        endif
        //计算韧性
        if( toUnitToughness>0 )then
            if( (realDamage-toUnitToughness) < realDamage*0.1 )then
                set realDamage = realDamage * 0.1
            else
                set realDamage = realDamage - toUnitToughness
            endif
        endif
        //计算单位是否无敌且伤害类型不混合绝对伤害（无敌属性为百分比计算，被动触发抵挡一次）
        if( hmath.strpos(bean.huntType,"absolute")==-1 and (his.invincible(toUnit)==true or GetRandomInt(1,100)<R2I(toUnitInvincible)  ))then
            set realDamage = 0
            return
        endif

        //造成伤害
        //call console.info("realDamage:"+R2S(realDamage))
        if( realDamage > 0 ) then

            //暴击文本加持
            if(isKnocking and isViolence)then
                set realDamageString = realDamageString+"双暴击"
                    set realDamageStringColor = "b054ee"
            elseif(isKnocking)then
                set realDamageString = realDamageString+"暴击"
                set realDamageStringColor = "ef3215"
            elseif(isViolence)then
                set realDamageString = realDamageString+"暴击"
                set realDamageStringColor = "15bcef"
            endif
            //文本显示
            call hmsg.style(  hmsg.ttg2Unit(toUnit,realDamageString+I2S(R2I(realDamage)),6.00,realDamageStringColor,10,1.1,11.00)  ,"toggle",0,0.25)

            call hevt.setLastDamageUnit(toUnit,fromUnit)
            call hplayer.addDamage(GetOwningPlayer(fromUnit),realDamage)
            call hplayer.addBeDamage(GetOwningPlayer(toUnit),realDamage)
            call hunit.subLife(toUnit,realDamage) //#

            if(bean.isNoAvoid==true)then
                //@触发造成无法回避伤害事件
                set hevtBean = hEvtBean.create()
                set hevtBean.triggerKey = "noAvoid"
                set hevtBean.triggerUnit = fromUnit
                set hevtBean.targetUnit = toUnit
                set hevtBean.damage = realDamage
                call hevt.triggerEvent(hevtBean)
                call hevtBean.destroy()
                //@触发被无法回避伤害事件
                set hevtBean = hEvtBean.create()
                set hevtBean.triggerKey = "beNoAvoid"
                set hevtBean.triggerUnit = toUnit
                set hevtBean.sourceUnit = fromUnit
                set hevtBean.damage = realDamage
                call hevt.triggerEvent(hevtBean)
                call hevtBean.destroy()
            endif

            //@触发伤害事件
            set hevtBean = hEvtBean.create()
            set hevtBean.triggerKey = "damage"
            set hevtBean.triggerUnit = fromUnit
            set hevtBean.targetUnit = toUnit
            set hevtBean.sourceUnit = fromUnit
            set hevtBean.damage = bean.damage
            set hevtBean.realDamage = realDamage
            set hevtBean.damageKind = bean.huntKind
            set hevtBean.damageType = bean.huntType
            call hevt.triggerEvent(hevtBean)
            call hevtBean.destroy()
            //@触发被伤害事件
            set hevtBean = hEvtBean.create()
            set hevtBean.triggerKey = "beDamage"
            set hevtBean.triggerUnit = toUnit
            set hevtBean.sourceUnit = fromUnit
            set hevtBean.damage = bean.damage
            set hevtBean.realDamage = realDamage
            set hevtBean.damageKind = bean.huntKind
            set hevtBean.damageType = bean.huntType
            call hevt.triggerEvent(hevtBean)
            call hevtBean.destroy()
            
            //分裂
            if( bean.huntKind == "attack" and fromUnitSplit >0 )then
                set loc = GetUnitLoc( toUnit )
                set filter = hFilter.create()
                call filter.setUnit(fromUnit)
                call filter.isAlive(true)
                call filter.isEnemy(true)
                call filter.isBuilding(false)
                set g = hgroup.createByLoc(loc,fromUnitSplitRange,function hFilter.get )
                call filter.destroy()
                call heffect.toLoc("Abilities\\Spells\\Human\\Feedback\\SpellBreakerAttack.mdl",loc,0)
                call RemoveLocation( loc )
                loop
                    exitwhen(IsUnitGroupEmptyBJ(g) == true)
                        set u = FirstOfGroup(g)
                        call GroupRemoveUnit( g , u )
                        if(u!=toUnit and IsUnitEnemy(u,GetOwningPlayer(fromUnit)) == true) then
                            set huntBean = hAttrHuntBean.create()
                            set huntBean.fromUnit = fromUnit
                            set huntBean.toUnit = u
                            set huntBean.damage = realDamage * fromUnitSplit * 0.01
                            set huntBean.huntKind = "special"
                            set huntBean.huntType = "physical"
                            set huntBean.isBreak = "defend"
                            call thistype.huntUnit(huntBean)
                            call heffect.toUnitLoc("Abilities\\Spells\\Other\\Cleave\\CleaveDamageTarget.mdl",u,0)
                            call huntBean.destroy()
                        endif
                endloop
                call GroupClear(g)
                call DestroyGroup(g)
                set g = null

                //@触发分裂事件
                set hevtBean = hEvtBean.create()
                set hevtBean.triggerKey = "spilt"
                set hevtBean.triggerUnit = fromUnit
                set hevtBean.targetUnit = toUnit
                set hevtBean.damage = realDamage * fromUnitSplit * 0.01
                set hevtBean.range = fromUnitSplitRange
                set hevtBean.value = fromUnitSplit
                call hevt.triggerEvent(hevtBean)
                call hevtBean.destroy()
                //@触发被分裂事件
                set hevtBean = hEvtBean.create()
                set hevtBean.triggerKey = "beSpilt"
                set hevtBean.triggerUnit = toUnit
                set hevtBean.sourceUnit = fromUnit
                set hevtBean.damage = realDamage * fromUnitSplit * 0.01
                set hevtBean.range = fromUnitSplitRange
                set hevtBean.value = fromUnitSplit
                call hevt.triggerEvent(hevtBean)
                call hevtBean.destroy()
            endif
            //吸血
            if( bean.huntKind == "attack" and fromUnitHemophagia >0 )then
                call hunit.addLife(fromUnit,realDamage * fromUnitHemophagia * 0.01)
                call heffect.toUnit("Abilities\\Spells\\Undead\\VampiricAura\\VampiricAuraTarget.mdl",fromUnit,"origin",1.00)
                //@触发吸血事件
                set hevtBean = hEvtBean.create()
                set hevtBean.triggerKey = "hemophagia"
                set hevtBean.triggerUnit = fromUnit
                set hevtBean.targetUnit = toUnit
                set hevtBean.damage = realDamage * fromUnitHemophagia * 0.01
                set hevtBean.value = fromUnitHemophagia
                call hevt.triggerEvent(hevtBean)
                call hevtBean.destroy()
                //@触发被吸血事件
                set hevtBean = hEvtBean.create()
                set hevtBean.triggerKey = "beHemophagia"
                set hevtBean.triggerUnit = toUnit
                set hevtBean.sourceUnit = fromUnit
                set hevtBean.damage = realDamage * fromUnitHemophagia * 0.01
                set hevtBean.value = fromUnitHemophagia
                call hevt.triggerEvent(hevtBean)
                call hevtBean.destroy()
            endif
            //技能吸血
            if( bean.huntKind == "skill" and fromUnitHemophagiaSkill >0 )then
                call hunit.addLife(fromUnit,realDamage * fromUnitHemophagiaSkill * 0.01)
                call heffect.toUnit("Abilities\\Spells\\Items\\HealingSalve\\HealingSalveTarget.mdl",fromUnit,"weapon",1.8)
                //@触发技能吸血事件
                set hevtBean = hEvtBean.create()
                set hevtBean.triggerKey = "skillHemophagia"
                set hevtBean.triggerUnit = fromUnit
                set hevtBean.targetUnit = toUnit
                set hevtBean.damage = realDamage * fromUnitHemophagiaSkill * 0.01
                set hevtBean.value = fromUnitHemophagiaSkill
                call hevt.triggerEvent(hevtBean)
                call hevtBean.destroy()
                //@触发被技能吸血事件
                set hevtBean = hEvtBean.create()
                set hevtBean.triggerKey = "beSkillHemophagia"
                set hevtBean.triggerUnit = toUnit
                set hevtBean.sourceUnit = fromUnit
                set hevtBean.damage = realDamage * fromUnitHemophagiaSkill * 0.01
                set hevtBean.value = fromUnitHemophagiaSkill
                call hevt.triggerEvent(hevtBean)
                call hevtBean.destroy()
            endif
            //硬直
            if( his.alive(toUnit) )then
                if( isEffect == true and fromUnitHuntEffectHeavyVal > 100 and GetRandomReal(1,100) <= fromUnitHuntEffectHeavyOdds ) then
                    set fromUnitPunishHeavy = fromUnitPunishHeavy * (fromUnitHuntEffectHeavyVal* 0.01)
                endif
                call hattr.subPunishCurrent(toUnit,realDamage*fromUnitPunishHeavy,0)

                if(hattr.getPunishCurrent(toUnit) <= 0 ) then
                    call hattr.setPunishCurrent(toUnit,hattr.getPunish(toUnit),0)
                    set punishEffect = hattr.getAttackSpeed(toUnit)*punishEffectRatio
                    if(punishEffect<1)then
                        set punishEffect = 1.00
                    endif
                    call hattr.subAttackSpeed( toUnit , punishEffect , 5.00 )
                    set punishEffect = hattr.getMove(toUnit)*punishEffectRatio
                    if(punishEffect<1)then
                        set punishEffect = 1.00
                    endif
                    call hattr.subMove( toUnit , punishEffect , 5.00 )
                    call hmsg.style(hmsg.ttg2Unit(toUnit,"僵硬",6.00,"c0c0c0",0,2.50,50.00)  ,"scale",0,0.05)

                    //@触发硬直事件
                    set hevtBean = hEvtBean.create()
                    set hevtBean.triggerKey = "punish"
                    set hevtBean.triggerUnit = toUnit
                    set hevtBean.sourceUnit = fromUnit
                    set hevtBean.value = punishEffect
                    set hevtBean.during = 5.00
                    call hevt.triggerEvent(hevtBean)
                    call hevtBean.destroy()

                endif
            endif
            //反射
            if( toUnitHuntRebound >0 )then
                call hunit.subLife(fromUnit,realDamage * toUnitHuntRebound * 0.01)
                call hmsg.style(hmsg.ttg2Unit(fromUnit,"反射"+I2S(R2I(realDamage*toUnitHuntRebound*0.01)),10.00,"f8aaeb",10,1.00,10.00)  ,"shrink",0,0.2)
                //@触发反伤事件
                set hevtBean = hEvtBean.create()
                set hevtBean.triggerKey = "rebound"
                set hevtBean.triggerUnit = toUnit
                set hevtBean.sourceUnit = fromUnit
                set hevtBean.damage = realDamage * toUnitHuntRebound * 0.01
                call hevt.triggerEvent(hevtBean)
                call hevtBean.destroy()
            endif
            //治疗
            if( toUnitCure >0 )then
                call hunit.addLife(toUnit,realDamage * toUnitCure * 0.01)
                call heffect.toUnit("Abilities\\Spells\\Undead\\VampiricAura\\VampiricAuraTarget.mdl",toUnit,"origin",1.00)
                set loc = GetUnitLoc( toUnit )
                call hmsg.style(hmsg.ttg2Loc(loc,"治疗"+I2S(R2I(realDamage*toUnitCure*0.01)),10.00,"f5f89b",10,1.00,10.00)  ,"shrink",0,0.2)
                call RemoveLocation( loc )
            endif
        endif

        //特殊效果,需要非无敌并处于效果启动状态下
        if( isEffect == true )then

if( fromUnitHuntEffectLifeBackVal>0 and fromUnitHuntEffectLifeBackDuring>0 ) then
    call hattr.addLifeBack(fromUnit,fromUnitHuntEffectLifeBackVal,fromUnitHuntEffectLifeBackDuring)
endif
if( fromUnitHuntEffectManaBackVal>0 and fromUnitHuntEffectManaBackDuring>0 ) then
    call hattr.addManaBack(fromUnit,fromUnitHuntEffectManaBackVal,fromUnitHuntEffectManaBackDuring)
endif
if( fromUnitHuntEffectAttackSpeedVal>0 and fromUnitHuntEffectAttackSpeedDuring>0 ) then
    call hattr.addAttackSpeed(fromUnit,fromUnitHuntEffectAttackSpeedVal,fromUnitHuntEffectAttackSpeedDuring)
endif
if( fromUnitHuntEffectAttackPhysicalVal>0 and fromUnitHuntEffectAttackPhysicalDuring>0 ) then
    call hattr.addAttackPhysical(fromUnit,fromUnitHuntEffectAttackPhysicalVal,fromUnitHuntEffectAttackPhysicalDuring)
endif
if( fromUnitHuntEffectAttackMagicVal>0 and fromUnitHuntEffectAttackMagicDuring>0 ) then
    call hattr.addAttackMagic(fromUnit,fromUnitHuntEffectAttackMagicVal,fromUnitHuntEffectAttackMagicDuring)
endif
if( fromUnitHuntEffectMoveVal>0 and fromUnitHuntEffectMoveDuring>0 ) then
    call hattr.addMove(fromUnit,fromUnitHuntEffectMoveVal,fromUnitHuntEffectMoveDuring)
endif
if( fromUnitHuntEffectAimVal>0 and fromUnitHuntEffectAimDuring>0 ) then
    call hattr.addAim(fromUnit,fromUnitHuntEffectAimVal,fromUnitHuntEffectAimDuring)
endif
if( fromUnitHuntEffectStrVal>0 and fromUnitHuntEffectStrDuring>0 ) then
    call hattr.addStr(fromUnit,fromUnitHuntEffectStrVal,fromUnitHuntEffectStrDuring)
endif
if( fromUnitHuntEffectAgiVal>0 and fromUnitHuntEffectAgiDuring>0 ) then
    call hattr.addAgi(fromUnit,fromUnitHuntEffectAgiVal,fromUnitHuntEffectAgiDuring)
endif
if( fromUnitHuntEffectIntVal>0 and fromUnitHuntEffectIntDuring>0 ) then
    call hattr.addInt(fromUnit,fromUnitHuntEffectIntVal,fromUnitHuntEffectIntDuring)
endif
if( fromUnitHuntEffectKnockingVal>0 and fromUnitHuntEffectKnockingDuring>0 ) then
    call hattr.addKnocking(fromUnit,fromUnitHuntEffectKnockingVal,fromUnitHuntEffectKnockingDuring)
endif
if( fromUnitHuntEffectViolenceVal>0 and fromUnitHuntEffectViolenceDuring>0 ) then
    call hattr.addViolence(fromUnit,fromUnitHuntEffectViolenceVal,fromUnitHuntEffectViolenceDuring)
endif
if( fromUnitHuntEffectHemophagiaVal>0 and fromUnitHuntEffectHemophagiaDuring>0 ) then
    call hattr.addHemophagia(fromUnit,fromUnitHuntEffectHemophagiaVal,fromUnitHuntEffectHemophagiaDuring)
endif
if( fromUnitHuntEffectHemophagiaSkillVal>0 and fromUnitHuntEffectHemophagiaSkillDuring>0 ) then
    call hattr.addHemophagiaSkill(fromUnit,fromUnitHuntEffectHemophagiaSkillVal,fromUnitHuntEffectHemophagiaSkillDuring)
endif
if( fromUnitHuntEffectSplitVal>0 and fromUnitHuntEffectSplitDuring>0 ) then
    call hattr.addSplit(fromUnit,fromUnitHuntEffectSplitVal,fromUnitHuntEffectSplitDuring)
endif
if( fromUnitHuntEffectLuckVal>0 and fromUnitHuntEffectLuckDuring>0 ) then
    call hattr.addLuck(fromUnit,fromUnitHuntEffectLuckVal,fromUnitHuntEffectLuckDuring)
endif
if( fromUnitHuntEffectHuntAmplitudeVal>0 and fromUnitHuntEffectHuntAmplitudeDuring>0 ) then
    call hattr.addHuntAmplitude(fromUnit,fromUnitHuntEffectHuntAmplitudeVal,fromUnitHuntEffectHuntAmplitudeDuring)
endif

            if( fromUnitHuntEffectPoisonVal>0 and fromUnitHuntEffectPoisonDuring>0 ) then
                call hattr.subLifeBack(toUnit,fromUnitHuntEffectPoisonVal,fromUnitHuntEffectPoisonDuring)
                call heffect.toUnit("Abilities\\Spells\\Other\\AcidBomb\\BottleImpact.mdl",toUnit,"origin",fromUnitHuntEffectPoisonDuring)
            endif
            if( fromUnitHuntEffectFireVal>0 and fromUnitHuntEffectFireDuring>0 ) then
                call hattr.subLifeBack(toUnit,fromUnitHuntEffectFireVal,fromUnitHuntEffectFireDuring)
                call heffect.toUnit("Abilities\\Spells\\Other\\ImmolationRed\\ImmolationRedDamage.mdl",toUnit,"origin",fromUnitHuntEffectFireDuring)
            endif
            if( fromUnitHuntEffectDryVal>0 and fromUnitHuntEffectDryDuring>0 ) then
                call hattr.subManaBack(toUnit,fromUnitHuntEffectDryVal,fromUnitHuntEffectDryDuring)
                call heffect.toUnit("Abilities\\Spells\\Other\\Drain\\ManaDrainCaster.mdl",toUnit,"foot",fromUnitHuntEffectDryDuring)
            endif
            if( fromUnitHuntEffectFreezeVal>0 and fromUnitHuntEffectFreezeDuring>0 ) then
                call hattr.subAttackSpeed(toUnit,fromUnitHuntEffectFreezeVal,fromUnitHuntEffectFreezeDuring)
                call heffect.toUnit("Abilities\\Spells\\Other\\FrostDamage\\FrostDamage.mdl",toUnit,"foot",fromUnitHuntEffectFreezeDuring)
            endif
            if( fromUnitHuntEffectColdVal>0 and fromUnitHuntEffectColdDuring>0 ) then
                call hattr.subMove(toUnit,fromUnitHuntEffectColdVal,fromUnitHuntEffectColdDuring)
                call heffect.toUnit("Abilities\\Spells\\Other\\FrostDamage\\FrostDamage.mdl",toUnit,"origin",fromUnitHuntEffectColdDuring)
            endif
            if( fromUnitHuntEffectBluntVal>0 and fromUnitHuntEffectBluntDuring>0 ) then
                call hattr.subAttackPhysical(toUnit,fromUnitHuntEffectBluntVal,fromUnitHuntEffectBluntDuring)
                call heffect.toUnit("Abilities\\Spells\\NightElf\\Barkskin\\BarkSkinTarget.mdl",toUnit,"origin",fromUnitHuntEffectBluntDuring)
            endif
            if( fromUnitHuntEffectMuggleVal>0 and fromUnitHuntEffectMuggleDuring>0 ) then
                call hattr.subAttackMagic(toUnit,fromUnitHuntEffectMuggleVal,fromUnitHuntEffectMuggleDuring)
                call heffect.toUnit("Abilities\\Spells\\Undead\\Cripple\\CrippleTarget.mdl",toUnit,"origin",fromUnitHuntEffectMuggleDuring)
            endif
            if( fromUnitHuntEffectCorrosionVal>0 and fromUnitHuntEffectCorrosionDuring>0 ) then
                call hattr.subDefend(toUnit,fromUnitHuntEffectCorrosionVal,fromUnitHuntEffectCorrosionDuring)
                call heffect.toUnit("Abilities\\Spells\\Undead\\DeathandDecay\\DeathandDecayTarget.mdl",toUnit,"origin",fromUnitHuntEffectCorrosionDuring)
            endif
            if( fromUnitHuntEffectChaosVal>0 and fromUnitHuntEffectChaosDuring>0 ) then
                call hattr.subResistance(toUnit,fromUnitHuntEffectChaosVal,fromUnitHuntEffectChaosDuring)
                call heffect.toUnit("Abilities\\Spells\\Other\\AcidBomb\\BottleImpact.mdl",toUnit,"origin",fromUnitHuntEffectChaosDuring)
            endif
            if( fromUnitHuntEffectTwineVal>0 and fromUnitHuntEffectTwineDuring>0 ) then
                call hattr.subAvoid(toUnit,fromUnitHuntEffectTwineVal,fromUnitHuntEffectTwineDuring)
                call heffect.toUnit("Abilities\\Spells\\NightElf\\EntanglingRoots\\EntanglingRootsTarget.mdl",toUnit,"origin",fromUnitHuntEffectTwineDuring)
            endif
            if( fromUnitHuntEffectBlindVal>0 and fromUnitHuntEffectBlindDuring>0 ) then
                call hattr.subAim(toUnit,fromUnitHuntEffectBlindVal,fromUnitHuntEffectBlindDuring)
                call heffect.toUnit("Abilities\\Spells\\Human\\ManaFlare\\ManaFlareBoltImpact.mdl",toUnit,"origin",fromUnitHuntEffectBlindDuring)
            endif
            if( fromUnitHuntEffectTortuaVal>0 and fromUnitHuntEffectTortuaDuring>0 ) then
                call hattr.subToughness(toUnit,fromUnitHuntEffectTortuaVal,fromUnitHuntEffectTortuaDuring)
                call heffect.toUnit("Abilities\\Spells\\Other\\Incinerate\\IncinerateBuff.mdl",toUnit,"origin",fromUnitHuntEffectTortuaDuring)
            endif
            if( fromUnitHuntEffectWeakVal>0 and fromUnitHuntEffectWeakDuring>0 ) then
                call hattr.subStr(toUnit,fromUnitHuntEffectWeakVal,fromUnitHuntEffectWeakDuring)
                call heffect.toUnit("Units\\Undead\\PlagueCloud\\PlagueCloudtarget.mdl",toUnit,"head",fromUnitHuntEffectWeakDuring)
            endif
            if( fromUnitHuntEffectAstrictVal>0 and fromUnitHuntEffectAstrictDuring>0 ) then
                call hattr.subAgi(toUnit,fromUnitHuntEffectAstrictVal,fromUnitHuntEffectAstrictDuring)
                call heffect.toUnit("Abilities\\Spells\\Undead\\Sleep\\SleepSpecialArt.mdl",toUnit,"origin",fromUnitHuntEffectAstrictDuring)
            endif
            if( fromUnitHuntEffectFoolishVal>0 and fromUnitHuntEffectFoolishDuring>0 ) then
                call hattr.subInt(toUnit,fromUnitHuntEffectFoolishVal,fromUnitHuntEffectFoolishDuring)
                call heffect.toUnit("Abilities\\Spells\\Undead\\Sleep\\SleepTarget.mdl",toUnit,"head",fromUnitHuntEffectFoolishDuring)
            endif
            if( fromUnitHuntEffectDullVal>0 and fromUnitHuntEffectDullDuring>0 ) then
                call hattr.subKnocking(toUnit,fromUnitHuntEffectDullVal,fromUnitHuntEffectDullDuring)
                call heffect.toUnit("Abilities\\Spells\\NightElf\\Barkskin\\BarkSkinTarget.mdl",toUnit,"weapon",fromUnitHuntEffectDullDuring)
            endif
            if( fromUnitHuntEffectDirtVal>0 and fromUnitHuntEffectDirtDuring>0 ) then
                call hattr.subViolence(toUnit,fromUnitHuntEffectDirtVal,fromUnitHuntEffectDirtDuring)
                call heffect.toUnit("Abilities\\Spells\\Items\\OrbCorruption\\OrbCorruptionSpecialArt.mdl",toUnit,"weapon",fromUnitHuntEffectDirtDuring)
            endif
            if( fromUnitHuntEffectSwimOdds>0 and fromUnitHuntEffectSwimDuring>0 ) then
                if(toUnitSwimOppose!=0)then
                    set fromUnitHuntEffectSwimOdds = fromUnitHuntEffectSwimOdds - toUnitSwimOppose
                    set fromUnitHuntEffectSwimDuring = fromUnitHuntEffectSwimDuring * (1-toUnitSwimOppose*0.01)
                endif
                if(fromUnitHuntEffectSwimOdds>=1)then
                    //@触发眩晕事件
                    set hevtBean = hEvtBean.create()
                    set hevtBean.triggerKey = "swim"
                    set hevtBean.triggerUnit = fromUnit
                    set hevtBean.targetUnit = toUnit
                    set hevtBean.value = fromUnitHuntEffectSwimOdds
                    set hevtBean.during = fromUnitHuntEffectSwimDuring
                    call hevt.triggerEvent(hevtBean)
                    call hevtBean.destroy()
                    //@触发被眩晕事件
                    set hevtBean = hEvtBean.create()
                    set hevtBean.triggerKey = "beSwim"
                    set hevtBean.triggerUnit = toUnit
                    set hevtBean.sourceUnit = fromUnit
                    set hevtBean.value = fromUnitHuntEffectSwimOdds
                    set hevtBean.during = fromUnitHuntEffectSwimDuring
                    call hevt.triggerEvent(hevtBean)
                    call hevtBean.destroy()
                    if(GetRandomReal(1,100)<=fromUnitHuntEffectSwimOdds and fromUnitHuntEffectSwimDuring>0)then
                        call hability.swim( toUnit , fromUnitHuntEffectSwimDuring )
                    endif
                endif
            endif
            if( GetRandomReal(1,100)<=fromUnitHuntEffectBreakOdds and fromUnitHuntEffectBreakDuring>0 ) then
                set punishEffect = hattr.getAttackSpeed(toUnit)*punishEffectRatio
                if(punishEffect<1)then
                    set punishEffect = 1.00
                endif
                call hattr.subAttackSpeed( toUnit , punishEffect , 5.00 )
                set punishEffect = hattr.getMove(toUnit)*punishEffectRatio
                if(punishEffect<1)then
                    set punishEffect = 1.00
                endif
                call hattr.subMove( toUnit , punishEffect , 5.00 )
                //@触发硬直事件
                set hevtBean = hEvtBean.create()
                set hevtBean.triggerKey = "punish"
                set hevtBean.triggerUnit = toUnit
                set hevtBean.sourceUnit = fromUnit
                set hevtBean.value = punishEffect
                set hevtBean.during = fromUnitHuntEffectBreakDuring
                call hevt.triggerEvent(hevtBean)
                call hevtBean.destroy()
            endif
            if( fromUnitHuntEffectUnluckVal>0 and fromUnitHuntEffectUnluckDuring>0 ) then
                call hattr.subLuck(toUnit,fromUnitHuntEffectUnluckVal,fromUnitHuntEffectUnluckDuring)
            endif
            if( GetRandomReal(1,100)<=fromUnitHuntEffectSilentOdds and fromUnitHuntEffectSilentDuring>0 ) then
                call hability.silent(toUnit,fromUnitHuntEffectSilentDuring)
            endif
            if( GetRandomReal(1,100)<=fromUnitHuntEffectUnarmOdds and fromUnitHuntEffectUnarmDuring>0 ) then
                call hability.unarm(toUnit,fromUnitHuntEffectUnarmDuring)
            endif
            if( GetRandomReal(1,100)<=fromUnitHuntEffectFetterOdds and fromUnitHuntEffectFetterDuring>0 ) then
                call hattr.subMove(toUnit,1000,fromUnitHuntEffectFetterDuring)
                call heffect.toUnit("Abilities\\Spells\\Orc\\SpiritLink\\SpiritLinkTarget.mdl",toUnit,"origin",fromUnitHuntEffectFetterDuring)
            endif
            if( fromUnitHuntEffectBombVal>0 and fromUnitHuntEffectBombRange>0 ) then
                if(fromUnitHuntEffectBombModel=="")then
                    set fromUnitHuntEffectBombModel = "Abilities\\Spells\\Other\\Incinerate\\FireLordDeathExplode.mdl"
                endif
                call heffect.toUnitLoc(fromUnitHuntEffectBombModel,toUnit,0)
                set filter = hFilter.create()
                call filter.setUnit(fromUnit)
                call filter.isEnemy(true)
                call filter.isBuilding(false)
                set g = hgroup.createByUnit(toUnit,fromUnitHuntEffectBombRange,function hFilter.get)
                call filter.destroy()
                loop
                    exitwhen(IsUnitGroupEmptyBJ(g) == true)
                        set u = FirstOfGroup(g)
                        call GroupRemoveUnit( g , u )
                        if( IsUnitAliveBJ(u) )then
                            set huntBean = hAttrHuntBean.create()
                            set huntBean.fromUnit = fromUnit
                            set huntBean.toUnit = u
                            set huntBean.damage = fromUnitHuntEffectBombVal
                            set huntBean.huntKind = "special"
                            set huntBean.huntType = "physicalfire"
                            call thistype.huntUnit(huntBean)
                            call huntBean.destroy()
                        endif
                        set u = null
                endloop
                call GroupClear( g )
                call DestroyGroup( g )
                set g = null
            endif
            if( GetRandomReal(1,100)<=fromUnitHuntEffectLightningChainOdds and fromUnitHuntEffectLightningChainVal>0 and fromUnitHuntEffectLightningChainQty>0 ) then
                if(fromUnitHuntEffectLightningChainModel=="")then
                    set fromUnitHuntEffectLightningChainModel = "Abilities\\Weapons\\Bolt\\BoltImpact.mdl"
                endif
                
            endif
            if( GetRandomReal(1,100)<=fromUnitHuntEffectCrackFlyOdds and fromUnitHuntEffectCrackFlyVal>0 ) then
                //
            endif
          
        endif

    endmethod

    /**
     * 伤害群
     */
    public static method huntGroup takes hAttrHuntBean bean returns nothing
    	local unit u = null
        local group g = null
    	if( bean.whichGroupHuntEff != null and bean.whichGroupHuntEff != "" and bean.whichGroupHuntEffLoc != null) then
			call heffect.toLoc(bean.whichGroupHuntEff,bean.whichGroupHuntEffLoc,0)
    	endif
        set g = CreateGroup()
        call GroupAddGroup(bean.whichGroup,g)
    	loop
            exitwhen(IsUnitGroupEmptyBJ(g) == true)
                set u = FirstOfGroup(g)
                call GroupRemoveUnit( g , u )
                if(IsUnitEnemy(u,GetOwningPlayer(bean.fromUnit))==true and (bean.whichGroupRepeat==null or IsUnitInGroup(u,bean.whichGroupRepeat)==false)) then
                    set bean.toUnit = u
                    call thistype.huntUnit(bean)
                endif
                if( bean.whichGroupRepeat != null) then
                	call GroupAddUnit( bean.whichGroupRepeat,u )
                endif
            set u = null
        endloop
        call GroupClear(g)
        call DestroyGroup(g)
        set g = null

    endmethod

endstruct
