#include "Protheus.ch"
#include "OMSA110.CH"

/*/{Protheus.doc} MenuDef
** Funcao reescrita para nao chamar menu def do MATXATU
@author Equipe OMS
@since 03/03/2022
/*/
Static Function MenuDef()
	Local aRotina

	aRotina := { { oemtoansi(STR0002),"AxPesqui", 0 , 1,,.F.},; // "Pesquisar"
	{ oemtoansi(STR0003),"AxCadVis", 0 , 2},; // "Visualizar"
	{ oemtoansi(STR0004),"AxCadInc", 0 , 3},; //"Incluir"
	{ oemtoansi(STR0005),"AxCadAlt", 0 , 4},; //"Alterar"
	{ oemtoansi(STR0006),"AxCadDel", 0 , 5}}  //"Excluir"
Return aRotina

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OMSA110  ³ Autor ³ Henry Fila            ³ Data ³ 30.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Nome Orig.³ DFATA08  ³                                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Cadastro de Grupos de Veiculos                             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APDL                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Revis„o  ³                                          ³ Data ³          ³±±
±±³          ³                                          ³      ³          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function OMSA110()
AxCadastro("DAC",OemToAnsi(STR0001),'A110Vdel()')	//"Cadastro de Grupos de Veiculos"
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ A110VDEL ³ Autor ³ Henry Fila            ³ Data ³ 30.04.02 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Validacao da exclusao do cadastro de grupos de veiculos    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ APDL                                                       ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Revis„o  ³                                          ³ Data ³          ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function A110Vdel()

#IFDEF TOP
	Local lQuery    := .F.     
	Local cQuery    := ""
	Local cAlias    := ""
#ENDIF

Local cInd      := ""
Local cCondicao := ""      
Local cKey      := ""

Local nInd      := 0

Local lRet      := .T.
Local lField    := DA3->(FieldPos("DA3_CODGRU")) > 0
If lField

	#IFDEF TOP
		If TcSrvType() <> "AS/400"
		
			lQuery := .T.                                              
			cAlias := "QRYDA3"
			
			cQuery := "SELECT COUNT(*) RECDA3 FROM "+RetSqlName("DA3")+ " DA3 "
			cQuery += "WHERE "
			cQuery += "DA3_FILIAL = '"+xFilial("DA3")+"' AND "		
			cQuery += "DA3_CODGRU = '"+DAC->DAC_CODGRU+"' AND "
			cQuery += "DA3.D_E_L_E_T_ = ' '"
			
			cQuery := ChangeQuery(cQuery)
			
			dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),cAlias,.F.,.T.)
			
			If (cAlias)->RECDA3 > 0
				Help(" ",1,"OMS110DEL")
				lRet := .F.
			Endif
			
			dbSelectArea(cAlias)
			dbCloseArea()
			dbSelectArea("DA3")			
		Else
	#ENDIF
	
	        dbSelectArea("DA3")
	        dbSetOrder(1)
	        MsSeek(xFilial("DA3"))
	        
	        While !Eof() .And. DA3-> DA3_FILIAL = xFilial("DA3") .And. lRet
	
				If DA3->DA3_CODGRU == DAC->DAC_CODGRU
					Help(" ",1,"OMS110DEL")			
					lRet := .F.
				Endif				
	             
	        	dbSelectArea("DA3")
	        	dbSkip()
	
	        EndDo
	#IFDEF TOP
		Endif
	#ENDIF	

Endif
	
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se existe Regras de Entrega                      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
#IFDEF TOP
	If TcSrvType() != "AS/400"
	
		cQuery := "SELECT COUNT(*) QTDREGRA "
		cQuery += " FROM " + RetSqlName("DAE")+ " DAE "
		cQuery += " WHERE "
		cQuery += " DAE_FILIAL = '"+xFilial("DAE")+"' AND "
		cQuery += " DAE_GRUVEI = '"+DAC->DAC_CODGRU+"' AND "
		cQuery += " DAE.D_E_L_E_T_ = ' ' "
		
		cQuery := ChangeQuery(cQuery)
		dBUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"QRYVAL",.F.,.T.)
		lQuery := .T.
		
        If QRYVAL->QTDREGRA > 0
	       	Help(" ",1,"NODELETA") //Nao e possivel excluir o ajudante pois o mesmo encontras-se relacionado a outros cadastro ### INCLUIR ATUSX
			lRet := .F.				
		Endif	        	
	
		dbSelectArea("QRYVAL")
		dbCloseArea()
		dbSelectArea("DAE")
	
	Else
#ENDIF
	
		dbSelectArea("DAE")
		dbSetOrder(1)
		cInd := CriaTrab(NIL,.F.)
	
		cKey := IndexKey()
		cCondicao := 'DAE_FILIAL == "'+xFilial("DAE")+'" .And.'
		cCondicao += 'DAE_GRUVEI == "'+DAC->DAC_CODGRU+'" '		
	
		IndRegua("DAE",cInd,cKey,,cCondicao) //"Selecionando Registros ..."
		nInd := RetIndex("DAE")
	
		#IFNDEF TOP
			dbSetIndex(cInd+OrdBagExT())
		#ENDIF   	
		dbSetOrder(nInd+1)
		dbGotop()
	
		If DAE->(!Eof())
        	Help(" ",1,"NODELETA") //Nao e possivel excluir o ajudante pois o mesmo encontras-se relacionado a outros cadastro ### INCLUIR ATUSX
			lRet := .F.				
		Endif
	
		dbSelectArea("DAE")
		dbClearFilter()
		RetIndex("DAE")
		Ferase(cInd+OrdBagExt())
		
#IFDEF TOP
	Endif
#ENDIF		
	
Return(lRet)
