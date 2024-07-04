#INCLUDE "CTBSVLD.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "ECD.CH"

//Compatibilização de fontes 30/05/2018

Static lDefTopCtb := IfDefTopCTB()
Static cConcat := ""

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³PreValdEcd³ Rev.  ³Elton C. Santana       ³ Data ³08/02/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a pré-validação 									  ³±±
±±³          ³                                                    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³dDataIni -> Data inicial da escrituração                    ³±±
±±³          ³cCaLend  -> Codigo do calendario                            ³±±
±±³          ³cContaIni-> Conta Inicial                                   ³±±
±±³          ³cContaFim-> Conta Final                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³			                                                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Ecd Contabil			                                 	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PreValdEcd(oProcess,dDataIni,dDataFim,cCalend,cContaIni,cContaFim)
Local aArea    	:= GetArea()
Local nX		:= 0
Local aVldErro 	:= {}
Local aMsgErro	:= {} 

PRIVATE aSelFil		:= {}

DEFAULT dDataIni 	:= cTod(" / / ")
DEFAULT dDataFim 	:= cTod(" / / ")
DEFAULT cContaIni 	:= Space(20)
DEFAULT cContaFim 	:= Replicate( "Z" , 20 )   

DEFAULT oProcess	:= Nil 

IF lDefTopCtb
	EcdNewMsg()//Iinicia a função de mensagem de erros
	
	If Alltrim(TcGetDb()) $ 'MSSQL7/MSSQL' 
		cConcat := "+"
	Else 
		cConcat := "||"	
	EndIf
	
	aSelFil := AdmGetFil()
	If Len( aSelFil ) <= 0
		Return
	EndIf 
	
	ValidPlanoCta(oProcess, aSelFil, cContaIni, cContaFim)
	ValidHistPad(oProcess, aSelFil)
	ValidMoeda(oProcess, aSelFil)
	ValidCalend(oProcess, aSelFil, cCalend)
	ValidContab(oProcess, aSelFil, dDataIni)
	ValidPartic(oProcess, aSelFil, dDataIni)
	ValidPlRef(oProcess, aSelFil)
	ValidLacto(oProcess, aSelFil, dDataIni, dDataFim)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Função (EcdRetMenssag()) que retorna o array com as menssagens de erro  ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	aMsgErro := EcdRetMenssag()
	If !Empty(aMsgErro)
		For nX := 1 To Len(aMsgErro)     
	    	aAdd(aVldErro, aMsgErro[nX][1])
		Next
	EndIf
Else
	MsgAlert( 'Essa rotina somente é suportadas por ambientes TopConnect/DbAcess.' )
Endif

RestArea( aArea )

Return aVldErro

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ValidPlanoCta³ Rev.  ³Elton C. Santana    ³ Data ³08/02/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a pré-validação do plano de Contas					  ³±±
±±³          ³                                                    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cContaIni-> Conta Inicial                                   ³±±
±±³          ³cContaFim-> Conta Final                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³array		                                                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Ecd Contabil 			                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPlanoCta(oProcess, aSelFil, cContaIni, cContaFim)
Local aArea    	:= GetArea()
Local nx		:= 0
Local aStruct	:= {}
Local cQuery	:= ""
Local cQuerCount:= ""
Local cAliasCT1	:= "CT1"
Local cCt1Count := "CT1"
Local lErro		:= .F.
Local lErroPai	:= .F.

DEFAULT cContaIni := Space(20)
DEFAULT cContaFim := Replicate( "Z" , 20 )

If oProcess <> Nil
	oProcess:IncRegua1( STR0010 ) 
	oProcess:SetRegua2(0)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query -Verifica se existe registro na tabela    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuerCount := "SELECT COUNT(CT1_FILIAL) CT1COUNT";
		+ " FROM " + RetSqlName( "CT1" ) + " CT1 ";
		+ " WHERE D_E_L_E_T_ = '' ";
		+ "	AND CT1_FILIAL " + GetRngFil( aSelFil ,"CT1")

cQuerCount := ChangeQuery(cQuerCount)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera um novo alias  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCt1Count := GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a query     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuerCount) , cCt1Count,.T.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe registro na tabela de acordo com o retorno da query   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cCt1Count)->(Eof()) .Or. (cCt1Count)->CT1COUNT <= 0
	lErro := .T.
	EcdAddMsg(STR0001) //"CT1-> NÃO EXISTE PLANO DE CONTAS CADASTRADO"
EndIf

(cCt1Count)->( dbCloseArea() )

If !lErro
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query utilizada para efetuar a validação do Plano de Contas		 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CT1.CT1_FILIAL, CT1.CT1_CONTA, CT1.CT1_DESC01, CT1.R_E_C_N_O_ ";
				 + ", 'CT1' TABELA";
				 + ", 'O CAMPO CT1_CLASSE OU O CAMPO CT1_NTSPED ESTÃO COM O VALOR ZERADO OU DIFERENTE DO PADRAO DO SISTEMA' MSG";
	   			+ " FROM " + RetSqlName( "CT1" ) + " CT1 ";
			+ "WHERE (CT1_CLASSE <> '1' And CT1_CLASSE <> '2' ) Or (CT1_NTSPED = ' ') ";
			+ " AND CT1.CT1_FILIAL " + GetRngFil( aSelFil ,"CT1");
			+ " AND CT1.CT1_CONTA >= '"+cContaIni+"' ";
			+ " AND CT1.CT1_CONTA <= '"+cContaFim+"' ";
			+ " AND CT1.D_E_L_E_T_ = ' ' ";
			+ " ORDER BY CT1.CT1_CONTA"   
	
	cQuery := ChangeQuery(cQuery)
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera um novo alias  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasCT1 := GetNextAlias()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a query     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCT1,.T.,.T.)
	
	aStruct   := CT1->(dbStruct())
	
	For nX := 1 To Len(aStruct)
		If aStruct[nX][2] <> "C" 	//.And. FieldPos(aStruct[nX][1])<>0
			TcSetField(cAliasCT1,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
		EndIf
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existem registros incorretos, de acordo com o retorno da query³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While (cAliasCT1)->( !Eof() )
		If !lErroPai
			EcdAddMsg( "ERRO: " + (cAliasCT1)->MSG )
			lErroPai := .T.
		EndIf
		
		If oProcess <> Nil 
			oProcess:IncRegua2(STR0011 + (cAliasCT1)->CT1_CONTA) 
		EndIf
	
		EcdAddMsg( "FILIAL: " + (cAliasCT1)->CT1_FILIAL  + " | REGISTRO: " + STR((cAliasCT1)->R_E_C_N_O_) + " | CONTA: " + Alltrim( (cAliasCT1)->CT1_CONTA ) + "-" + (cAliasCT1)->CT1_DESC01 )
		
		dbSelectArea(cAliasCT1)
		dbSkip()
	EndDo
	
	(cAliasCT1)->( dbCloseArea() )
Endif
	
RestArea( aArea )

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ValidHistPad ³ Rev.  ³Elton C. Santana    ³ Data ³08/02/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a pré-validação do Historico Padrao 				  ³±±
±±³          ³                                                    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                      							          ³±±
±±³          ³						                            		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³array		                                                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Ecd Contabil			                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidHistPad(oProcess, aSelFil)
Local aArea    	:= GetArea()
Local cQuery	:= ""
Local cAliasCT8	:= "CT8"

Default oProcess := Nil

If oProcess <> Nil
	oProcess:IncRegua1( STR0012 ) 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query -Verifica se existe registro na tabela    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT COUNT(CT8_FILIAL) CT8COUNT ";
   			+ " FROM " + RetSqlName( "CT8" ) + " CT8 ";
		+ " WHERE D_E_L_E_T_ = '' ";
		+ "	AND CT8_FILIAL " + GetRngFil( aSelFil ,"CT8")
		
cQuery := ChangeQuery(cQuery)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera um novo alias  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasCT8 := GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a query     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCT8,.T.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe registro na tabela de acordo com o retorno da query   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cAliasCT8)->(Eof()) .Or. (cAliasCT8)->CT8COUNT <= 0
	//Adiciona menssagem de erro
	EcdAddMsg(STR0002)//"CT8-> NAO EXISTE HISTORICO CADASTRADO"
EndIf

(cAliasCT8)->( dbCloseArea() )
dbSelectArea("CT8")

RestArea( aArea )

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ValidMoeda³ Rev.  ³Elton C. Santana       ³ Data ³08/02/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a pré-validação da Moeda 				  			  ³±±
±±³          ³                                                    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                      							          ³±±
±±³          ³						                            		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³array		                                                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Ecd Contabil			                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidMoeda(oProcess, aSelFil)
Local aArea    	:= GetArea()
Local cQuery	:= ""
Local cAliasCTO	:= "CTO"

Default oProcess := Nil

If oProcess <> Nil 
	oProcess:IncRegua1(STR0013)
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query - Verifica se existe registro na tabela   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuery := "SELECT COUNT(CTO_FILIAL) CTOCOUNT";
   			+ " FROM " + RetSqlName( "CTO" ) + " CTO ";
		+ " WHERE D_E_L_E_T_ = '' ";
		+ "	AND CTO_FILIAL " + GetRngFil( aSelFil ,"CTO") 
		
cQuery := ChangeQuery(cQuery)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera um novo alias  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cAliasCTO := GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a query     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCTO,.T.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe registro na tabela de acordo com o retorno da query   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cAliasCTO)->(Eof()) .Or. (cAliasCTO)->CTOCOUNT <= 0
	//Adiciona menssagem de erro
	EcdAddMsg(STR0003)//"CTO-> NAO EXISTE MOEDA CADASTRADA"
EndIf

(cAliasCTO)->( dbCloseArea() )
dbSelectArea("CTO")

RestArea( aArea )

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ValidCalend ³ Rev.  ³Elton C. Santana     ³ Data ³08/02/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a pré-validação do calendario						  ³±±
±±³          ³                                                    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cContaIni-> Conta Inicial                                   ³±±
±±³          ³cContaFim-> Conta Final                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³array		                                                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Ecd Contabil		  		                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidCalend(oProcess, aSelFil, cCalend)
Local aArea    	:= GetArea()
Local nx		:= 0
Local aStruct	:= {}
Local cQuery	:= ""
Local cQuerCount:= ""
Local cAliasCTG	:= "CTG"
Local cCtGCount := "CTG"
Local aRet		:= {}
Local lErro		:= .F.

Default cCalend := ""

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query -Verifica se existe registro na tabela    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuerCount := "SELECT COUNT(CTG_FILIAL) CTGCOUNT";
			+ " FROM " + RetSqlName( "CTG" ) + " CTG ";
			+ " WHERE D_E_L_E_T_ = '' ";
			+ "	AND CTG_FILIAL " + GetRngFil( aSelFil ,"CTG") 

cQuerCount := ChangeQuery(cQuerCount)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera um novo alias  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCtGCount := GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a query     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuerCount) , cCtGCount,.T.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe registro na tabela de acordo com o retorno da query   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cCtGCount)->(Eof()) .Or. (cCtGCount)->CTGCOUNT <= 0
	aAdd(aRet,STR0004) //"CTG-> NÃO EXISTE CADASTRO DE CALENDARIO"
	lErro := .T.
Endif

(cCtGCount)->( dbCloseArea() )

If !lErro
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query utilizada para efetuar a validação do Calendario Contabil	 ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CTG.CTG_FILIAL, CTG.CTG_EXERC, CTG.CTG_PERIOD, CTG.CTG_DTINI, CTG.CTG_DTFIM";
			+ "  FROM " + RetSqlName( "CTG" ) + " CTG ";
			+ " WHERE CTG.CTG_CALEND = '"+cCalend+"'";
			+ "   AND CTG.CTG_FILIAL " + GetRngFil( aSelFil ,"CTG") ;
			+ "   AND CTG.D_E_L_E_T_ = ' ' ";
			+ " ORDER BY CTG.CTG_PERIOD"

	cQuery := ChangeQuery(cQuery)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera um novo alias  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasCTG := GetNextAlias()

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a query     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCTG,.T.,.T.)

	aStruct   := CTG->(dbStruct())

	For nX := 1 To Len(aStruct)
		If aStruct[nX][2] <> "C" 	// .And. FieldPos(aStruct[nX][1])<>0
			TcSetField(cAliasCTG,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
		EndIf
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existem registros incorretos, de acordo com o retorno da query³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea(cAliasCTG)
	While (cAliasCTG)->( !Eof() )

		aAdd(aRet,"CTG-> " + (cAliasCTG)->CTG_PERIOD)

		dbSelectArea(cAliasCTG)
		dbSkip()
	EndDo

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se todos os meses do calendario estao preenchidos³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If !Empty(aRet)
		If Len(aRet)<12
			aRet:={}
			aAdd(aRet,STR0005) //"CTG-> CALENDÁRIO CONTÁBIL DEVE TER 12 PERIODOS"
		Else
			aRet:={}
		EndIf
		For nX := 1 To Len(aRet)
			//Adcionando menssagem de erro
			EcdAddMsg(aRet[nX])
		Next
	EndIf

	(cAliasCTG)->( dbCloseArea() )
	dbSelectArea("CTG")
Endif

RestArea( aArea )

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³VaLidContab        ³ Rev.³Elton C. Santana ³ Data ³08/02/09 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a pré-validação do contabilista					  ³±±
±±³          ³                                                    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³dDataIni-> Data inicial	                                  ³±±
±±³          ³                          						          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³array		                                                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Ecd Contabil			                                  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function VaLidContab(oProcess, aSelFil, dDataIni)
Local aArea    	:= GetArea()
Local nx		:= 0
Local aStruct	:= {}
Local cQuery	:= ""
Local cQuerCount:= ""
Local cAliasCVB	:= "CVB"
Local cCVBCount := "CVB"
Local cMsgErro	:= ""
Local lErro		:= .F.

Default oProcess := Nil
Default dDataIni := cTod("01/01/" + Year() ) 

If oProcess <> Nil
	oProcess:IncRegua1(STR0014) 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query -Verifica se existe registro na tabela    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuerCount := "SELECT COUNT(CVB_FILIAL) CCVBCOUNT";
   				+ " FROM " + RetSqlName( "CVB" ) + " CVB ";
   				+ " WHERE CVB_FILIAL " + GetRngFil( aSelFil ,"CVB") ;
   				+ "   AND D_E_L_E_T_ = ' '"

cQuerCount := ChangeQuery(cQuerCount)   				

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera um novo alias  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCVBCount := GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a query     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuerCount) , cCVBCount,.T.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe registro na tabela de acordo com o retorno da query   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cCVBCount)->(Eof()) .OR. (cCVBCount)->CCVBCOUNT <= 0
	//Adicionando menssagem de erro
	EcdAddMsg(STR0006)//"CVB-> NÃO EXISTE CADASTRO DE CONTABILISTA"
	lErro := .T.
Endif	

(cCVBCount)->( dbCloseArea() )

IF !lErro
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query utilizada para efetuar a validação dos Contabilista³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CVB.CVB_FILIAL,CVB.CVB_CODCTB, CVB.CVB_NOME, CVB.CVB_DTINI  AS DATA, CVB.R_E_C_N_O_";
			     + ", 'DATA DE INICIO DO CONTABILISTA É MAIOR QUE A DATA DE ESCRITURAÇÃO' MSG";
			+ "  FROM " + RetSqlName( "CVB" ) + " CVB ";
			+ " WHERE CVB.CVB_FILIAL " + GetRngFil( aSelFil ,"CVB") ;
			+ "   AND CVB.CVB_DTINI > '" + dTos(dDataIni) + "'";
			+ "   AND CVB.D_E_L_E_T_ = ' ' "

	cQuery += "UNION ALL "

	cQuery += "SELECT CVB.CVB_FILIAL, CVB.CVB_CODCTB, CVB.CVB_NOME, CVB.CVB_DTINI AS DATA, CVB.R_E_C_N_O_";
				 + ", 'INICIO DO RELACIONAMENTO DO CONTABILISTA NÃO PREENCHIDO' MSG";
			+ "  FROM " + RetSqlName( "CVB" ) + " CVB ";
			+ " WHERE CVB.CVB_FILIAL " + GetRngFil( aSelFil ,"CVB") ;
			+ "   AND CVB.CVB_DTINI = ''";
			+ "   AND CVB.D_E_L_E_T_ = ' ' "

	cQuery += "UNION ALL "

	cQuery += "SELECT CVB.CVB_FILIAL, CVB.CVB_CODCTB, CVB.CVB_NOME, CVB.CVB_DTINI AS DATA, CVB.R_E_C_N_O_";
				 + ", 'CNPJ/CPF DO CONTABILISTA NÃO PREENCHIDO' MSG";
			+ "  FROM " + RetSqlName( "CVB" ) + " CVB ";
			+ " WHERE CVB.CVB_FILIAL " + GetRngFil( aSelFil ,"CVB") ;
			+ "   AND ( CVB.CVB_CGC = '' AND CVB.CVB_CPF = '' )";
			+ "   AND CVB.D_E_L_E_T_ = ' ' "

	cQuery += "UNION ALL "

	cQuery += "SELECT CVB.CVB_FILIAL, CVB.CVB_CODCTB, CVB.CVB_NOME, CVB.CVB_DTINI AS DATA, CVB.R_E_C_N_O_";
				 + ", 'CÓDIGO DE QUALIFICAÇÃO DO CONTABILISTA NÃO PREENCHIDO' MSG";
			+ "  FROM " + RetSqlName( "CVB" ) + " CVB ";
			+ " WHERE CVB.CVB_FILIAL " + GetRngFil( aSelFil ,"CVB") ;
			+ "   AND ( CVB.CVB_ASSIN = '' OR CVB.CVB_QUALIF = '' ) ";
			+ "   AND CVB.D_E_L_E_T_ = ' ' "


	cQuery := ChangeQuery(cQuery)

	// gera um novo alias
	cAliasCVB := GetNextAlias()

	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCVB,.T.,.T.)

	aStruct   := CVB->(dbStruct())

	For nX := 1 To Len(aStruct)
		If aStruct[nX][2] <> "C" 	// .And. FieldPos(aStruct[nX][1])<>0
			TcSetField(cAliasCVB,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
		EndIf
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existem registros incorretos, de acordo com o retorno da query³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While (cAliasCVB)->( !Eof() )
		If (cAliasCVB)->MSG <> cMsgErro
			EcdAddMsg( "ERRO: " + (cAliasCVB)->MSG)
			cMsgErro := (cAliasCVB)->MSG
		EndIf

		If oProcess <> Nil
			oProcess:SetRegua2(0)
			oProcess:IncRegua2( STR0015 + (cAliasCVB)->CVB_CODCTB) //"Cod. do Contabilista : "
		EndIf

		//Adicionando menssagem de erro
		EcdAddMsg( "FILIAL: " + (cAliasCVB)->CVB_FILIAL  + " | REGISTRO: " + STR((cAliasCVB)->R_E_C_N_O_) + " | COD: " + Alltrim( (cAliasCVB)->CVB_CODCTB ) + "-" + (cAliasCVB)->CVB_NOME + " | DT. INICIO: " + DTOC(STOD((cAliasCVB)->DATA)) )

		dbSelectArea(cAliasCVB)
		dbSkip()
	EndDo

	(cAliasCVB)->( dbCloseArea() )
	dbSelectArea("CVB")
Endif

RestArea( aArea )

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ValidPartic ³ Rev.  ³Elton C. Santana     ³ Data ³08/02/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a pré-validação do participante					  ³±±
±±³          ³                                                    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³dDataIni-> Data inicial	                                  ³±±
±±³          ³                          						          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³array		                                                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Ecd Contabil				                                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPartic(oProcess, aSelFil, dDataIni)

Local aArea    	:= GetArea()
Local nx		:= 0
Local aStruct	:= {}
Local cQuery	:= ""
Local cQuerCount:= ""
Local cAliasCVC	:= "CVC"
Local cCVCCount := "CVC"
Local cMsgErro	:= ""
Local lErro		:= .F.

Default oProcess := Nil
Default dDataIni := cTod("01/01/" + Year() ) 

If oProcess <> Nil
	oProcess:IncRegua1( STR0016 )//"Validando Participante"
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query -Verifica se existe registro na tabela    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuerCount := "SELECT COUNT(CVC_FILIAL) CCVCCOUNT";
			+ "  FROM " + RetSqlName( "CVC" ) + " CVC ";
			+ " WHERE CVC_FILIAL " + GetRngFil( aSelFil ,"CVC");
			+ "	  AND D_E_L_E_T_ = ' '"

cQuerCount := ChangeQuery(cQuerCount)   

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera um novo alias  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCVCCount := GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a query     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuerCount) , cCVCCount,.T.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe registro na tabela de acordo com o retorno da query   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cCVCCount)->(Eof()) .OR. (cCVCCount)->CCVCCOUNT <= 0
	//Adcionando menssagem de erro
	EcdAddMsg(STR0007)//"CVC-> NÃO EXISTE CADASTRO DE PARTICIPANTE"
	lErro := .T.
Endif

(cAliasCVC)->( dbCloseArea() )

If !lErro
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query utilizada para efetuar a validação do Participante	  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CVC.CVC_FILIAL,CVC.CVC_CODPAR, CVC.CVC_NOME, CVC.CVC_DTINI,CVC.R_E_C_N_O_,'DATA DE INICIO DO PARTICIPANTE MAIOR QUE A DATA DE ESCRITURAÇÃO' MSG, '2' ERRO";
			+ "  FROM " + RetSqlName( "CVC" ) + " CVC ";
			+ " WHERE CVC.CVC_DTINI > '"+dTos(dDataIni)+"'";
			+ "   AND CVC.CVC_FILIAL " + GetRngFil( aSelFil ,"CVC");
			+ "   AND CVC.D_E_L_E_T_ = ' ' "
	 
	cQuery := ChangeQuery(cQuery) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera um novo alias  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasCVC := GetNextAlias()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a query     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCVC,.T.,.T.)
	
	aStruct   := CVC->(dbStruct())
	
	For nX := 1 To Len(aStruct)
		If aStruct[nX][2] <> "C" 	// .And. FieldPos(aStruct[nX][1])<>0
			TcSetField(cAliasCVC,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
		EndIf
	Next nX
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existem registros incorretos, de acordo com o retorno da query³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While (cAliasCVC)->( !Eof() )
		If (cAliasCVC)->MSG <> cMsgErro
			EcdAddMsg( "ERRO: " + (cAliasCVC)->MSG)
			cMsgErro := (cAliasCVC)->MSG
		EndIf

		If oProcess <> Nil
			oProcess:SetRegua2(0)
			oProcess:IncRegua2( STR0017 + (cAliasCVC)->CVC_CODPAR) //"Cod. do Contabilista : "
		EndIf

		//Adicionando menssagem de erro
		EcdAddMsg( "FILIAL: " + (cAliasCVC)->CVC_FILIAL  + " | REGISTRO: " + STR((cAliasCVC)->R_E_C_N_O_) + " | COD: " + Alltrim( (cAliasCVC)->CVC_CODPAR ) + "-" + (cAliasCVC)->CVC_NOME  )
	
		dbSelectArea(cAliasCVC)
		dbSkip()
	EndDo

	(cCVCCount)->( dbCloseArea() )
	dbSelectArea("CVC")
EndIf

RestArea( aArea )

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ValidPlRef    ³ Rev.  ³Elton C. Santana   ³ Data ³08/02/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a pré-validação do Plano de Contas Referencial		  ³±±
±±³          ³                                                    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³							                                  ³±±
±±³          ³                          						          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³array		                                                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Ecd Contabil			                	                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidPlRef(oProcess, aSelFil)

Local aArea    	 := GetArea()
Local nx		 := 0
Local aStruct	 := {}
Local cQuery	 := ""
Local cQuerCount := ""
Local cAliasCVD	 := "CVD"
Local cCVDCount  := "CVD"
Local cMsgErro	:= ""
Local lErro		:= .F.

Default oProcess := Nil

If oProcess <> Nil
	oProcess:IncRegua1( STR0018)//"Validando Plano de Conta Referencial" 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query -Verifica se existe registro na tabela    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuerCount := "SELECT COUNT(CVD_FILIAL) CCVDCOUNT";
			+ "  FROM " + RetSqlName( "CVD" ) + " CVD ";
			+ " WHERE CVD_FILIAL " + GetRngFil( aSelFil ,"CVD");
			+ "	  AND D_E_L_E_T_ = '' " 

cQuerCount := ChangeQuery(cQuerCount) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera um novo alias  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCVDCount := GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a query     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuerCount) , cCVDCount,.T.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe registro na tabela de acordo com o retorno da query   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cCVDCount)->(Eof()) .OR. (cCVDCount)->CCVDCOUNT <= 0
	//Adcionando menssagem de erro
	EcdAddMsg(STR0008) //"CVD-> NÃO EXISTE AMARRAÇÃO DO PLANO DE CONTA COM O PLANO DE CONTAS REFERENCIAL"
	lErro := .T.
Endif	

(cCVDCount)->( dbCloseArea() )

If !lErro
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query utilizada para efetuar a validação do Plano de Contas Referencial   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CVD.CVD_FILIAL, CVD.CVD_ENTREF, CVD.CVD_CTAREF, CVD.CVD_CONTA, CVD.CVD_CUSTO, CVD.R_E_C_N_O_";
			     + ", 'CONTA INFORMADA NO PLANO REFERENCIAL NÃO EXISTE '" + cConcat + "CVD.CVD_CONTA MSG, '2' ERRO ";
			+ "  FROM " + RetSQLTab( "CVD" );
			+ " WHERE " + RetSQLCond( "CVD" );
			+ "   AND NOT EXISTS(";
			+ "                 SELECT R_E_C_N_O_ ";
			+ "                 FROM " + RetSQLTab( "CT1" ) + " ";
			+ "                 WHERE CVD.CVD_FILIAL " + GetRngFil( aSelFil ,"CVD");
			+ "					AND CT1.CT1_FILIAL " + GetRngFil( aSelFil ,"CT1");
			+ "                 AND CVD.CVD_CONTA = CT1.CT1_CONTA ";
			+ "                 AND CVD.D_E_L_E_T_ <> '*'";
			+ "                )";
	
	cQuery += " UNION "

	cQuery += "SELECT CVD.CVD_FILIAL, CVD.CVD_ENTREF, CVD.CVD_CTAREF, CVD.CVD_CONTA, CVD.CVD_CUSTO, CVD.R_E_C_N_O_";
				 + ", 'C.CUSTO INFORMADO NO PLANO REFERENCIAL NÃO EXISTE '"+cConcat+"CVD.CVD_CUSTO MSG, '2' ERRO";
			+ "  FROM " + RetSQLTab( "CVD" );
			+ " WHERE " + RetSQLCond( "CVD" );
			+ "   AND CVD.CVD_CUSTO <> ' '";
			+ "   AND NOT EXISTS(";
			+ "                 SELECT R_E_C_N_O_ ";
			+ "                 FROM " + RetSQLTab( "CTT" ) + " ";
			+ "                 WHERE CVD.CVD_FILIAL " + GetRngFil( aSelFil ,"CVD");
			+ "					AND CTT.CTT_FILIAL " + GetRngFil( aSelFil ,"CTT");
			+ "                 AND CVD.CVD_CUSTO = CTT.CTT_CUSTO ";
			+ "                 AND CVD.D_E_L_E_T_ <> '*'";
		 	+ "                )"
	 
	cQuery := ChangeQuery(cQuery) 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera um novo alias  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasCVD := GetNextAlias()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a query     ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCVD,.T.,.T.)
	
	
	aStruct   := CVD->(dbStruct())
	For nX := 1 To Len(aStruct)
		If aStruct[nX][2] <> "C" 	// .And. FieldPos(aStruct[nX][1])<>0
			TcSetField(cAliasCVD,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
		EndIf
	Next nX

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existem registros incorretos, de acordo com o retorno da query³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While (cAliasCVD)->( !Eof() )
		If (cAliasCVD)->MSG <> cMsgErro
			EcdAddMsg( "ERRO: " + (cAliasCVD)->MSG )
			cMsgErro := (cAliasCVD)->MSG
		EndIf

		If oProcess <> Nil
			oProcess:SetRegua2(0)
   			oProcess:IncRegua2( STR0019 +(cAliasCVD)->CVD_CTAREF) //"Plano de Conta Referencial: "
		EndIf

		//Adicionando menssagem de erro
		EcdAddMsg( "FILIAL: " + (cAliasCVD)->CVD_FILIAL  + " | REGISTRO: " + STR((cAliasCVD)->R_E_C_N_O_) + " | COD: " + Alltrim( (cAliasCVD)->CVD_ENTREF ) + "-" + (cAliasCVD)->CVD_CTAREF )

		dbSelectArea(cAliasCVD)
		dbSkip()
	EndDo

	(cAliasCVD)->( dbCloseArea() )
	dbSelectArea("CVD")
EndIf

RestArea( aArea )

Return 

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³ValidLacto³ Rev.  ³Elton C. Santana       ³ Data ³08/02/09  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Efetua a pré-validação dos Lançamentos Contabeis			  ³±±
±±³          ³                                                    		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³							                                  ³±±
±±³          ³                          						          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³array		                                                  ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Ecd Contabil			                                      ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function ValidLacto(oProcess, aSelFil, dDataIni, dDataFim)
Local aArea    	:= GetArea()
Local nx		:= 0
Local aStruct	:= {}
Local cQuery	:= ""
Local cQuerCount:= ""
Local cAliasCT2	:= "CT2"
Local cCt2Count := "CT2"
Local cMsgErro	:= ""
Local lErro		:= .F.
Local nTamConta :=  TamSx3("CT1_CONTA")[1] 
Local nTamCusto :=  TamSx3("CTT_CUSTO")[1] 

Default oProcess := Nil
Default dDataIni := cTod("01/01/" + Year() )
Default dDataFim := cTod("31/12/" + Year() )

If oProcess <> Nil
	oProcess:IncRegua1(STR0020) //"Validando Movimentações Contabeis" 
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Query -Verifica se existe registro na tabela    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cQuerCount := "SELECT COUNT(CT2_FILIAL) CT2COUNT";
			+ " FROM " + RetSqlName( "CT2" ) + " CT2 ";
			+ " WHERE CT2_FILIAL " + GetRngFil( aSelFil ,"CT2") ;
			+ "   AND CT2_DATA >= '" + Dtos( dDataIni ) + "'" ; 
			+ "   AND CT2_DATA <= '" + Dtos( dDataFim ) + "'" ; 
			+ "   AND D_E_L_E_T_ = ' '" 

cQuerCount := ChangeQuery(cQuerCount) 
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Gera um novo alias  ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cCt2Count := GetNextAlias()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Executa a query	   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuerCount) , cCt2Count,.T.,.T.)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se existe registro na tabela de acordo com o retorno da query   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (cCt2Count)->(Eof()) .OR. (cCt2Count)->CT2COUNT <= 0
	//Adcionando menssagem de erro
	EcdAddMsg(STR0009 + " | PERIODO: " + Dtoc( dDataIni ) + " ATÉ " + Dtoc( dDataFim ) , .T. )//"CT2-> NAO EXISTE LANÇAMENTOS CONTABEIS"
	lErro := .T.
Endif

(cCt2Count)->( dbCloseArea() )

If !lErro
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Query utilizada para efetuar a validação dos lanaçmentos contabeis³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cQuery := "SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, R_E_C_N_O_, 'CONTA DE DEBITO NAO PREENCHIDO' MSG, '2' ERRO " ;
			+ "  FROM " + RetSqlName( "CT2" ) ;
			+ " WHERE CT2_FILIAL " + GetRngFil( aSelFil ,"CT2", .T. );
			+ "   AND CT2_DATA >= '" + Dtos( dDataIni ) + "'" ; 
			+ "   AND CT2_DATA <= '" + Dtos( dDataFim ) + "'" ; 
			+ "   AND ( CT2_DC = '1' OR CT2_DC = '3' )" ;
			+ "   AND CT2_DEBITO = '" + Space( nTamConta ) + "'" ;
			+ "   AND D_E_L_E_T_ = ' ' " 
			
	
	cQuery += " UNION "
	cQuery += "SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, R_E_C_N_O_, 'CONTA DE CREDITO NAO PREENCHIDO' MSG, '2' ERRO " ;
			+ "  FROM " + RetSqlName( "CT2" ) ;
			+ " WHERE CT2_FILIAL " + GetRngFil( aSelFil ,"CT2", .T. );
			+ "   AND CT2_DATA >= '" + Dtos( dDataIni ) + "'" ; 
			+ "   AND CT2_DATA <= '" + Dtos( dDataFim ) + "'" ; 
			+ "   AND ( CT2_DC = '2' OR CT2_DC = '3' )";
			+ "   AND CT2_CREDIT = '" + Space( nTamConta ) + "'" ;
			+ "   AND D_E_L_E_T_ = ' ' "
	
	
	cQuery += " UNION "
	cQuery += "SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, R_E_C_N_O_, 'CONTA DE DEBITO NAO EXITE NO PLANO DE CONTAS: '"+cConcat+" CT2_DEBITO  MSG, '2' ERRO ";
			+ "  FROM " + RetSqlName( "CT2" );
			+ " WHERE CT2_FILIAL " + GetRngFil( aSelFil ,"CT2", .T. );
			+ "   AND CT2_DATA >= '" + Dtos( dDataIni ) + "'" ; 
			+ "   AND CT2_DATA <= '" + Dtos( dDataFim ) + "'" ; 
			+ "   AND CT2_DEBITO <> '" + Space( nTamConta ) + "'" ;
			+ "   AND CT2_DEBITO NOT IN (  SELECT CT1_CONTA FROM " + RetSqlName( "CT1" );
										+ " WHERE CT1_FILIAL " + GetRngFil( aSelFil ,"CT1");
										+ "   AND D_E_L_E_T_ = ' ' )" ;
			+ "   AND D_E_L_E_T_ = ' ' "
	
	cQuery += " UNION "
	cQuery += "SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, R_E_C_N_O_, 'CONTA DE CREDITO NAO EXISTE NO PLANO DE CONTAS: ' "+cConcat+" CT2_CREDIT  MSG, '2' ERRO ";
			+ "  FROM " + RetSqlName( "CT2" );
			+ " WHERE CT2_FILIAL " + GetRngFil( aSelFil ,"CT2", .T. );
			+ "   AND CT2_DATA >= '" + Dtos( dDataIni ) + "'" ; 
			+ "   AND CT2_DATA <= '" + Dtos( dDataFim ) + "'" ; 
			+ "   AND CT2_CREDIT <> '" + Space( nTamConta ) + "'";
			+ "   AND CT2_CREDIT NOT IN ( SELECT CT1_CONTA FROM "+RetSqlName( "CT1" );
								       + " WHERE CT1_FILIAL " + GetRngFil( aSelFil ,"CT1");
									   + "   AND D_E_L_E_T_ = ' ' )";
			+ "   AND D_E_L_E_T_ = ' ' "
	
	cQuery += " UNION "
	cQuery += "SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, R_E_C_N_O_, 'C. CUSTO DE DEBITO NAO EXITE NO CADASTRO DE C. CUSTO: ' "+cConcat+" CT2_CCD MSG, '2' ERRO ";
			+ "  FROM " + RetSqlName( "CT2" );
			+ " WHERE CT2_FILIAL " + GetRngFil( aSelFil ,"CT2", .T. );
			+ "   AND CT2_DATA >= '" + Dtos( dDataIni ) + "'" ; 
			+ "   AND CT2_DATA <= '" + Dtos( dDataFim ) + "'" ; 
			+ "   AND CT2_CCD <> '" + Space( nTamCusto ) + "'" ;
			+ "   AND CT2_CCD NOT IN ( SELECT CTT_CUSTO FROM "+RetSqlName( "CTT" );
													+ " WHERE CTT_FILIAL " + GetRngFil( aSelFil ,"CTT");
													+ "AND D_E_L_E_T_ = ' ' )";
			+ "   AND D_E_L_E_T_ = ' ' "

	
	cQuery += " UNION "
	cQuery += "SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, R_E_C_N_O_, 'C. CUSTO DE CREDITO NAO EXISTE NO CADASTRO DE C. CUSTO: ' "+cConcat+" CT2_CCC MSG, '2' ERRO ";
			+ "  FROM " + RetSqlName( "CT2" );
			+ " WHERE CT2_FILIAL " + GetRngFil( aSelFil ,"CT2", .T. );
			+ "   AND CT2_DATA >= '" + Dtos( dDataIni ) + "'" ; 
			+ "   AND CT2_DATA <= '" + Dtos( dDataFim ) + "'" ; 
			+ "   AND CT2_CCC <> '" + Space( nTamCusto ) + "'";
			+ "   AND CT2_CCC NOT IN ( SELECT CTT_CUSTO FROM "+RetSqlName( "CTT" );
													+ " WHERE CTT_FILIAL " + GetRngFil( aSelFil ,"CTT");
													+ "AND D_E_L_E_T_ = ' ' )";
			+ "   AND D_E_L_E_T_ = ' ' "
	
	cQuery += " UNION "
	cQuery += "SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, R_E_C_N_O_, 'CODIGO DO HISTORICO PADRÃO NAO EXISTE NO CADASTRO DE HISTORICOS: ' "+cConcat+" CT2_HP MSG, '2' ERRO ";
			+ "  FROM " + RetSqlName( "CT2" );
			+ " WHERE CT2_FILIAL " + GetRngFil( aSelFil ,"CT2", .T. );
			+ "   AND CT2_DATA >= '" + Dtos( dDataIni ) + "'" ; 
			+ "   AND CT2_DATA <= '" + Dtos( dDataFim ) + "'" ; 
			+ "   AND CT2_HP <> '' AND CT2_HP NOT IN ( SELECT CT8_HIST FROM "+RetSqlName( "CT8" );
												  + " WHERE CT8_FILIAL " + GetRngFil( aSelFil ,"CT8");
												  + "AND D_E_L_E_T_ = ' ' )";
			+ "   AND D_E_L_E_T_ = ' ' "
	
	cQuery += " UNION "
	cQuery += "SELECT CT2_FILIAL, CT2_DATA, CT2_LOTE, CT2_SBLOTE, CT2_DOC, CT2_LINHA, R_E_C_N_O_, 'CODIGO DO PARTICIPANTE NAO EXISTE NO CADASTRO DE PARTICIPANTE: ' "+cConcat+" CT2_HP MSG, '2' ERRO ";
			+ "  FROM " + RetSqlName( "CT2" );
			+ " WHERE CT2_FILIAL " + GetRngFil( aSelFil ,"CT2", .T. );
			+ "   AND CT2_DATA >= '" + Dtos( dDataIni ) + "'" ; 
			+ "   AND CT2_DATA <= '" + Dtos( dDataFim ) + "'" ; 
			+ "   AND CT2_CODPAR <> '' AND CT2_CODPAR NOT IN ( SELECT CVC_CODPAR FROM "+RetSqlName( "CVC" );
														  + " WHERE CVC_FILIAL " + GetRngFil( aSelFil ,"CVC");
													      + "AND D_E_L_E_T_ = ' ' )";
			+ "   AND D_E_L_E_T_ = ' ' "
	
	cQuery := ChangeQuery(cQuery) 
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Gera um novo alias  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cAliasCT2 := GetNextAlias()
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Executa a query	   ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasCT2,.T.,.T.)
	
	aStruct   := CT2->(dbStruct())
	
	For nX := 1 To Len(aStruct)
		If aStruct[nX][2] <> "C" 	// .And. FieldPos(aStruct[nX][1])<>0
			TcSetField(cAliasCT2,aStruct[nX][1],aStruct[nX][2],aStruct[nX][3],aStruct[nX][4])
		EndIf
	Next nX 

	dbSelectArea(cAliasCT2)
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Verifica se existem registros incorretos, de acordo com o retorno da query³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	While (cAliasCT2)->( !Eof() )
		If (cAliasCT2)->MSG <> cMsgErro
			EcdAddMsg( "ERRO: " + (cAliasCT2)->MSG )
			cMsgErro := (cAliasCT2)->MSG
		EndIf

		If oProcess <> Nil
			oProcess:SetRegua2(0)
   			oProcess:IncRegua2( STR0021 + dToc((cAliasCT2)->CT2_DATA)+" "+STR0022+(cAliasCT2)->CT2_LOTE  )//"Data do Lacto. : "## "Lote: "
		EndIf

		//Adicionando menssagem de erro
		EcdAddMsg( "FILIAL: " + (cAliasCT2)->CT2_FILIAL  + " | REGISTRO: " + STR((cAliasCT2)->R_E_C_N_O_) + " | DATA: " + dToc((cAliasCT2)->CT2_DATA)+ " | LCTO: " + Alltrim( (cAliasCT2)->CT2_LOTE + CT2_SBLOTE + CT2_DOC + CT2_LINHA ) )
		
		dbSelectArea(cAliasCT2)
		dbSkip()
	EndDo

	(cAliasCT2)->( dbCloseArea() )
	dbSelectArea("CT2")
EndIf

RestArea( aArea )

Return 
