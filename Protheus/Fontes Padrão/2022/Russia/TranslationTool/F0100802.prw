#INCLUDE "PROTHEUS.CH"
#INCLUDE "TBICONN.CH"

/** Aplica as traduções no flavour
 */

User Function F0100800()

    DEFINE MSDIALOG oDlg TITLE "Flavour Update" FROM 000, 000 TO 150, 500 PIXEL

    @018, 015 SAY "Flavour Update" SIZE 300, 300 OF oDlg PIXEL

    DEFINE SBUTTON FROM 060, 010 TYPE 1 ACTION (U_F0100802(), oDlg:End())                        ENABLE OF oDlg
    DEFINE SBUTTON FROM 060, 215 TYPE 2 ACTION (MsgAlert("Canceled"), oDlg:End())  ENABLE OF oDlg

    ACTIVATE MSDIALOG oDlg CENTERED

Return


User Function F0100802()
    
    Local cAliasZA1 := GetNextAlias()
    Local aKey      := {}

    InitProc()
    
    BeginSQL Alias cAliasZA1
        SELECT ZA1.R_E_C_N_O_ ZA1REC
          FROM %Table:ZA1% ZA1
         WHERE ZA1_STATUS  = '4'
           AND ZA1_APLICA != '1'
           AND ZA1_IDIOM   = 'ru'
           AND ZA1.%NotDel%
        ORDER BY ZA1_ORIGIN, ZA1_SEEK
    EndSQL

    While (cAliasZA1)->(!EoF())
        ZA1->(DbGoTo((cAliasZA1)->ZA1REC))

        If ApplyTrans(ZA1->ZA1_ORIGIN, RTrim(ZA1->ZA1_SEEK), ZA1->ZA1_NEWTEX)
            cHistory := U_ZA1Hist("Translation '" + RTrim(ZA1->ZA1_NEWTEX) + "' applied in flavour." )
        Else 
            aKey := { RTrim(ZA1->ZA1_KEY1) , ; 
                      RTrim(ZA1->ZA1_KEY2) , ; 
                      RTrim(ZA1->ZA1_KEY3) , ; 
                      RTrim(ZA1->ZA1_KEY4) , ; 
                      RTrim(ZA1->ZA1_KEY5)  }

            SaveFlvKey(ZA1->ZA1_ORIGIN, aKey, ZA1->ZA1_FLAV, ZA1->ZA1_IDIOM, ZA1->ZA1_NEWTEX)
            
            cHistory := U_ZA1Hist("Flavour for translation '" + RTrim(ZA1->ZA1_NEWTEX) + "' created." )
        EndIf

        RecLock("ZA1", .F.)
        ZA1->ZA1_APLICA := "1"
        ZA1->ZA1_HIST   := cHistory
        ZA1->(MsUnlock())

        (cAliasZA1)->(DbSkip())
    End
    
    ClearGLBVALUE('*')
    
    ClearProc()

Return


Static Function ApplyTrans(cOrigin, cSeekKey, cTranslation) As Logical

    Local cFlvAlias := GetFlvAlias(cOrigin)
    Local cTrans1   := ""
    Local cTrans2   := ""
    Local lSuccess  := .F.
    Local cFlvAlias := GetFlvAlias(cOrigin)

   	cSeekKey := GetSeekKey(cFlvAlias)
    
    If (cFlvAlias)->(DbSeek(cSeekKey))
        RecLock(cFlvAlias, .F.)

        If (cFlvAlias)->(FieldPos(cFlvAlias + "_TEXT2"))
            cTrans1 := SubStr(cTranslation, 1, Len((cFlvAlias)->(FieldGet(FieldPos(cFlvAlias + "_TEXT1")))))
            cTrans2 := SubStr(cTranslation, Len(cTrans1) + 1)
            FieldPut(FieldPos(cFlvAlias + "_TEXT1"), cTrans1)
            FieldPut(FieldPos(cFlvAlias + "_TEXT2"), cTrans2)
        Else
            FieldPut(FieldPos(cFlvAlias + "_TEXT"), cTranslation)
        EndIf
        
        (cFlvAlias)->(MsUnlock())
    
        lSuccess  := .T.

    EndIf

    
Return lSuccess

Static Function GetFlvAlias(cOrigin) As Character
    
    Local nPosAlias := 0
    Local aAlias := {;
                        {"1", "XXG"},;
                        {"2", "XXI"},;
                        {"3", "XXK"},;
                        {"5", "XXL"},;
                        {"6", "XXM"},;
                        {"A", "XXN"},;
                        {"B", "XXO"},;
                        {"G", "XXQ"},;
                        {"S", "XXR"},;
                        {"M", "XXS"},;
                        {"H", "XAB"};
                    }

    nPosAlias := AScan(aAlias, {|aOrigin| aOrigin[1] == cOrigin })

Return aAlias[nPosAlias, 2]

Static Function SaveFlvKey(cOrigin, aKey, cFlavour, cIdiom, cTranslation)

    Local nFieldLen := 0
    Local cFlvAlias := GetFlvAlias(cOrigin)

    RecLocK(cFlvAlias, .T.)
    FieldPut(FieldPos(cFlvAlias + "_CODFLA"), cFlavour)
    FieldPut(FieldPos(cFlvAlias + "_IDIOM") , cIdiom  )

    If FieldPos(cFlvAlias + "_TEXT1") > 0
        nFieldLen := Len(&(cFlvAlias + "_TEXT1"))
        FieldPut(FieldPos(cFlvAlias + "_TEXT1") , SubStr(cTranslation, 1            , nFieldLen ))
        FieldPut(FieldPos(cFlvAlias + "_TEXT2") , SubStr(cTranslation, nFieldLen + 1))
    Else
        FieldPut(FieldPos(cFlvAlias + "_TEXT") , cTranslation)
    EndIf

	Do Case
		Case cFlvAlias == "XXR"
            XXR->XXR_PROGRA := aKey[1] + ".CH"
            XXR->XXR_CHAVE  := "STR" + aKey[2]
            XXR->XXR_ATTRIB := "ZB1_TXTPOR"
            XXR->XXR_SIZETX := Len(cTranslation)
		Case cFlvAlias == "XXI"
            XXI->XXI_ALIAS  := aKey[1]
            XXI->XXI_ATTRIB := aKey[2]
		Case cFlvAlias == "XXK"
            XXK->XXK_CAMPO := aKey[1]
            XXK->XXK_ATTRIB := aKey[2]
		Case cFlvAlias == "XXL"
            XXL->XXL_TABELA := aKey[1]
            XXL->XXL_CHAVE  := aKey[2]
            XXL->XXL_ATTRIB := aKey[3]
		Case cFlvAlias == "XXG"
            XXG->XXG_GRUPO  := aKey[1]
            XXG->XXG_IDFIL  := aKey[2]
            XXG->XXG_ORDEM  := aKey[3]
            XXG->XXG_ATTRIB := aKey[4]
		Case cFlvAlias == "XXM"
            XXM->XXM_VAR    := aKey[1]
            XXM->XXM_ATTRIB := aKey[2]
		Case cFlvAlias == "XXN"
            XXN->XXN_ALIAS  := aKey[1]
            XXN->XXN_AGRUP  := aKey[2]
            XXN->XXN_ORDEM  := aKey[3]
            XXN->XXN_ATTRIB := aKey[4]
		Case cFlvAlias == "XXO"
            XXO->XXO_CODSXB := aKey[1]
            XXO->XXO_TIPO   := aKey[2]
            XXO->XXO_SEQ	:= aKey[3]
            XXO->XXO_COLUNA := aKey[4]
            XXO->XXO_ATTRIB := aKey[5]
		Case cFlvAlias == "XXQ"
            XXQ->XXQ_GRUPO  := aKey[1]
            XXQ->XXQ_ATTRIB := aKey[2]
		Case cFlvAlias == "XXS"
            XXS->XXS_CODIGO := aKey[1]
            XXS->XXS_ATTRIB := aKey[2]
		Case cFlvAlias == "XAB"
            XAB->XAB_CODHLS := aKey[1]
            XAB->XAB_ATTRIB := aKey[2]
	EndCase

    MsUnlock()

Return

Static Function GetSeekKey(cTab)
	Local cRet	:=	""
	Do Case
		Case cTab == 'XXR'
		/*cRet	:=	ZA1->ZA1_FLAV + PadR( ALLTRIM(ZA1->ZA1_KEY1) + ".CH", Len( XXR->XXR_PROGRA )) + ;
		PadR( 'STR'+ALLTRIM(ZA1->ZA1_KEY2), Len( XXR->XXR_CHAVE )) + ;		
		"ZB1_TXTPOR" + ZA1->ZA1_IDIOM*/
		cRet	:=	ZA1->ZA1_FLAV + PadR( ALLTRIM(ZA1->ZA1_KEY1) + ".CH", Len( XXR->XXR_PROGRA )) + ;
		PadR( ALLTRIM(ZA1->ZA1_KEY3	), Len( XXR->XXR_CHAVE )) + ;		
		"ZB1_TXTPOR" + ZA1->ZA1_IDIOM
		  
		Case cTab == 'XXI'
		cRet	:=	ZA1->ZA1_FLAV +PadR( ALLTRIM(ZA1->ZA1_KEY1), Len( XXI->XXI_ALIAS )) + PadR( ALLTRIM(ZA1->ZA1_KEY2), 10 ) + ZA1->ZA1_IDIOM  
		Case cTab == 'XXK'
		cRet	:=	ZA1->ZA1_FLAV+ PadR( ALLTRIM(ZA1->ZA1_KEY1), Len( XXK->XXK_CAMPO )) + PadR( ALLTRIM(ZA1->ZA1_KEY2), 10 ) + ZA1->ZA1_IDIOM  					 
		Case cTab == 'XXL'
		cRet	:=	ZA1->ZA1_FLAV + PadR( ALLTRIM(ZA1->ZA1_KEY1), Len( XXL->XXL_TABELA )) + PadR( ALLTRIM(ZA1->ZA1_KEY2), Len( XXL->XXL_CHAVE )) + PadR( ALLTRIM(ZA1->ZA1_KEY3), 10 ) + ZA1->ZA1_IDIOM   
		Case cTab == 'XXG'
		cRet	:=	ZA1->ZA1_FLAV + PadR( ALLTRIM(ZA1->ZA1_KEY1), Len( XXG->XXG_GRUPO )) + ;
		PadR( ALLTRIM(ZA1->ZA1_KEY2), Len( XXG->XXG_IDFIL )) + ;
		PadR( ALLTRIM(ZA1->ZA1_KEY3), Len( XXG->XXG_ORDEM )) + ;
		PadR( ALLTRIM(ZA1->ZA1_KEY4), 10 ) + ZA1->ZA1_IDIOM  
		Case cTab == 'XXM'
		cRet	:= ZA1->ZA1_FLAV + PadR( ALLTRIM(ZA1->ZA1_KEY1), Len( XXM->XXM_VAR )) + PadR( ALLTRIM(ZA1->ZA1_KEY2), 10 ) + ZA1->ZA1_IDIOM  
		Case cTab == 'XXN'
		cRet	:=	ZA1->ZA1_FLAV+ PadR( ALLTRIM(ZA1->ZA1_KEY1), Len( XXN->XXN_ALIAS )) + ;
		PadR( ALLTRIM(ZA1->ZA1_KEY2), Len( XXN->XXN_AGRUP )) + ; 
		PadR( ALLTRIM(ZA1->ZA1_KEY3), Len( XXN->XXN_ORDEM )) + PadR( ALLTRIM(ZA1->ZA1_KEY4), 10 ) + ZA1->ZA1_IDIOM 
		Case cTab == 'XXO'
		cRet	:=	ZA1->ZA1_FLAV+ PadR( ALLTRIM(ZA1->ZA1_KEY1), Len( XXO->XXO_CODSXB )) + ;
		PadR( ALLTRIM(ZA1->ZA1_KEY2), Len( XXO->XXO_TIPO )) + ;
		PadR( ALLTRIM(ZA1->ZA1_KEY3), Len( XXO->XXO_SEQ )) + ;
		PadR( ALLTRIM(ZA1->ZA1_KEY4) , Len( XXO->XXO_COLUNA )) + ;				
		PadR( ALLTRIM(ZA1->ZA1_KEY5), 10 ) + ZA1->ZA1_IDIOM  
		Case cTab == 'XXQ'
		cRet	:=	ZA1->ZA1_FLAV+ PadR( ALLTRIM(ZA1->ZA1_KEY1), Len( XXQ->XXQ_GRUPO )) + PadR( ALLTRIM(ZA1->ZA1_KEY2), 10 ) + ZA1->ZA1_IDIOM  
		Case cTab == 'XXS'
			If !Empty(ZA1->ZA1_KEY1) .and. !Empty(XXS->( IndexKey( 2 ) ) ) 
				cRet	:=	ZA1->ZA1_FLAV + PadR( ALLTRIM(ZA1->ZA1_KEY1), Len( XXS->XXS_ID )) + ;
				PadR( ALLTRIM(ZA1->ZA1_KEY2), 10 ) + ZA1->ZA1_IDIOM
			Else
				cRet	:=	ZA1->ZA1_FLAV + PadR( ALLTRIM(ZA1->ZA1_KEY3), Len( XXS->XXS_CODIGO )) + ;
				PadR( ALLTRIM(ZA1->ZA1_KEY2), 10 ) + ZA1->ZA1_IDIOM
			Endif	  
		Case cTab == 'XAB'
			cRet	:= ZA1->ZA1_FLAV+ PadR( ALLTRIM(ZA1->ZA1_KEY1), Len( XAB->XAB_CODHLS )) + ;
		PadR(ALLTRIM(ZA1->ZA1_KEY2), Len( XAB->XAB_ATTRIB )) + ZA1->ZA1_IDIOM  
	EndCase				

Return cRet

Static Function InitProc(aEmp)

    Default aEmp := {"99", "01"}

    Static lInitialize := .F.

    If Select("SX2") == 0
        lInitialize := .T.
        RPCSetEnv(aEmp[1], aEmp[2])
    EndIf

Return

Static Function ClearProc()

    If lInitialize 
	    RpcClearEnv()
        lInitialize := Nil
    EndIf

Return
// Russia_R5
