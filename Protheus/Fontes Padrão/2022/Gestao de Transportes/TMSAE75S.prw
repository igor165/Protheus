#INCLUDE "Protheus.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ TMSAE75S    ³ Autor ³ Daniel Leme        ³ Data ³16/05/2022³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Schedule de EDI Automáticoe								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function TMSAE75S()
Local cQuery	:= ""
Local cAliasQry	:= GetNextAlias()

cQuery := " SELECT DE5_CGCREM "
cQuery += " FROM " + RetSqlName("DE5") + " DE5 "
cQuery += " WHERE DE5.DE5_FILIAL = '"+xFilial("DE5")+"'"
cQuery += "   AND DE5.DE5_CGCREM BETWEEN '"+mv_par01+"' AND '"+mv_par02+"'"
cQuery += "   AND DE5.DE5_CGCDES BETWEEN '"+mv_par03+"' AND '"+mv_par04+"'"
cQuery += "   AND DE5.DE5_STATUS <> '2'"
//-- Somente DE5 não processadas no Scheduller
cQuery += "   AND DE5.DE5_STAUTO IN(' ','0' ) "
cQuery += "   AND DE5.DE5_FILORI = '"+cFilAnt+"' "
cQuery += "   AND DE5.D_E_L_E_T_ = ' '"
cQuery += " GROUP BY DE5_CGCREM "

cQuery := ChangeQuery(cQuery)
DbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery), cAliasQry, .F., .T. )

//-- Processa um Remetente por vez, quando JOB
While (cAliasQry)->(!Eof())	
	If LockByName("SIGATMS_EDI75_" + AllTrim((cAliasQry)->DE5_CGCREM), .T.,.F.)   
        mv_par01 := (cAliasQry)->DE5_CGCREM
        mv_par02 := (cAliasQry)->DE5_CGCREM
        mv_par05 := 2 //-- Não seleciona as NF's
        TMSAE75Prc(,.T.)

		UnLockByName("SIGATMS_EDI75_" + AllTrim((cAliasQry)->DE5_CGCREM), .T.,.F.)  
	EndIf	
	(cAliasQry)->(dbSkip())
EndDo

(cAliasQry)->(DbCloseArea())

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ Scheddef    ³ Autor ³ Daniel Leme        ³ Data ³15/05/2022³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Função Schedule  										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function SchedDef()
Local aParam
Local cPerg     := "TMSAE75"

aParam := {"P",;  	//Tipo R para relatorio P para processo   
		   cPerg,;		// Pergunte do relatorio, caso nao use passar ParamDef            
		   "DE5",;  // Alias            
		   ,;   	//Array de ordens   
		   'Schedule - EDI Automático'} //--> Schedule - Repom   

Return aParam
