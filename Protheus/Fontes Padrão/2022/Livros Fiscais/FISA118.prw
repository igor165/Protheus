#Include 'Protheus.ch'
#Include 'FISA118.ch'

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ReProc118    ºAutor  ³Henrique Pereira º Data ³  02/03/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Reprocessamento da tabela CFF para notas que ainda não      º±±
±±º          ³possuem a tabela CFF populada e estão no renge de notas     º±±
±±º          ³selecionados via parâmetros desta rotina                    º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FISA118()
Local cTitulo   := STR0001
Local nOpc      := 0
Local cDatade   := ""
Local cDataAte  := ""
Local cNfDe     := ""
Local cNfAte    := ""
Local cSerDe    := ""
Local cSerAte   := ""
Local cPerg	  := "MTACFF"
Local aFilial   := {}
Local nX		  := 0
Local lSelFil   := .F.
Local aAreaSM0 := {}

If GetRpoRelease()$"12.1.016|12.1.014|12.1.007"
	DbSelectArea("SIX")
	DbSetOrder(1)
	
	If !MsSeek("CFF" + "3")		//Caso não exista indice não processa CAT207
		Alert("Dicionário de dados desatualizado, Atualizar base de dados disponibilizado na Issue: DSERFIS2-814 ")
		Return
	EndIf
Endif
While .t.
   DEFINE MSDIALOG oDlg TITLE OemtoAnsi(cTitulo) FROM  165,145 TO 315,495 PIXEL OF oMainWnd
	@ 03, 10 TO 43, 165 LABEL "" OF oDlg  PIXEL
	@ 10, 15 SAY OemToAnsi(STR0002)  SIZE 150, 8 OF oDlg PIXEL
	@ 20, 15 SAY OemToAnsi(STR0003) SIZE 150, 8 OF oDlg PIXEL
	@ 30, 15 SAY OemToAnsi(STR0004)    SIZE 150, 8 OF oDlg PIXEL
	DEFINE SBUTTON FROM 50, 082 TYPE 5 ACTION (nOpc:=1,oDlg:End()) ENABLE OF oDlg
	DEFINE SBUTTON FROM 50, 111 TYPE 2 ACTION (nOpc:=2,oDlg:End()) ENABLE OF oDlg
	ACTIVATE MSDIALOG oDlg
  
   
   Do Case
		Case nOpc==1
			Pergunte(cPerg)
			lSelFil := (MV_PAR07 == 2) // Seleciona filiais? 1-Não / 2-SIM
			
			 If Empty(MV_PAR01) .Or. Empty(MV_PAR02)
				    MsgInfo(STR0005) 
				    nOpc :=0
			 Else 
			 	If lSelFil
			 	   aAreaSM0 := SM0->(GetArea())
			 	   aFilial := MatFilCalc(.T.)
					  For nX := 1 to Len(aFilial)
					     If aFilial[nX][1] 			     
						     If SM0->(dbSeek(cEmpAnt+aFilial[nX][2],.T.))
						     	  cFilAnt := aFilial[nX][2]	       
						         Proc118(cPerg)
						     EndIf
						     
					     EndIf
					  Next nX
					  RestArea (aAreaSM0)
                    cFilAnt := FwCodFil()
					  SM0->(dbSeek(cEmpAnt+cFilant,.T.))
				Else
				      MsgInfo(STR0006)
				      Proc118(cPerg)
				EndIf
			 EndIf
			 
		Case nOpc==2
			EXIT
			nOpc :=0
	EndCase
    EXIT
EndDo
Return

Function Proc118()
Local cDatade   := MV_PAR01
Local cDataAte  := MV_PAR02
Local cNfDe     := MV_PAR03
Local cNfAte    := MV_PAR04
Local cSerDe    := MV_PAR05
Local cSerAte   := MV_PAR06
Local cAliasQry := "SF2"
Local cChavSF2  := ""
Local lCmpCFF   := CFF->(FieldPos('CFF_TIPO')) > 0

DbSelectArea("SF4")
DbSetOrder(1)

			BeginSql Alias cAliasQry
							
				SELECT 
					SF2.F2_DOC, SF2.F2_SERIE, SF2.F2_CLIENTE, SF2.F2_LOJA,SF2.F2_EST, SD2.D2_TES, SD2.D2_ITEM
				FROM
				%table:SF2% SF2 
				INNER JOIN %Table:SD2% SD2 ON (	SD2.D2_DOC    = SF2.F2_DOC
													AND SD2.D2_SERIE  = SF2.F2_SERIE
													AND SD2.D2_FILIAL =  %xFilial:SD2%)
				INNER JOIN %Table:SF4% SF4 ON (SF4.F4_CODIGO = SD2.D2_TES
											AND SF4.F4_FILIAL  = %xFilial:SF4% 
											AND SF4.F4_CRDACUM = '1' )
				
				WHERE
				SF2.F2_FILIAL = %xFilial:SF2% AND
				SF2.F2_EMISSAO BETWEEN %Exp:cDatade%  AND %Exp:cDataAte% AND
				SF2.F2_DOC     BETWEEN %Exp:cNfDe%          AND %Exp:cNfAte% AND
				SF2.F2_SERIE   BETWEEN %Exp:cSerDe%         AND %Exp:cSerAte% AND
				SF2.%NotDel% AND SD2.%NotDel%
				ORDER BY SD2.D2_ITEM 
				 
			EndSql
DbSelectArea(cAliasQry) 
(cAliasQry)->(DbGoTop())
While (cAliasQry)->(!EoF())     
    If SF4->(dBseek(xFilial("SF4")+(cAliasQry)->D2_TES))
		 cChavSF2 := xFilial("CFF")+(cAliasQry)->(F2_DOC+F2_SERIE+F2_CLIENTE+F2_LOJA)

		If lCmpCFF
			cChavSF2 += 'S'+SD2->D2_TIPO
		EndIf

		 nItNF	   := (cAliasQry)->D2_ITEM
		 FisGrvCFF(nil, cChavSF2, nItNF, .T.)	     
    EndIf    
	(cAliasQry)->(dbSkip())	 
EndDo

DbSelectArea("SF4")
SF4->(DbCloseArea())
(cAliasQry)->(DbCloseArea())
MsgInfo(STR0007)
Return 
