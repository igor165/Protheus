#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH" //#AGRO NOVO   AGRPMT010INTEG
#INCLUDE "FWADAPTEREAI.CH"

/*/{Protheus.doc} AGRPMT010ACPMD
Gera o array dos dados conforme o recebimento das tags XML dos dados de agronegócio do produto do cadastro de produto via integração MATI010
Estes dados serão usados pela função AGRPMT010GRVMD para gravar os dados na base de dados PROTHEUS
@author  Felipe Raposo | claudineia.reinert
@version P12
@since   21/09/2018 | 25/08/2020
/*/
Function AGRPMT010ACPMD(cVersion, oXml, cMarca, nEvento, cCode)
    Local aErro             := {}
    Local aRet              := {}
    Local aAgroModel		:= {} 
    //Devido ao fluxo padrão ser PROTHEUS para o PIMS, por recomendação será mantido comentado o recebimento do XML
    // quando houver necessidade poderá ser descomentado para uso. Os testes foram realizado somente local PROTHEUS->PROTHEUS ou SOAUPUI->PROTHEUS
    /*
    Local aAgroDados		:= {}     
    Local aAgroReg			:= {} 
    Local aXMLAux			:= {} 
    Local aAux				:= {}
    Local nCount			:= 1    
    Local cCodigo           := ""
    Local lAgro             := VldVersao(cVersion)

    If lAgro
        // Dados do agronegócio.
        aAdd(aAgroModel, {"FORMNCR", {}})
        aAgroDados := aTail(aAgroModel)[2]

        // Dados gerais do produto agronegócio.
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgriculturalCultureInternalId:Text") != "U"         
            If !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgriculturalCultureInternalId:Text)
                aAux := AI800Cod(cMarca, oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgriculturalCultureInternalId:Text)
                If Len(aAux) > 2 .and. !Empty(aAux[3])
                    aAdd(aAgroDados, {"NCR_CULTUR", aAux[3]})
                ElseIf Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgriculturalCultureCode:Text") != "U" 
                    cCodigo := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgriculturalCultureCode:Text
                    NP3->(dbSetOrder( 1 ))
                    If NP3->(dbSeek( FWxFilial("NP3") + cCodigo) ) 
                        aAdd(aAgroDados, {"NCR_CULTUR", cCodigo})
                    Else
                        aadd(aErro,"Valor inválido na Tag AgriculturalCultureInternalId/AgriculturalCultureCode.")
                    EndIf
                Else
                    aadd(aErro,"Valor inválido na Tag AgriculturalCultureInternalId.")
                EndIf
            Else
                aAdd(aAgroDados, {"NCR_CULTUR", ""}) //pode ser alteração limpando campo
            EndIf
            
        EndIf
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgriculturalInputFormulationInternalId:Text") != "U" 
            If !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgriculturalInputFormulationInternalId:Text)
                aAux := AP020Cod(cMarca, oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgriculturalInputFormulationInternalId:Text)
                If Len(aAux) > 2 .and. !Empty(aAux[3])
                    aAdd(aAgroDados, {"NCR_FORM", aAux[3]})
                ElseIf Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgriculturalInputFormulationCode:Text") != "U"
                    cCodigo := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgriculturalInputFormulationCode:Text
                    NCI->(dbSetOrder( 1 ))
                    If NCI->(dbSeek( FWxFilial("NCI") + cCodigo) ) 
                        aAdd(aAgroDados, {"NCR_FORM", cCodigo})
                    Else
                        aadd(aErro,"Valor inválido na Tag AgriculturalInputFormulationInternalId/AgriculturalInputFormulationCode.")
                    EndIf
                Else
                    aadd(aErro,"Valor inválido na Tag AgriculturalInputFormulationInternalId/AgriculturalInputFormulationCode.")
                Endif
            Else
                aAdd(aAgroDados, {"NCR_FORM", ""})
            Endif
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_QuantityInertMaterials:Text") != "U"
            aAdd(aAgroDados, {"NCR_MATINE", val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_QuantityInertMaterials:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ToxicologicalClassificationInternalId:Text") != "U" 
            If !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ToxicologicalClassificationInternalId:Text)
                aAux := AP090Cod(cMarca, oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ToxicologicalClassificationInternalId:Text)
                If Len(aAux) > 2 .and. !Empty(aAux[3])
                    aAdd(aAgroDados, {"NCR_CLATOX", aAux[3]})
                ElseIf Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ToxicologicalClassificationCode:Text") != "U"
                    cCodigo := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ToxicologicalClassificationCode:Text
                    NCF->(dbSetOrder( 1 ))
                    If NCF->(dbSeek( FWxFilial("NCF") + cCodigo) ) 
                        aAdd(aAgroDados, {"NCR_CLATOX", cCodigo})
                    Else
                        aadd(aErro,"Valor inválido na Tag ToxicologicalClassificationInternalId/ToxicologicalClassificationCode.")
                    EndIf
                Else
                    aadd(aErro,"Valor inválido na Tag ToxicologicalClassificationInternalId/ToxicologicalClassificationCode.")
                Endif
            Else
                aAdd(aAgroDados, {"NCR_CLATOX", ""})
            Endif
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EnvironmentalClassificationInternalId:Text") != "U" 
            If !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EnvironmentalClassificationInternalId:Text)
                aAux := AP100Cod(cMarca, oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EnvironmentalClassificationInternalId:Text)
                If Len(aAux) > 2 .and. !Empty(aAux[3])
                    aAdd(aAgroDados, {"NCR_CLAAMB", aAux[3]})
                ElseIf Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EnvironmentalClassificationCode:Text") != "U"
                    cCodigo := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_EnvironmentalClassificationCode:Text
                    NCG->(dbSetOrder( 1 ))
                    If NCG->(dbSeek( FWxFilial("NCG") + cCodigo) ) 
                        aAdd(aAgroDados, {"NCR_CLAAMB", cCodigo})
                    Else
                        aadd(aErro,"Valor inválido na Tag EnvironmentalClassificationInternalId/EnvironmentalClassificationCode.")
                    EndIf
                Else
                    aadd(aErro,"Valor inválido na Tag EnvironmentalClassificationInternalId/EnvironmentalClassificationCode.")
                Endif
            Else
                aAdd(aAgroDados, {"NCR_CLAAMB", ""})
            Endif
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_MapaRegistrationCode:Text") != "U"
            aAdd(aAgroDados, {"NCR_MAPA",   oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_MapaRegistrationCode:Text})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgriculturalInputActionModeInternalId:Text") != "U" 
            If !Empty(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgriculturalInputActionModeInternalId:Text)
                aAux := AP110Cod(cMarca, oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgriculturalInputActionModeInternalId:Text)
                If Len(aAux) > 2 .and. !Empty(aAux[3])
                    aAdd(aAgroDados, {"NCR_MODACA", aAux[3]})
                ElseIf Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgriculturalInputActionModeCode:Text") != "U"
                    cCodigo := oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgriculturalInputActionModeCode:Text
                    NCH->(dbSetOrder( 1 ))
                    If NCH->(dbSeek( FWxFilial("NCH") + cCodigo) ) 
                        aAdd(aAgroDados, {"NCR_MODACA", cCodigo})
                    Else
                        aadd(aErro,"Valor inválido na Tag AgriculturalInputActionModeInternalId/AgriculturalInputActionModeCode.")
                    EndIf
                Else
                    aadd(aErro,"Valor inválido na Tag AgriculturalInputActionModeInternalId/AgriculturalInputActionModeCode.")
                Endif
            Else
                aAdd(aAgroDados, {"NCR_MODACA", ""})
            Endif
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrganicCarbon:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_COT", val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_OrganicCarbon:Text)})
        Endif
        //If (cVersion = "3." .and. cVersion >= "3.010") .or. (cVersion = "4." .and. cVersion >= "4.008")
        //If NCR->(ColumnPos("NCR_CTCRED")) > 0
            //If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgriculturalCreditAccountantAccountCode:Text") != "U"
                //aAdd(aAgroDados, {"NCR_CTCRED", oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_AgriculturalCreditAccountantAccountCode:Text})
            //Endif
        //Endif
        //Endif

        // Macronutrientes.
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageNitrogen:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_N",   val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageNitrogen:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentagePhosphorus:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_P",   val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentagePhosphorus:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentagePotassium:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_K",   val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentagePotassium:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageCarbon:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_C",   val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageCarbon:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageOxygen:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_O",   val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageOxygen:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageHydrogen:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_H",   val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageHydrogen:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageSulfur:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_S",   val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageSulfur:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageCalcium:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_CA",  val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageCalcium:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageMagnesium:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_MG",  val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageMagnesium:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageOtherMacronutrients:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_OMA", val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageOtherMacronutrients:Text)})
        Endif

        // Micronutrientes.
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageIron:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_FE",  val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageIron:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageManganese:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_MN",  val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageManganese:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageBoron:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_B",   val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageBoron:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageZinc:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_ZN",   val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageZinc:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageCopper:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_CU",  val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageCopper:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageMolybdenum:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_MO",  val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageMolybdenum:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageChlorine:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_CL",  val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageChlorine:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageOtherMicronutrients:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_OMI", val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageOtherMicronutrients:Text)})
        Endif

        // Nutrientes benéficos.
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageSodium:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_NA",  val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageSodium:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageCobalt:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_CO",  val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageCobalt:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageSilicon:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_SI",  val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageSilicon:Text)})
        Endif
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageNickel:Text") != "U"
            aAdd(aAgroDados, {"NCR_VL_NI",  val(oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_PercentageNickel:Text)})
        Endif

        // Dados de mantenedor (agronegócio).
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalInputMaintainer") <> "U"
            aAdd(aAgroModel, {"FORMNC7", {}})
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalInputMaintainer:_AgriculturalInputMaintainer") <> "U"
                XmlNode2Arr(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalInputMaintainer:_AgriculturalInputMaintainer,'_AgriculturalInputMaintainer')
                aXMLAux := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalInputMaintainer:_AgriculturalInputMaintainer

                aAgroDados := aTail(aAgroModel)[2]            
                For nCount := 1 to len(aXMLAux)                
                    If XmlChildEx(aXMLAux[nCount], UPPER("_AgriculturalInputMaintainerInternalId") ) <> Nil ;
                    .and. !Empty(aXMLAux[nCount]:_AgriculturalInputMaintainerInternalId:Text)
                            aAdd(aAgroDados, {})
                            aAgroReg := aTail(aAgroDados)
                            aAux := AP010Cod(cMarca, aXMLAux[nCount]:_AgriculturalInputMaintainerInternalId:Text)
                            If Len(aAux) > 2 .and. !Empty(aAux[3])
                                aAdd(aAgroReg, {"NCM_CODREG", aAux[3]})
                            ElseIf XmlChildEx(aXMLAux[nCount], UPPER("_AgriculturalInputMaintainerCode") ) <> Nil //_AGRICULTURALINPUTMAINTAINERCODE
                                cCodigo := aXMLAux[nCount]:_AgriculturalInputMaintainerCode:Text
                                NC7->(dbSetOrder( 1 ))
                                If NC7->(dbSeek( FWxFilial("NC7") + cCodigo) ) 
                                    aAdd(aAgroReg, {"NCM_CODREG", cCodigo})
                                Else
                                    aadd(aErro,"Valor inválido na Tag AgriculturalInputMaintainerInternalId/AgriculturalInputMaintainerCode.")
                                EndIf
                            Else
                                aadd(aErro,"Valor inválido na Tag AgriculturalInputMaintainerInternalId/AgriculturalInputMaintainerCode.")
                            Endif
                    Endif
                Next nCount
            Endif
        Endif

        // Dados de alvos/fitossanidade (agronegócio).
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalPhytosanitary") <> "U"
            aAdd(aAgroModel, {"FORMNCD", {}})
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalPhytosanitary:_AgriculturalPhytosanitary") <> "U"
                XmlNode2Arr(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalPhytosanitary:_AgriculturalPhytosanitary,'_AgriculturalPhytosanitary')
                aXMLAux := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalPhytosanitary:_AgriculturalPhytosanitary

                aAgroDados := aTail(aAgroModel)[2]
                For nCount := 1 to len(aXMLAux)                
                    If XmlChildEx(aXMLAux[nCount], UPPER("_AgriculturalPhytosanitaryInternalId") ) <> Nil ; 
                        .and. !Empty(aXMLAux[nCount]:_AgriculturalPhytosanitaryInternalId:Text)
                            aAdd(aAgroDados, {})
                            aAgroReg := aTail(aAgroDados)
                            aAux := AP070Cod(cMarca, aXMLAux[nCount]:_AgriculturalPhytosanitaryInternalId:Text)
                            If Len(aAux) > 2 .and. !Empty(aAux[3])
                                aAdd(aAgroReg, {"NCM_CODREG", aAux[3]})
                            ElseIf XmlChildEx(aXMLAux[nCount], UPPER("_AgriculturalPhytosanitaryCode") ) <> Nil
                                cCodigo := aXMLAux[nCount]:_AgriculturalPhytosanitaryCode:Text
                                NCD->(dbSetOrder( 1 ))
                                If NCD->(dbSeek( FWxFilial("NCD") + cCodigo) ) 
                                    aAdd(aAgroReg, {"NCM_CODREG", cCodigo})
                                Else
                                    aadd(aErro,"Valor inválido na Tag AgriculturalPhytosanitaryInternalId/AgriculturalPhytosanitaryCode.")
                                EndIf
                            Else
                                aadd(aErro,"Valor inválido na Tag AgriculturalPhytosanitaryInternalId/AgriculturalPhytosanitaryCode.")
                            Endif
                        
                    Endif

                    If XmlChildEx(aXMLAux[nCount], UPPER("_AgriculturalCultureInternalId") ) <> Nil 
                        If !Empty(aXMLAux[nCount]:_AgriculturalCultureInternalId:Text)
                            aAux := AI800Cod(cMarca, aXMLAux[nCount]:_AgriculturalCultureInternalId:Text)
                            If Len(aAux) > 2 .and. !Empty(aAux[3])
                                aAdd(aAgroReg, {"NCM_CULTUR", aAux[3]})
                            ElseIf XmlChildEx(aXMLAux[nCount], UPPER("_AgriculturalCultureCode") ) <> Nil //_AGRICULTURALINPUTMAINTAINERCODE
                                cCodigo := aXMLAux[nCount]:_AgriculturalCultureCode:Text
                                NP3->(dbSetOrder( 1 ))
                                If NP3->(dbSeek( FWxFilial("NP3") + cCodigo) ) 
                                    aAdd(aAgroReg, {"NCM_CULTUR", cCodigo})
                                Else
                                    aadd(aErro,"Valor inválido na Tag AgriculturalCultureInternalId/AgriculturalCultureCode.")
                                EndIf
                            Else
                                aadd(aErro,"Valor inválido na Tag AgriculturalCultureInternalId/AgriculturalCultureCode.")
                            Endif
                        Else
                            aAdd(aAgroReg, {"NCM_CULTUR", ""})
                        Endif
                    Endif
                    If XmlChildEx(aXMLAux[nCount], UPPER("_Observation") ) <> Nil
                        aAdd(aAgroReg, {"NCM_OBS",    aXMLAux[nCount]:_Observation:Text})
                    Endif
                    If XmlChildEx(aXMLAux[nCount], UPPER("_MinimumDosage") ) <> Nil
                        aAdd(aAgroReg, {"NCM_DOSMIN", val(aXMLAux[nCount]:_MinimumDosage:Text)})
                    Endif
                    If XmlChildEx(aXMLAux[nCount], UPPER("_MaximumDosage") ) <> Nil
                        aAdd(aAgroReg, {"NCM_DOSMAX", val(aXMLAux[nCount]:_MaximumDosage:Text)})
                    Endif
                    If XmlChildEx(aXMLAux[nCount], UPPER("_RecommendedDosage") ) <> Nil
                        aAdd(aAgroReg, {"NCM_DOSREC", val(aXMLAux[nCount]:_RecommendedDosage:Text)})
                    Endif
                Next nCount
            Endif
        Endif

        // Dados de grupo químico (agronegócio).
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalInputChemicalGroup") <> "U"
            aAdd(aAgroModel, {"FORMNCK", {}})
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalInputChemicalGroup:_AgriculturalInputChemicalGroup") <> "U"
                XmlNode2Arr(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalInputChemicalGroup:_AgriculturalInputChemicalGroup,'_AgriculturalInputChemicalGroup')
                aXMLAux := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalInputChemicalGroup:_AgriculturalInputChemicalGroup

                aAgroDados := aTail(aAgroModel)[2]
                For nCount := 1 to len(aXMLAux)
                    If XmlChildEx(aXMLAux[nCount], UPPER("_AgriculturalInputChemicalGroupInternalId") ) <> Nil ;
                        .and. !Empty(aXMLAux[nCount]:_AgriculturalInputChemicalGroupInternalId:Text)
                            aAdd(aAgroDados, {})
                            aAgroReg := aTail(aAgroDados)
                            aAux := AP050Cod(cMarca, aXMLAux[nCount]:_AgriculturalInputChemicalGroupInternalId:Text)
                            If Len(aAux) > 2 .and. !Empty(aAux[3])
                                aAdd(aAgroReg, {"NCM_CODREG", aAux[3]})
                            ElseIf XmlChildEx(aXMLAux[nCount], UPPER("_AgriculturalInputChemicalGroupCode") ) <> Nil
                                cCodigo := aXMLAux[nCount]:_AgriculturalInputChemicalGroupCode:Text
                                NCK->(dbSetOrder( 1 ))
                                If NCK->(dbSeek( FWxFilial("NCK") + cCodigo) ) 
                                    aAdd(aAgroReg, {"NCM_CODREG", cCodigo})
                                Else
                                    aadd(aErro,"Valor inválido na Tag AgriculturalInputChemicalGroupInternalId/AgriculturalInputChemicalGroupCode.")
                                EndIf
                            Else
                                aadd(aErro,"Valor inválido na Tag AgriculturalInputChemicalGroupInternalId/AgriculturalInputChemicalGroupCode.")
                            Endif
                    Endif
                Next nCount
            Endif
        Endif

        // Dados de princípio ativo (agronegócio).
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfActiveIngredient") <> "U"
            aAdd(aAgroModel, {"FORMNCE", {}})
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfActiveIngredient:_ActiveIngredient") <> "U"
                XmlNode2Arr(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfActiveIngredient:_ActiveIngredient,'_ActiveIngredient')
                aXMLAux := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfActiveIngredient:_ActiveIngredient

                aAgroDados := aTail(aAgroModel)[2]
                For nCount := 1 to len(aXMLAux)
                    If XmlChildEx(aXMLAux[nCount], UPPER("_ActiveIngredientInternalId") ) <> Nil ;
                        .and. !Empty(aXMLAux[nCount]:_ActiveIngredientInternalId:Text)
                            aAdd(aAgroDados, {})
                            aAgroReg := aTail(aAgroDados)
                            aAux := AP080Cod(cMarca, aXMLAux[nCount]:_ActiveIngredientInternalId:Text)
                            If Len(aAux) > 2 .and. !Empty(aAux[3])
                                aAdd(aAgroReg, {"NCM_CODREG", aAux[3]})
                            ElseIf XmlChildEx(aXMLAux[nCount], UPPER("_ActiveIngredientCode") ) <> Nil
                                cCodigo := aXMLAux[nCount]:_ActiveIngredientCode:Text
                                NCE->(dbSetOrder( 1 ))
                                If NCE->(dbSeek( FWxFilial("NCE") + cCodigo) ) 
                                    aAdd(aAgroReg, {"NCM_CODREG", cCodigo})
                                Else
                                    aadd(aErro,"Valor inválido na Tag ActiveIngredientInternalId/ActiveIngredientCode.")
                                EndIf
                            Else
                                aadd(aErro,"Valor inválido na Tag ActiveIngredientInternalId/ActiveIngredientCode.")
                            Endif
                    Endif
                    If XmlChildEx(aXMLAux[nCount], UPPER("_ConcentrationPercentage") ) <> Nil
                        aAdd(aAgroReg, {"NCM_PERCON", val(aXMLAux[nCount]:_ConcentrationPercentage:Text)})
                    Endif
                    If XmlChildEx(aXMLAux[nCount], UPPER("_ConcentrationQuantity") ) <> Nil
                        aAdd(aAgroReg, {"NCM_QTDCON", val(aXMLAux[nCount]:_ConcentrationQuantity:Text)})
                    Endif
                    If XmlChildEx(aXMLAux[nCount], UPPER("_UnitOfMeasureOfInternalId") ) <> Nil 
                        If !Empty(aXMLAux[nCount]:_UnitOfMeasureOfInternalId:Text)
                            aAux := IntUndInt(aXMLAux[nCount]:_UnitOfMeasureOfInternalId:Text, cMarca)
                            If aAux[1]
                                aAdd(aAgroReg, {"NCM_UM", PadR(aAux[2][3],TamSx3("B1_UM")[1])})
                            ElseIf XmlChildEx(aXMLAux[nCount], UPPER("_UnitOfMeasureOfCode") ) <> Nil
                                cCodigo := PadR(aXMLAux[nCount]:_UnitOfMeasureOfCode:Text,TamSx3("B1_UM")[1])
                                SAH->(dbSetOrder( 1 ))
                                If SAH->(dbSeek( FWxFilial("SAH") + cCodigo) ) 
                                    aAdd(aAgroReg, {"NCM_UM", PadR(cCodigo,TamSx3("B1_UM")[1])})
                                Else
                                    aadd(aErro,"Valor inválido na Tag UnitOfMeasureOfInternalId/UnitOfMeasureOfCode.")
                                EndIf
                            Else
                                aadd(aErro,"Valor inválido na Tag UnitOfMeasureOfInternalId/UnitOfMeasureOfCode.")
                            Endif
                        Else
                            aAdd(aAgroReg, {"NCM_UM", ""})
                        Endif
                        
                    Endif
                    If XmlChildEx(aXMLAux[nCount], UPPER("_UnitOfMeasureByInternalId") ) <> Nil 
                        If !Empty(aXMLAux[nCount]:_UnitOfMeasureByInternalId:Text)
                            aAux := IntUndInt(aXMLAux[nCount]:_UnitOfMeasureByInternalId:Text, cMarca)
                            If aAux[1]
                                aAdd(aAgroReg, {"NCM_UMBASE", PadR(aAux[2][3],TamSx3("B1_UM")[1])})
                            ElseIf XmlChildEx(aXMLAux[nCount], UPPER("_UnitOfMeasureByCode") ) <> Nil
                                cCodigo := PadR(aXMLAux[nCount]:_UnitOfMeasureByCode:Text,TamSx3("B1_UM")[1])
                                SAH->(dbSetOrder( 1 ))
                                If SAH->(dbSeek( FWxFilial("SAH") + cCodigo) ) 
                                    aAdd(aAgroReg, {"NCM_UMBASE", PadR(cCodigo,TamSx3("B1_UM")[1])})
                                Else
                                    aadd(aErro,"Valor inválido na Tag UnitOfMeasureByInternalId/UnitOfMeasureByCode.")
                                EndIf
                            Else
                                aadd(aErro,"Valor inválido na Tag UnitOfMeasureByInternalId/UnitOfMeasureByCode.")
                            Endif
                        Else
                            aAdd(aAgroReg, {"NCM_UMBASE", ""})
                        Endif
                    
                    Endif
                Next nCount
            Endif
        Endif

        // Dados de culturas (agronegócio).
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalCulture") <> "U"
            aAdd(aAgroModel, {"FORMNP3", {}})
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalCulture:_AgriculturalCulture") <> "U"
                XmlNode2Arr(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalCulture:_AgriculturalCulture,'_AgriculturalCulture')
                aXMLAux := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalCulture:_AgriculturalCulture

                aAgroDados := aTail(aAgroModel)[2]
                For nCount := 1 to len(aXMLAux)
                    If XmlChildEx(aXMLAux[nCount], UPPER("_AgriculturalCultureInternalId") ) <> Nil ;
                        .and. !Empty(aXMLAux[nCount]:_AgriculturalCultureInternalId:Text)
                            aAdd(aAgroDados, {})
                            aAgroReg := aTail(aAgroDados)
                            aAux := AI800Cod(cMarca, aXMLAux[nCount]:_AgriculturalCultureInternalId:Text)
                            If Len(aAux) > 2 .and. !Empty(aAux[3])
                                aAdd(aAgroReg, {"NCM_CODREG", aAux[3]})
                            ElseIf XmlChildEx(aXMLAux[nCount], UPPER("_AgriculturalCultureCode") ) <> Nil
                                aAdd(aAgroReg, {"NCM_CODREG", aXMLAux[nCount]:_AgriculturalCultureCode:Text})
                                cCodigo := aXMLAux[nCount]:_AgriculturalCultureCode:Text
                                NP3->(dbSetOrder( 1 ))
                                If NP3->(dbSeek( FWxFilial("NP3") + cCodigo) ) 
                                    aAdd(aAgroReg, {"NCM_CODREG", cCodigo})
                                Else
                                    aadd(aErro,"Valor inválido na Tag AgriculturalCultureInternalId/AgriculturalCultureCode.")
                                EndIf
                            Else
                                aadd(aErro,"Valor inválido na Tag AgriculturalCultureInternalId/AgriculturalCultureCode.")
                            Endif
                    Endif
                    If XmlChildEx(aXMLAux[nCount], UPPER("_GracePeriodForHarvest") ) <> Nil
                        aAdd(aAgroReg, {"NCM_CARCOL", val(aXMLAux[nCount]:_GracePeriodForHarvest:Text)})
                    Endif
                    If XmlChildEx(aXMLAux[nCount], UPPER("_GracePeriodForReEntry") ) <> Nil
                        aAdd(aAgroReg, {"NCM_CARREE", val(aXMLAux[nCount]:_GracePeriodForReEntry:Text)})
                    Endif
                Next nCount
            Endif
        Endif

        // Dados de tecnologia de aplicação (agronegócio).
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalInputApplicationTechnology") <> "U"
            aAdd(aAgroModel, {"FORMNCC", {}})
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalInputApplicationTechnology:_AgriculturalInputApplicationTechnology") <> "U"
                XmlNode2Arr(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalInputApplicationTechnology:_AgriculturalInputApplicationTechnology,'_AgriculturalInputApplicationTechnology')
                aXMLAux := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalInputApplicationTechnology:_AgriculturalInputApplicationTechnology

                aAgroDados := aTail(aAgroModel)[2]
                For nCount := 1 to len(aXMLAux)
                    If XmlChildEx(aXMLAux[nCount], UPPER("_AgriculturalInputApplicationTechnologyInternalId") ) <> Nil ;
                        .and. !Empty(aXMLAux[nCount]:_AgriculturalInputApplicationTechnologyInternalId:Text)
                            aAdd(aAgroDados, {})
                            aAgroReg := aTail(aAgroDados)
                            aAux := AP060Cod(cMarca, aXMLAux[nCount]:_AgriculturalInputApplicationTechnologyInternalId:Text)
                            If Len(aAux) > 2 .and. !Empty(aAux[3])
                                aAdd(aAgroReg, {"NCM_CODREG", aAux[3]})
                            ElseIf XmlChildEx(aXMLAux[nCount], UPPER("_AgriculturalInputApplicationTechnologyCode") ) <> Nil
                                cCodigo := aXMLAux[nCount]:_AgriculturalInputApplicationTechnologyCode:Text
                                NCC->(dbSetOrder( 1 ))
                                If NCC->(dbSeek( FWxFilial("NCC") + cCodigo) ) 
                                    aAdd(aAgroReg, {"NCM_CODREG", cCodigo})
                                Else
                                    aadd(aErro,"Valor inválido na Tag AgriculturalInputApplicationTechnologyInternalId/AgriculturalInputApplicationTechnologyCode.")
                                EndIf
                            Else
                                aadd(aErro,"Valor inválido na Tag AgriculturalInputApplicationTechnologyInternalId/AgriculturalInputApplicationTechnologyCode.")
                            Endif
                    Endif
                Next nCount
            Endif
        Endif

        // Dados de EPI (agronegócio).
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfEquipmentsIndividualSafety") <> "U"
            aAdd(aAgroModel, {"FORMNCP", {}})
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfEquipmentsIndividualSafety:_EquipmentsIndividualSafety") <> "U"
                XmlNode2Arr(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfEquipmentsIndividualSafety:_EquipmentsIndividualSafety,'_EquipmentsIndividualSafety')
                aXMLAux := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfEquipmentsIndividualSafety:_EquipmentsIndividualSafety

                aAgroDados := aTail(aAgroModel)[2]
                For nCount := 1 to len(aXMLAux)
                    If XmlChildEx(aXMLAux[nCount], UPPER("_EquipmentsIndividualSafetyInternalId") ) <> Nil ;
                        .and. !Empty(aXMLAux[nCount]:_EquipmentsIndividualSafetyInternalId:Text)
                            aAdd(aAgroDados, {})
                            aAgroReg := aTail(aAgroDados)
                            aAux := AP130Cod(cMarca, aXMLAux[nCount]:_EquipmentsIndividualSafetyInternalId:Text)
                            If Len(aAux) > 2 .and. !Empty(aAux[3])
                                aAdd(aAgroReg, {"NCM_CODREG", aAux[3]})
                            ElseIf XmlChildEx(aXMLAux[nCount], UPPER("_EquipmentsIndividualSafetyCode") ) <> Nil
                                aAdd(aAgroReg, {"NCM_CODREG", aXMLAux[nCount]:_EquipmentsIndividualSafetyCode:Text})
                                cCodigo := aXMLAux[nCount]:_EquipmentsIndividualSafetyCode:Text
                                NCP->(dbSetOrder( 1 ))
                                If NCP->(dbSeek( FWxFilial("NCP") + cCodigo) ) 
                                    aAdd(aAgroReg, {"NCM_CODREG", cCodigo})
                                Else
                                    aadd(aErro,"Valor inválido na Tag EquipmentsIndividualSafetyInternalId/EquipmentsIndividualSafetyCode.")
                                EndIf
                            Else
                                aadd(aErro,"Valor inválido na Tag EquipmentsIndividualSafetyInternalId/EquipmentsIndividualSafetyCode.")
                            Endif
                    Endif
                Next nCount
            Endif
        Endif

        // Dados de evento genético (agronegócio).
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalGeneticEvent") <> "U"
            aAdd(aAgroModel, {"FORMNCJ", {}})
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalGeneticEvent:_AgriculturalGeneticEvent") <> "U"
                XmlNode2Arr(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalGeneticEvent:_AgriculturalGeneticEvent,'_AgriculturalGeneticEvent')
                aXMLAux := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalGeneticEvent:_AgriculturalGeneticEvent

                aAgroDados := aTail(aAgroModel)[2]
                For nCount := 1 to len(aXMLAux)
                    If XmlChildEx(aXMLAux[nCount], UPPER("_AgriculturalGeneticEventInternalId") ) <> Nil ;
                        .and. !Empty(aXMLAux[nCount]:_AgriculturalGeneticEventInternalId:Text)
                            aAdd(aAgroDados, {})
                            aAgroReg := aTail(aAgroDados)
                            aAux := AP030Cod(cMarca, aXMLAux[nCount]:_AgriculturalGeneticEventInternalId:Text)
                            If Len(aAux) > 2 .and. !Empty(aAux[3])
                                aAdd(aAgroReg, {"NCM_CODREG", aAux[3]})
                            ElseIf XmlChildEx(aXMLAux[nCount], UPPER("_AgriculturalGeneticEventCode") ) <> Nil
                                cCodigo := aXMLAux[nCount]:_AgriculturalGeneticEventCode:Text
                                NCJ->(dbSetOrder( 1 ))
                                If NCJ->(dbSeek( FWxFilial("NCJ") + cCodigo) ) 
                                    aAdd(aAgroReg, {"NCM_CODREG", cCodigo})
                                Else
                                    aadd(aErro,"Valor inválido na Tag AgriculturalGeneticEventInternalId/AgriculturalGeneticEventCode.")
                                EndIf
                            Else
                                aadd(aErro,"Valor inválido na Tag AgriculturalGeneticEventInternalId/AgriculturalGeneticEventCode.")
                            Endif
                    EndIF
                Next nCount
            Endif
        Endif

        // Dados de tecnologia de variedade (agronegócio).
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalInputTechnology") <> "U"
            aAdd(aAgroModel, {"FORMNCA", {}})
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalInputTechnology:_AgriculturalInputTechnology") <> "U"
                XmlNode2Arr(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalInputTechnology:_AgriculturalInputTechnology,'_AgriculturalInputTechnology')
                aXMLAux := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalInputTechnology:_AgriculturalInputTechnology

                aAgroDados := aTail(aAgroModel)[2]
                For nCount := 1 to len(aXMLAux)
                    If XmlChildEx(aXMLAux[nCount], UPPER("_AgriculturalInputTechnologyInternalId") ) <> Nil ;
                        .and. !Empty(aXMLAux[nCount]:_AgriculturalInputTechnologyInternalId:Text)
                            aAdd(aAgroDados, {})
                            aAgroReg := aTail(aAgroDados)
                            aAux := AP040Cod(cMarca, aXMLAux[nCount]:_AgriculturalInputTechnologyInternalId:Text)
                            If Len(aAux) > 2 .and. !Empty(aAux[3])
                                aAdd(aAgroReg, {"NCM_CODREG", aAux[3]})
                            ElseIf XmlChildEx(aXMLAux[nCount], UPPER("_AgriculturalInputTechnologyCode") ) <> Nil
                                cCodigo := aXMLAux[nCount]:_AgriculturalInputTechnologyCode:Text
                                NCA->(dbSetOrder( 1 ))
                                If NCA->(dbSeek( FWxFilial("NCA") + cCodigo) ) 
                                    aAdd(aAgroReg, {"NCM_CODREG", cCodigo})
                                Else
                                    aadd(aErro,"Valor inválido na Tag AgriculturalInputTechnologyInternalId/AgriculturalInputTechnologyCode.")
                                EndIf
                            Else
                                aadd(aErro,"Valor inválido na Tag AgriculturalInputTechnologyInternalId/AgriculturalInputTechnologyCode.")
                            Endif
                    Endif
                Next nCount
            Endif
        Endif

        // Dados de sistema de aplicação (agronegócio).
        If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalApplicationSystem") <> "U"
            aAdd(aAgroModel, {"FORMNCO", {}})
            If Type("oXml:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalApplicationSystem:_AgriculturalApplicationSystem") <> "U"
                XmlNode2Arr(oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalApplicationSystem:_AgriculturalApplicationSystem,'_AgriculturalApplicationSystem')
                aXMLAux := oXML:_TOTVSMessage:_BusinessMessage:_BusinessContent:_ListOfAgriculturalApplicationSystem:_AgriculturalApplicationSystem

                aAgroDados := aTail(aAgroModel)[2]
                For nCount := 1 to len(aXMLAux)
                    If XmlChildEx(aXMLAux[nCount], UPPER("_AgriculturalApplicationSystemInternalId") ) <> Nil ;
                        .and. !Empty(aXMLAux[nCount]:_AgriculturalApplicationSystemInternalId:Text)
                            aAdd(aAgroDados, {})
                            aAgroReg := aTail(aAgroDados)
                            aAux := AP120Cod(cMarca, aXMLAux[nCount]:_AgriculturalApplicationSystemInternalId:Text)
                            If Len(aAux) > 2 .and. !Empty(aAux[3])
                                aAdd(aAgroReg, {"NCM_CODREG", aAux[3]})
                            ElseIf XmlChildEx(aXMLAux[nCount], UPPER("_AgriculturalApplicationSystemCode") ) <> Nil
                                cCodigo := aXMLAux[nCount]:_AgriculturalApplicationSystemCode:Text
                                NCO->(dbSetOrder( 1 ))
                                If NCO->(dbSeek( FWxFilial("NCO") + cCodigo) ) 
                                    aAdd(aAgroReg, {"NCM_CODREG", cCodigo})
                                Else
                                    aadd(aErro,"Valor inválido na Tag AgriculturalApplicationSystemInternalId/AgriculturalApplicationSystemCode.")
                                EndIf
                            Else
                                aadd(aErro,"Valor inválido na Tag AgriculturalApplicationSystemInternalId/AgriculturalApplicationSystemCode.")
                            Endif
                    Endif
                Next nCount
            Endif
        Endif
    Endif
    */

    If LEN(aErro) > 0
        aadd(aRet,.F.)
        aadd(aRet,aErro)
    Else
        aadd(aRet,.T.)
        aadd(aRet,aAgroModel)
    ENDIF    

Return aRet

/*/{Protheus.doc} AGRPMT010GRVMD
Grava dados de agronegócio do produto no cadastro de produto via integração MATI010
O array de dados é gerado pelo função AGRPMT010ACPMD achado pelo MATI010 e repassado para esta função
@author  Felipe Raposo | claudineia.reinert
@version P12
@since   21/09/2018 | 25/08/2020
/*/
Function AGRPMT010GRVMD(aAgroModel, nEvento, cCode, cVersion) //#AGRO NOVO

    Local lRet       := .T.
    //Devido ao fluxo padrão ser PROTHEUS para o PIMS, por recomendação será mantido comentado o recebimento do XML
    // quando houver necessidade poderá ser descomentado para uso. Os testes foram realizado somente local PROTHEUS->PROTHEUS ou SOAUPUI->PROTHEUS
    /*
    Local oModel     := Nil
    local cModelo    := ""
    Local aAgroDados := {}
    Local cCodReg    := ""
    Local aReg       := {}
    Local aLinhasAlt := {}
    Local aErro      := {}
    Local oSubModel  as object
    Local nModelo    as numeric
    Local nLin       as numeric
    Local nReg       as numeric
    Local lUpdate    := .F.
     
    
    If len(aAgroModel) > 0
        oModel     := FwLoadModel("MATA010")
        oModel:SetOperation(MODEL_OPERATION_UPDATE)
        lRet := oModel:Activate()

        If lRet 
            // Atualiza os dados de todos os modelos.
            For nModelo := 1 to len(aAgroModel)
                cModelo    := aAgroModel[nModelo, 1]
                aAgroDados := aAgroModel[nModelo, 2]
                oSubModel  := oModel:GetModel(cModelo)            

                If cModelo == "FORMNCR"   // Se for um modelo de fields.
                    // Atualiza todos os registros da linha.
                    aReg := aAgroDados
                    For nReg := 1 to len(aReg)
                        lRet := oSubModel:SetValue(aReg[nReg, 1], aReg[nReg, 2])
                        lUpdate := .T.
                        If !lRet
                            Exit
                        Endif
                    Next nReg
                Else// Se for um modelo de grid.
                    // Controle para apagar linhas a mais do modelo
                    aLinhasAlt := array(oSubModel:Length())
                    aFill(aLinhasAlt, .F.)

                    // Percorre todas as linhas do modelo.
                    For nLin := 1 to len(aAgroDados)
                        aReg    := aAgroDados[nLin]
                        nReg    := aScan(aReg, {|x| x[1] == "NCM_CODREG"})
                        cCodReg := aReg[nReg, 2]

                        If oSubModel:SeekLine({{"NCM_CODREG", cCodReg}})
                            aLinhasAlt[oSubModel:GetLine()] := .T.  // Marca a linha como atualizada.
                        Else
                            lRet := (oSubModel:AddLine() > 0 .and. oSubModel:SetValue("NCM_CODREG", cCodReg))
                        EndIf
                        lUpdate := .T.

                        // Atualiza todos os registros da linha.
                        If lRet
                            For nReg := 1 to len(aReg)
                                cCodReg := aReg[nReg, 1]
                                If cCodReg <> "NCM_CODREG"
                                    lRet := oSubModel:SetValue(aReg[nReg, 1], aReg[nReg, 2])
                                    lUpdate := .T.
                                Endif
                                If !lRet
                                    Exit
                                Endif
                            Next nReg
                        Endif

                        If !lRet
                            Exit
                        Endif
                    Next nLin

                    // Apaga as linhas não passadas na mensagem.
                    If lRet
                        For nLin := 1 to len(aLinhasAlt)
                            If !aLinhasAlt[nLin]
                                lRet := (oSubModel:GoLine(nLin) == nLin .and. oSubModel:DeleteLine())
                                lUpdate := .T.
                                If !lRet
                                    Exit
                                Endif
                            Endif
                        Next nLin
                    Endif
                Endif

                If !lRet
                    Exit
                Endif
            Next nModelo

            If lRet .and. lUpdate  
                // Grava os dados passados.
                lRet := oModel:VldData() .and. oModel:CommitData()
            EndIf
        Endif

        If !lRet
            lMsErroAuto := .T. //VARIAVEL PRIVATE DA FUNÇÃO QUE CHAMA ESTA FUNÇÃO

            aErro := oModel:GetErrorMessage()
            AutoGRLog(Alltrim(aErro[5]) + '-' + AllTrim(aErro[6]))
            If !Empty(Alltrim(aErro[7]))
                AutoGRLog(AllTrim(aErro[7]))
            Endif
        Endif
    Endif
    */

Return lRet

/*/{Protheus.doc} VldVersao
Valida a versão do XML e se esta ativo os parametros necessarios para ativar os campos/aba dos dados de agronegócio do produto no cadastro de produto 
@author  Felipe Raposo | claudineia.reinert
@version P12
@since   21/09/2018 | 25/08/2020
/*/
Static Function VldVersao(cVersion)
    Local lRet := .F.
    Local cRot := SuperGetMv("MV_CADPROD",,"|SBZ|SB5|SGI|D3E|")
   
    Local aVersao := StrTokArr( cVersion , ".")
	Local cVersao := aVersao[1]
	Local cRelease := aVersao[2]
    // Define se os campos/tag de agronegócio serão trafegados.
    If cVersao = "4" .and. cRelease >= "007"  // Se versão 4, da 4.007 ou acima. //#AGRO NOVO
        If "AGRO" $ cRot .And. SuperGetMv("MV_SIGAAGR",,.F.) == .T.
            lRet := .T.
        Endif
    Endif


Return lRet

/*/{Protheus.doc} AGRPMT010XMLENV
Gera as tags XML dos dados de agronegócio do produto do cadastro de produto para envio via integração MATI010

@author  Felipe Raposo | claudineia.reinert
@version P12
@since   21/09/2018 | 25/08/2020
/*/
Function AGRPMT010XMLENV(cVersion, cCodProd)
    Local lAgro := VldVersao(cVersion)
    Local cXMLRet := ""

    //#AGRO NOVO INICIO
    // Dados agronegócio.
    If lAgro
        NCR->(dbSetOrder(1))  // NCR_FILIAL, NCR_PROD.
        If NCR->(msSeek(xFilial() + cCodProd, .F.))
            cXMLRet += '<AgriculturalCultureCode>' + _NoTags(RTrim(NCR->NCR_CULTUR)) + '</AgriculturalCultureCode>'
            cXMLRet += '<AgriculturalCultureInternalId>' + IIF(Empty(NCR->NCR_CULTUR),'' ,RTrim(AI800IntId(, NCR->NCR_CULTUR))) + '</AgriculturalCultureInternalId>'
            cXMLRet += '<AgriculturalInputFormulationCode>' + _NoTags(RTrim(NCR->NCR_FORM)) + '</AgriculturalInputFormulationCode>'
            cXMLRet += '<AgriculturalInputFormulationInternalId>' + IIF(Empty(NCR->NCR_FORM),'' ,RTrim(AP020IntId(, NCR->NCR_FORM))) + '</AgriculturalInputFormulationInternalId>'
            cXMLRet += '<QuantityInertMaterials>' + cValToChar(NCR->NCR_MATINE) + '</QuantityInertMaterials>'
            cXMLRet += '<ToxicologicalClassificationCode>' + _NoTags(RTrim(NCR->NCR_CLATOX)) + '</ToxicologicalClassificationCode>'
            cXMLRet += '<ToxicologicalClassificationInternalId>' + IIF(Empty(NCR->NCR_CLATOX),'' ,RTrim(AP090IntId(, NCR->NCR_CLATOX))) + '</ToxicologicalClassificationInternalId>'
            cXMLRet += '<EnvironmentalClassificationCode>' + _NoTags(RTrim(NCR->NCR_CLAAMB)) + '</EnvironmentalClassificationCode>'
            cXMLRet += '<EnvironmentalClassificationInternalId>' + IIF(Empty(NCR->NCR_CLAAMB),'' ,RTrim(AP100IntId(, NCR->NCR_CLAAMB))) + '</EnvironmentalClassificationInternalId>'
            cXMLRet += '<MapaRegistrationCode>' + _NoTags(RTrim(NCR->NCR_MAPA)) + '</MapaRegistrationCode>'
            cXMLRet += '<AgriculturalInputActionModeCode>' + _NoTags(RTrim(NCR->NCR_MODACA)) + '</AgriculturalInputActionModeCode>'
            cXMLRet += '<AgriculturalInputActionModeInternalId>' + IIF(Empty(NCR->NCR_MODACA),'' ,RTrim(AP110IntId(, NCR->NCR_MODACA))) + '</AgriculturalInputActionModeInternalId>'
            cXMLRet += '<OrganicCarbon>' + cValToChar(NCR->NCR_VL_COT) + '</OrganicCarbon>'
            /*If (cVersion = "3." .and. cVersion >= "3.010") .or. (cVersion = "4." .and. cVersion >= "4.008")
                If NCR->(ColumnPos("NCR_CTCRED")) > 0
                    cXMLRet += '<AgriculturalCreditAccountantAccountCode>' + RTrim(NCR->NCR_CTCRED) + '</AgriculturalCreditAccountantAccountCode>'
                Endif
            Endif*/

            // Macronutrientes.
            cXMLRet += '<PercentageNitrogen>'   + cValToChar(NCR->NCR_VL_N)  + '</PercentageNitrogen>'
            cXMLRet += '<PercentagePhosphorus>' + cValToChar(NCR->NCR_VL_P)  + '</PercentagePhosphorus>'
            cXMLRet += '<PercentagePotassium>'  + cValToChar(NCR->NCR_VL_K)  + '</PercentagePotassium>'
            cXMLRet += '<PercentageCarbon>'     + cValToChar(NCR->NCR_VL_C)  + '</PercentageCarbon>'
            cXMLRet += '<PercentageOxygen>'     + cValToChar(NCR->NCR_VL_O)  + '</PercentageOxygen>'
            cXMLRet += '<PercentageHydrogen>'   + cValToChar(NCR->NCR_VL_H)  + '</PercentageHydrogen>'
            cXMLRet += '<PercentageSulfur>'     + cValToChar(NCR->NCR_VL_S)  + '</PercentageSulfur>'
            cXMLRet += '<PercentageCalcium>'    + cValToChar(NCR->NCR_VL_CA) + '</PercentageCalcium>'
            cXMLRet += '<PercentageMagnesium>'  + cValToChar(NCR->NCR_VL_MG) + '</PercentageMagnesium>'
            cXMLRet += '<PercentageOtherMacronutrients>' + cValToChar(NCR->NCR_VL_OMA) + '</PercentageOtherMacronutrients>'

            // Micronutrientes.
            cXMLRet += '<PercentageIron>'       + cValToChar(NCR->NCR_VL_FE)  + '</PercentageIron>'
            cXMLRet += '<PercentageManganese>'  + cValToChar(NCR->NCR_VL_MN)  + '</PercentageManganese>'
            cXMLRet += '<PercentageBoron>'      + cValToChar(NCR->NCR_VL_B)   + '</PercentageBoron>'
            cXMLRet += '<PercentageZinc>'       + cValToChar(NCR->NCR_VL_ZN)  + '</PercentageZinc>'
            cXMLRet += '<PercentageCopper>'     + cValToChar(NCR->NCR_VL_CU)  + '</PercentageCopper>'
            cXMLRet += '<PercentageMolybdenum>' + cValToChar(NCR->NCR_VL_MO) + '</PercentageMolybdenum>'
            cXMLRet += '<PercentageChlorine>'   + cValToChar(NCR->NCR_VL_CL) + '</PercentageChlorine>'
            cXMLRet += '<PercentageOtherMicronutrients>' + cValToChar(NCR->NCR_VL_OMI) + '</PercentageOtherMicronutrients>'

            // Nutrientes benéficos.
            cXMLRet += '<PercentageSodium>'     + cValToChar(NCR->NCR_VL_NA) + '</PercentageSodium>'
            cXMLRet += '<PercentageCobalt>'     + cValToChar(NCR->NCR_VL_CO) + '</PercentageCobalt>'
            cXMLRet += '<PercentageSilicon>'    + cValToChar(NCR->NCR_VL_SI) + '</PercentageSilicon>'
            cXMLRet += '<PercentageNickel>'     + cValToChar(NCR->NCR_VL_NI) + '</PercentageNickel>'
        Endif

        // Mantenedores.
        NCM->(dbSetOrder(1))  // NCM_FILIAL, NCM_PROD, NCM_ALIAS, NCM_FILREG, NCM_CODREG.
        If NCM->(msSeek(xFilial() + cCodProd + "NC7", .F.))
            cXMLRet += '<ListOfAgriculturalInputMaintainer>'
            Do While NCM->(!eof() .and. NCM_FILIAL + NCM_PROD + NCM_ALIAS == xFilial() + cCodProd + "NC7")
                cXMLRet += '<AgriculturalInputMaintainer>'
                cXMLRet += '  <AgriculturalInputMaintainerCode>' + _NoTags(NCM->NCM_CODREG) + '</AgriculturalInputMaintainerCode>'
                cXMLRet += '  <AgriculturalInputMaintainerInternalId>' + IIF(Empty(NCM->NCM_CODREG),'' ,RTrim(AP010IntId(, NCM->NCM_CODREG))) + '</AgriculturalInputMaintainerInternalId>'
                cXMLRet += '</AgriculturalInputMaintainer>'
                NCM->(dbSkip())
            EndDo
            cXMLRet += '</ListOfAgriculturalInputMaintainer>'
        Else
            cXMLRet += '<ListOfAgriculturalInputMaintainer/>'
        Endif

        // Alvos (fitossanidade).
        NCM->(dbSetOrder(1))  // NCM_FILIAL, NCM_PROD, NCM_ALIAS, NCM_FILREG, NCM_CODREG.
        If NCM->(msSeek(xFilial() + cCodProd + "NCD", .F.))
            cXMLRet += '<ListOfAgriculturalPhytosanitary>'
            Do While NCM->(!eof() .and. NCM_FILIAL + NCM_PROD + NCM_ALIAS == xFilial() + cCodProd + "NCD")
                cXMLRet += '<AgriculturalPhytosanitary>'
                cXMLRet += '  <AgriculturalPhytosanitaryCode>' + _NoTags(NCM->NCM_CODREG) + '</AgriculturalPhytosanitaryCode>'
                cXMLRet += '  <AgriculturalPhytosanitaryInternalId>' + IIF(Empty(NCM->NCM_CODREG),'' ,RTrim(AP070IntId(, NCM->NCM_CODREG))) + '</AgriculturalPhytosanitaryInternalId>'
                cXMLRet += '  <AgriculturalCultureCode>' + _NoTags(NCM->NCM_CULTUR) + '</AgriculturalCultureCode>'
                cXMLRet += '  <AgriculturalCultureInternalId>' + IIF(Empty(NCM->NCM_CULTUR),'' ,RTrim(AI800IntId(, NCM->NCM_CULTUR))) + '</AgriculturalCultureInternalId>'
                cXMLRet += '  <Observation>' + _NoTags(NCM->NCM_OBS) + '</Observation>'
                cXMLRet += '  <MinimumDosage>' + cValToChar(NCM->NCM_DOSMIN) + '</MinimumDosage>'
                cXMLRet += '  <MaximumDosage>' + cValToChar(NCM->NCM_DOSMAX) + '</MaximumDosage>'
                cXMLRet += '  <RecommendedDosage>' + cValToChar(NCM->NCM_DOSREC) + '</RecommendedDosage>'
                cXMLRet += '</AgriculturalPhytosanitary>'
                NCM->(dbSkip())
            EndDo
            cXMLRet += '</ListOfAgriculturalPhytosanitary>'
        Else
            cXMLRet += '<ListOfAgriculturalPhytosanitary/>'
        Endif

        // Grupos químicos.
        NCM->(dbSetOrder(1))  // NCM_FILIAL, NCM_PROD, NCM_ALIAS, NCM_FILREG, NCM_CODREG.
        If NCM->(msSeek(xFilial() + cCodProd + "NCK", .F.))
            cXMLRet += '<ListOfAgriculturalInputChemicalGroup>'
            Do While NCM->(!eof() .and. NCM_FILIAL + NCM_PROD + NCM_ALIAS == xFilial() + cCodProd + "NCK")
                cXMLRet += '<AgriculturalInputChemicalGroup>'
                cXMLRet += '  <AgriculturalInputChemicalGroupCode>' + _NoTags(NCM->NCM_CODREG) + '</AgriculturalInputChemicalGroupCode>'
                cXMLRet += '  <AgriculturalInputChemicalGroupInternalId>' + IIF(Empty(NCM->NCM_CODREG),'' ,RTrim(AP050IntId(, NCM->NCM_CODREG))) + '</AgriculturalInputChemicalGroupInternalId>'
                cXMLRet += '</AgriculturalInputChemicalGroup>'
                NCM->(dbSkip())
            EndDo
            cXMLRet += '</ListOfAgriculturalInputChemicalGroup>'
        Else
            cXMLRet += '<ListOfAgriculturalInputChemicalGroup/>'
        Endif

        // Princípios ativos.
        NCM->(dbSetOrder(1))  // NCM_FILIAL, NCM_PROD, NCM_ALIAS, NCM_FILREG, NCM_CODREG.
        If NCM->(msSeek(xFilial() + cCodProd + "NCE", .F.))
            cXMLRet += '<ListOfActiveIngredient>'
            Do While NCM->(!eof() .and. NCM_FILIAL + NCM_PROD + NCM_ALIAS == xFilial() + cCodProd + "NCE")
                cXMLRet += '<ActiveIngredient>'
                cXMLRet += '  <ActiveIngredientCode>' + _NoTags(NCM->NCM_CODREG) + '</ActiveIngredientCode>'
                cXMLRet += '  <ActiveIngredientInternalId>' + IIF(Empty(NCM->NCM_CODREG),'' ,RTrim(AP080IntId(, NCM->NCM_CODREG))) + '</ActiveIngredientInternalId>'
                cXMLRet += '  <ConcentrationPercentage>' + cValToChar(NCM->NCM_PERCON) + '</ConcentrationPercentage>'
                cXMLRet += '  <ConcentrationQuantity>' + cValToChar(NCM->NCM_QTDCON) + '</ConcentrationQuantity>'
                If empty(NCM->NCM_UM)
                    cXMLRet += '<UnitOfMeasureOfCode/>'
                    cXMLRet += '<UnitOfMeasureOfInternalId/>'
                Else
                    cXMLRet += '  <UnitOfMeasureOfCode>' + _NoTags(NCM->NCM_UM) + '</UnitOfMeasureOfCode>'
                    cXMLRet += '  <UnitOfMeasureOfInternalId>' + IIF(Empty(NCM->NCM_UM), ,RTrim(IntUndExt(,, NCM->NCM_UM)[2])) + '</UnitOfMeasureOfInternalId>'
                Endif
                If empty(NCM->NCM_UMBASE)
                    cXMLRet += '<UnitOfMeasureByCode/>'
                    cXMLRet += '<UnitOfMeasureByInternalId/>'
                Else
                    cXMLRet += '  <UnitOfMeasureByCode>' + _NoTags(NCM->NCM_UMBASE) + '</UnitOfMeasureByCode>'
                    cXMLRet += '  <UnitOfMeasureByInternalId>' + IIF(Empty(NCM->NCM_UMBASE),'' ,RTrim(IntUndExt(,, NCM->NCM_UMBASE)[2])) + '</UnitOfMeasureByInternalId>'
                Endif
                cXMLRet += '</ActiveIngredient>'
                NCM->(dbSkip())
            EndDo
            cXMLRet += '</ListOfActiveIngredient>'
        Else
            cXMLRet += '<ListOfActiveIngredient/>'
        Endif

        // Culturas.
        NCM->(dbSetOrder(1))  // NCM_FILIAL, NCM_PROD, NCM_ALIAS, NCM_FILREG, NCM_CODREG.
        If NCM->(msSeek(xFilial() + cCodProd + "NP3", .F.))
            cXMLRet += '<ListOfAgriculturalCulture>'
            Do While NCM->(!eof() .and. NCM_FILIAL + NCM_PROD + NCM_ALIAS == xFilial() + cCodProd + "NP3")
                cXMLRet += '<AgriculturalCulture>'
                cXMLRet += '  <AgriculturalCultureCode>' + _NoTags(NCM->NCM_CODREG) + '</AgriculturalCultureCode>'
                cXMLRet += '  <AgriculturalCultureInternalId>' + IIF(Empty(NCM->NCM_CODREG),'' ,RTrim(AI800IntId(, NCM->NCM_CODREG))) + '</AgriculturalCultureInternalId>'
                cXMLRet += '  <GracePeriodForHarvest>' + cValToChar(NCM->NCM_CARCOL) + '</GracePeriodForHarvest>'
                cXMLRet += '  <GracePeriodForReEntry>' + cValToChar(NCM->NCM_CARREE) + '</GracePeriodForReEntry>'
                cXMLRet += '</AgriculturalCulture>'
                NCM->(dbSkip())
            EndDo
            cXMLRet += '</ListOfAgriculturalCulture>'
        Else
            cXMLRet += '<ListOfAgriculturalCulture/>'
        Endif

        // Tecnologia de aplicação.
        NCM->(dbSetOrder(1))  // NCM_FILIAL, NCM_PROD, NCM_ALIAS, NCM_FILREG, NCM_CODREG.
        If NCM->(msSeek(xFilial() + cCodProd + "NCC", .F.))
            cXMLRet += '<ListOfAgriculturalInputApplicationTechnology>'
            Do While NCM->(!eof() .and. NCM_FILIAL + NCM_PROD + NCM_ALIAS == xFilial() + cCodProd + "NCC")
                cXMLRet += '<AgriculturalInputApplicationTechnology>'
                cXMLRet += '  <AgriculturalInputApplicationTechnologyCode>' + _NoTags(NCM->NCM_CODREG) + '</AgriculturalInputApplicationTechnologyCode>'
                cXMLRet += '  <AgriculturalInputApplicationTechnologyInternalId>' + IIF(Empty(NCM->NCM_CODREG),'' ,RTrim(AP060IntId(, NCM->NCM_CODREG))) + '</AgriculturalInputApplicationTechnologyInternalId>'
                cXMLRet += '</AgriculturalInputApplicationTechnology>'
                NCM->(dbSkip())
            EndDo
            cXMLRet += '</ListOfAgriculturalInputApplicationTechnology>'
        Else
            cXMLRet += '<ListOfAgriculturalInputApplicationTechnology/>'
        Endif

        // EPI.
        NCM->(dbSetOrder(1))  // NCM_FILIAL, NCM_PROD, NCM_ALIAS, NCM_FILREG, NCM_CODREG.
        If NCM->(msSeek(xFilial() + cCodProd + "NCP", .F.))
            cXMLRet += '<ListOfEquipmentsIndividualSafety>'
            Do While NCM->(!eof() .and. NCM_FILIAL + NCM_PROD + NCM_ALIAS == xFilial() + cCodProd + "NCP")
                cXMLRet += '<EquipmentsIndividualSafety>'
                cXMLRet += '  <EquipmentsIndividualSafetyCode>' + _NoTags(NCM->NCM_CODREG) + '</EquipmentsIndividualSafetyCode>'
                cXMLRet += '  <EquipmentsIndividualSafetyInternalId>' + IIF(Empty(NCM->NCM_CODREG),'' ,RTrim(AP130IntId(, NCM->NCM_CODREG))) + '</EquipmentsIndividualSafetyInternalId>'
                cXMLRet += '</EquipmentsIndividualSafety>'
                NCM->(dbSkip())
            EndDo
            cXMLRet += '</ListOfEquipmentsIndividualSafety>'
        Else
            cXMLRet += '<ListOfEquipmentsIndividualSafety/>'
        Endif

        // Evento genético.
        NCM->(dbSetOrder(1))  // NCM_FILIAL, NCM_PROD, NCM_ALIAS, NCM_FILREG, NCM_CODREG.
        If NCM->(msSeek(xFilial() + cCodProd + "NCJ", .F.))
            cXMLRet += '<ListOfAgriculturalGeneticEvent>'
            Do While NCM->(!eof() .and. NCM_FILIAL + NCM_PROD + NCM_ALIAS == xFilial() + cCodProd + "NCJ")
                cXMLRet += '<AgriculturalGeneticEvent>'
                cXMLRet += '  <AgriculturalGeneticEventCode>' + _NoTags(NCM->NCM_CODREG) + '</AgriculturalGeneticEventCode>'
                cXMLRet += '  <AgriculturalGeneticEventInternalId>' + IIF(Empty(NCM->NCM_CODREG),'' ,RTrim(AP030IntId(, NCM->NCM_CODREG))) + '</AgriculturalGeneticEventInternalId>'
                cXMLRet += '</AgriculturalGeneticEvent>'
                NCM->(dbSkip())
            EndDo
            cXMLRet += '</ListOfAgriculturalGeneticEvent>'
        Else
            cXMLRet += '<ListOfAgriculturalGeneticEvent/>'
        Endif

        // Tecnologia de variedade.
        NCM->(dbSetOrder(1))  // NCM_FILIAL, NCM_PROD, NCM_ALIAS, NCM_FILREG, NCM_CODREG.
        If NCM->(msSeek(xFilial() + cCodProd + "NCA", .F.))
            cXMLRet += '<ListOfAgriculturalInputTechnology>'
            Do While NCM->(!eof() .and. NCM_FILIAL + NCM_PROD + NCM_ALIAS == xFilial() + cCodProd + "NCA")
                cXMLRet += '<AgriculturalInputTechnology>'
                cXMLRet += '  <AgriculturalInputTechnologyCode>' + _NoTags(NCM->NCM_CODREG) + '</AgriculturalInputTechnologyCode>'
                cXMLRet += '  <AgriculturalInputTechnologyInternalId>' + IIF(Empty(NCM->NCM_CODREG),'' ,RTrim(AP040IntId(, NCM->NCM_CODREG))) + '</AgriculturalInputTechnologyInternalId>'
                cXMLRet += '</AgriculturalInputTechnology>'
                NCM->(dbSkip())
            EndDo
            cXMLRet += '</ListOfAgriculturalInputTechnology>'
        Else
            cXMLRet += '<ListOfAgriculturalInputTechnology/>'
        Endif

        // Sistema de aplicação.
        NCM->(dbSetOrder(1))  // NCM_FILIAL, NCM_PROD, NCM_ALIAS, NCM_FILREG, NCM_CODREG.
        If NCM->(msSeek(xFilial() + cCodProd + "NCO", .F.))
            cXMLRet += '<ListOfAgriculturalApplicationSystem>'
            Do While NCM->(!eof() .and. NCM_FILIAL + NCM_PROD + NCM_ALIAS == xFilial() + cCodProd + "NCO")
                cXMLRet += '<AgriculturalApplicationSystem>'
                cXMLRet += '  <AgriculturalApplicationSystemCode>' + _NoTags(NCM->NCM_CODREG) + '</AgriculturalApplicationSystemCode>'
                cXMLRet += '  <AgriculturalApplicationSystemInternalId>' + IIF(Empty(NCM->NCM_CODREG),'' ,RTrim(AP120IntId(, NCM->NCM_CODREG))) + '</AgriculturalApplicationSystemInternalId>'
                cXMLRet += '</AgriculturalApplicationSystem>'
                NCM->(dbSkip())
            EndDo
            cXMLRet += '</ListOfAgriculturalApplicationSystem>'
        Else
            cXMLRet += '<ListOfAgriculturalApplicationSystem/>'
        Endif
    Endif
    
Return cXMLRet

