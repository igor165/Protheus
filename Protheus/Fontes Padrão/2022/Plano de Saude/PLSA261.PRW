#INCLUDE "plsa261.ch"
#include "PROTHEUS.CH"
#include "PLSMGER.CH"

#define  K_DefExc  4
STATIC cMenu := 2 //Variavel estatica para controlar o MenuDef e o aRotina.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA261 ³ Autor ³ Tulio Cesar          ³ Data ³ 24.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Movimentacao para cobranca de segunda via de carteira      ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA261

/*Local aCores  := { 	{ "BED_FATUR = '0'", 'BR_VERDE'   },;
{ "BED_FATUR = '1'", 'BR_VERMELHO'},;
{ "BED_FATUR = '2'", 'BR_AMARELO' },;
{ "BED_FATUR = '3'", 'BR_AZUL'    } }
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta matriz com as opcoes do browse...                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE cDesIdent := AllTrim(BA0->(Posicione("BA0",1,xFilial("BA0")+PLSINTPAD(),"BA0_NOMCAR")))
If  empty(cDesIdent)
	cDesIdent := STR0060 //"Cartão de Identificação"
Endif

PRIVATE aRotina   :=	{}

PRIVATE cCadastro := Fundesc() + cDesIdent //"Lancamento para Cobranca Vias de Cartao"
/*PRIVATE aCdCores  	:= { 	{ 'BR_VERDE'	,'Nao Faturado'						},;
{ 'BR_VERMELHO'	,'Faturado para proxima cobrança'	},;
{ 'BR_AMARELO'	,'Aguardando pagamento do Titulo'	},;
{ 'BR_AZUL'		,'Titulo Pago'						} }
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Starta mBrowse...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

cMenu := 0
aRotina   := MenuDef()

BED->(DBSetOrder(1))
BED->(mBrowse(06,01,22,75,"BED"))

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA261EXC ³ Autor ³ Tulio Cesar       ³ Data ³ 25.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Tratamento para exclusao dos lanctos cobranca 2 via cartao ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA261EXC(cAlias,nReg,nOpc,lDelDireto)

Local cCodInt   := BED->BED_CODINT
Local cCodEmp   := BED->BED_CODEMP
Local cMatric   := BED->BED_MATRIC
Local cTipReg   := BED->BED_TIPREG
Local cDigito   := BED->BED_DIGITO
Local cCodigo   := ""
Local cChaveSe1 := ""
Local nRegBDE   := 0
Local nOrdAnt   := 0
Local nOK 	    := 0
Local nUltVia   := 0
Local aVetor    := {}
Local aRetBED   := {}

DEFAULT lDelDireto := .F.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Criado somente para rodar o AxDeleta que necessita do aRotina       ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aRotina   := {}

cMenu := 1


aRotina := MenuDef()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se nao foi emitido pela rotina de lanc. avulsos, nao permite a exclusao...      ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AllTrim(BED->BED_ORIGEM) <> AllTrim(FunName()) 
	If !AllTrim(BED->BED_ORIGEM) == 'TMKA271' //lancamento avulso realizado através do call center 
		MsgStop(STR0064) //"Via de cartão do usuário emitida pela rotina de Lotes de cartão, o registro não será excluído."
		Return .F.
	EndIf	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Localiza o arquivo de lancamento...                          		³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BDE->(DbSetOrder(1))
If BED->BED_CDIDEN <> "AVULSA"
	If ! BDE->(DbSeek(xFilial("BDE")+BED->(BED_CODINT+BED_CDIDEN)))
		If ! lDelDireto
			MsgStop(STR0013+cDesIdent) //"Não foi possível localizar o lançamento de exportação/emissão de "
		Endif
		Return .F.
	Else
		cCodigo := BED->BED_CDIDEN
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica estado do arquivo de lancamento...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If BED->BED_CDIDEN <> "AVULSA"
	If BDE->BDE_STACAR $ "3,4"
		If ! lDelDireto
			MsgStop(STR0065) //"Lote Bloqueado, não poderá ser excluído."
		Endif
		Return .F.
	EndIf
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se foi faturada...                                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cChaveSe1 := BED->(BED_PREFIX + BED_NUMTIT + BED_PARCEL + BED_TIPTIT)
SE1->(DbSetOrder(1))

If SE1->(DbSeek(xFilial("SE1")+cChaveSe1))
	
	If BED->BED_FATUR == "1"
		If ! lDelDireto
			MsgStop(STR0015) //"Não é possível excluir este lançamento pois ele já foi faturado!"
		Endif
		Return .F.
	Else
		If SE1->E1_SALDO = 0
			If ! lDelDireto
				MsgStop(STR0016) //"Não é possível excluir este lançamento pois ele já foi pago!"
			Endif
			Return .F.
		Endif
	Endif
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se eh o ultimo lote emitido para este usuario...           ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUltVia := PL261UVC(cCodInt, cCodEmp, cMatric, cTipReg)[1]

If nUltVia >= 0
	If nUltVia <> BED->BED_VIACAR
		If ! lDelDireto
			MsgStop(STR0017) //"Somente a última via do cartão do usuário pode ser excluída!"
		Endif
		Return .F.
	Endif
Else
	If ! lDelDireto
		MsgStop(STR0018) //"Última via do cartão do usuário não encontrada. Verifique!"
	Endif
	Return .F.
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se a Via esta bloqueada...                                 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (BED->( FieldPos("BED_CODBLO") ) = 0) .OR. (BED->( FieldPos("BED_BLOIDE") ) = 0)
	If ! lDelDireto
		MsgStop(STR0019) //"Dicionario de dados desatualizado!!!"
	Endif
	Return .F.
Else
	If BED->BED_BLOIDE == "1"
		If ! lDelDireto
			MsgStop(STR0020) //"Via do Cartão não pode ser excluida pois está bloqueada!"
		Endif
		Return .F.
	Endif
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Alimenta controle... 				                                ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ! lDelDireto
	nOK := BED->(AxDeleta(cAlias,nReg,K_Excluir))
Else
	nOk := 2
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se foi confirmada a exclusao...                                     ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nOK == 2
	
	BEGIN TRANSACTION
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza dados no usuario...                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BED->BED_FATUR <> "2"
		BA1->(DbSetOrder(2))
		If BA1->(DbSeek(xFilial("BA1")+cCodInt+cCodEmp+cMatric+cTipReg))
			
			BA1->(RecLock("BA1",.F.))
			
			If BA1->BA1_VIACAR > 1
				
				aRetBED := PL261UVC(cCodInt, cCodEmp, cMatric, cTipReg)
				
				If aRetBED[1] >= 0
					BA1->BA1_VIACAR := aRetBED[1]
					BA1->BA1_CDIDEN := aRetBED[2]
					BA1->BA1_DTVLCR := aRetBED[3]
					GrvVldCarUsr(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),aRetBED[3])
				Else
					If ! lDelDireto
						MsgStop(STR0021) //"Não foi encontrada a Via anterior do Cartão. Verifique!"
					Endif
				Endif
				
			Else

				aRetBED := PL261UVC(cCodInt, cCodEmp, cMatric, cTipReg)

				If aRetBED[1] >= 0
					BA1->BA1_VIACAR := aRetBED[1]
					BA1->BA1_CDIDEN := aRetBED[2]
					BA1->BA1_DTVLCR := aRetBED[3]
					GrvVldCarUsr(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),aRetBED[3])
				Else
					BA1->BA1_VIACAR := 0
					BA1->BA1_CDIDEN := ""
					BA1->BA1_DTVLCR := StoD("")
					GrvVldCarUsr(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),StoD(""))
				Endif
			Endif
			
			BA1->(MsUnLock())
			
		Endif
	EndIf
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza Financeiro... 		                                        ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ! Empty(cChaveSe1)
		
		BBT->(DbSetOrder(7))
		If BBT->(DbSeek(xFilial("BBT")+cChaveSe1))
			BBT->(RecLock("BBT",.F.))
			BBT->(DbDelete())
			BBT->(MsUnLock())
		Endif
		BBT->(DbSetOrder(1))
		
		If ! lDelDireto
			
			nOldMod := nModulo
			nModulo := 6
			
			aVetor  := {	{"E1_PREFIXO" ,SE1->E1_PREFIXO ,Nil},;
			{"E1_NUM"	  ,SE1->E1_NUM     ,Nil},;
			{"E1_PARCELA" ,SE1->E1_PARCELA ,Nil},;
			{"E1_TIPO"	  ,SE1->E1_TIPO    ,Nil},;
			{"E1_NATUREZ" ,SE1->E1_NATUREZ ,Nil} }
			
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Exclui registro em SE1...	                                        ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			MSExecAuto({|x,y| Fina040(x,y)},aVetor,5)
			
			nModulo := nOldMod
			
		Endif
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Exclui BED... 		                                        		³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lDelDireto
		BED->(RecLock("BED",.F.))
		BED->(DbDelete())
		BED->(MsUnLock())
	Endif
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Atualiza BDE... 		                                        	³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If BED->BED_CDIDEN <> "AVULSA"
		BDE->(RecLock("BDE",.F.))
		If BDE->BDE_QTD == 1
			BDE->(DbDelete())
		Else
			BDE->BDE_QTD := BDE->BDE_QTD -1
		Endif
		BDE->(MsUnLock())
	Endif
	
	END TRANSACTION
	
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Fim da Rotina...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA261USR ³ Autor ³ Tulio Cesar       ³ Data ³ 25.06.2002 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Trata matricula do usuario                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Advanced Protheus                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ Nenhum                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA261USR(__cUsuario)
LOCAL lRet

BA1->(DbSetOrder(2))

lRet := BA1->(DbSeek(xFilial("BA1")+__cUsuario))
If ! lRet
	Help("",1,"REGNOIS")
Endif

If lRet .And. Type("oGetBED") = "O"
	If PlsVldGd()
		oGetBED:aCols[oGetBED:Linha(), 2] := BA1->BA1_NOMUSR
	Else
		lRet := .F.
	Endif
Endif

Return(lRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA261LEG ³ Autor ³ Wagner Mobile Costa ³ Data ³ 28.08.03 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Exibe a legenda...                                         ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA261Leg()

Local aLegenda := { 	{ aCdCores[1,1],aCdCores[1,2] },;
{ aCdCores[2,1],aCdCores[2,2] },;
{ aCdCores[3,1],aCdCores[3,2] },;
{ aCdCores[4,1],aCdCores[4,2] } }


BrwLegenda(cCadastro,"Status" ,aLegenda)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA261VIA ³ Autor ³ Eduardo Motta       ³ Data ³ 30.03.04 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Consulta vias do usuario                                   ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA261Via(cMatUsu)

Local aCols   := {}
Local aHeader := {}
Local aTrb    := {}
Local aCab    := {}
Local cMatric := ""
Local nI 	  := 0
Local nTam 	  := 0
Default cMatUsu = ""
If Empty(cMatUsu)
	If !Pergunte("PLS261")
		Return
	EndIf
	cMatric := RTrim(MV_PAR01)
Else
	cMatric := RTrim(cMatusu)
EndIf

Store Header "BED" TO aCab For .T.

BED->(DbSetOrder(1))
If ! BED->(DbSeek(xFilial("BED")+cMatric))
	MsgStop(STR0022) //"Nenhuma carteirinha foi emitida."
	Return
Else
	Store COLS "BED" TO aCols FROM aCab VETTRAB aTrb While xFilial("BED")+cMatric == BED->(BED_FILIAL)+PadR(BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG+BED_DIGITO),Len(cMatric))
Endif

For nI := 1 to Len(aCab)
	nTam := aCab[nI,4]
	If Len(AllTrim(aCab[nI,1])) > nTam
		nTam := Len(AllTrim(aCab[nI,1]))
	EndIf
	aadd(aHeader,{aCab[nI,1],aCab[nI,3],nTam*3})
Next

PLSCRIGEN(aCols,aHeader, STR0023) //"Consulta de vias"

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PL261INC   ³ Autor ³ Microsiga	        ³ Data ³ 27.07.09 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Chama a rotina de inclusao direto do Menu                  ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/

Function PL261INC()
PLSA261INC()
Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA261INC ³ Autor ³ Eduardo Motta       ³ Data ³ 30.03.04 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Inclusao de vias do usuario                                ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA261INC(cCodInt,cMatric,cMotivo,lImp,dDatval,Lweb,lImpressao,lAutoma)
Local _nH		:= 0
Local cExpRdm  	:= ""
Local cCodLote 	:= ""
Local aRet     	:= {.F.,{},{},{}}
Local cNomCar	:= ""
Local cProtoc	:= ""
Local aCritica	:= {}

Default cMatric  	:= ""
Default cMotivo  	:= ""
Default cCodInt  	:= ""
Default dDatVal  	:= ""
Default lImp     	:= .t.
Default Lweb	 	:= .f. //Variavel referente ao Portal do beneficiario
Default lImpressao 	:= .f.
Default lAutoma		:= .F. // Variavel responsavel para controle de automação

If funname() = "PLSA261" .OR. (funname() = "TMKA271" .AND. (Empty(cCodInt) .or. Empty(cMatric) .or. Empty(cMotivo))) .OR. lAutoma
	
	cCodInt  := PlsIntPad()
	AjustaSX1()
	
	If !Pergunte("PLS262")
		Return(aRet)
	EndIf
	
	cMatric  := MV_PAR01
	cMotivo  := MV_PAR02
	lImp     := (MV_PAR03==1)
	dDatVal  := MV_PAR04
	MV_PAR05 := Alltrim(IIF(Empty(MV_PAR05),"c:\",MV_PAR05)) //Não permite local de gravacao vazio 
	cNomCar	 := StrZero(mv_par06,1)

	If Empty(cMatric) .or. Empty(cMotivo) .or. Empty(dDatVal)
		Help("",1,"OBRIGAT")
		Return(aRet)
	EndIf
	
EndIf

DBSELECTAREA("BDE")
BDE->(DbSetOrder(1))

BA1->(DbSetOrder(2))
If ! BA1->(DbSeek(xFilial("BA1")+cMatric))
	If !Lweb
		MsgStop(STR0024) //"Usuário não encontrado!"
		Return(aRet)
	Else
		Aadd(aCritica, {"",STR0024})
		aRet := {.F.,{},aCritica,{}}
	Endif
EndIf

BA3->(DbSetOrder(1))
If ! BA3->(DbSeek(xFilial("BA3")+BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC)))
	IF !Lweb
		MsgStop(STR0025) //"Família não encontrada!"
		Return(aRet)
	Else
		Aadd(aCritica, {"",STR0025})
		aRet := {.F.,{},aCritica,{}}
	Endif
EndIf

If GetNewPar("MV_PLSMP1V","4") == cMotivo .and. !lImpressao

	If BA1->(DbSeek(xFilial("BA1")+cMatric)) .And. BA1->BA1_VIACAR <> 0

		If !Lweb
			MsgStop(STR0062) //Usuário já tem cartão emitido, não é possível emitir primeira via
			Return(aRet)
		Else
			Aadd(aCritica, {"",STR0062})
			aRet := {.F.,{},aCritica,{}}
			
			Return(aRet)
		Endif
		
	EndIf
EndIf

If GetNewPar("MV_PLSMP1V","4") <> cMotivo .And. BA1->(DbSeek(xFilial("BA1")+cMatric)) .And. BA1->BA1_VIACAR = 0
	If !Lweb
		MsgStop(STR0063) //"Usuário não tem primeira via emitida. Deve ser emitida a primeira via"
		Return(aRet)
	Else
		Aadd(aCritica, {"",STR0063})
		aRet := {.F.,{},aCritica,{}}
		Return(aRet)
	Endif
	
EndIf

If lImp

	_nH := PLSAbreSem("PLSA262.SMF",.F.)
	
	If  _nH == 0
		If !Lweb
			msgalert(STR0026) //"A rotina de geração de carteirinha está sendo executada por outro usuário. Inclusão nao poderá ser feita neste momento."
			Return(aRet)
		Else
			Aadd(aCritica, {"",STR0026})
			aRet := {.F.,{},aCritica,{}}
			Return(aRet)
		Endif
		
	EndIf
	
	PLSFechaSem(_nH,"PLSA262.SMF")
	
	cCodLote := PLSA262NUM(cCodInt)
Else
	cCodLote := "AVULSA"
EndIf

If BDE->(FieldPos("BDE_PROTOC"))<>0
	cProtoc:= GetSxENum( "BDE", "BDE_PROTOC" )
Endif

If Lweb
	cCodLote := PLSA262NUM(cCodInt)
Endif

BA0->(DbSetOrder(1))
If BA0->(DbSeek(xFilial("BA0")+cCodInt))
	
	If Empty(BA0->BA0_EXPIDE)
		cExpRdm := AllTrim(GetNewPar("MV_PLSEXPI",""))
	Else
		cExpRdm := AllTrim(BA0->BA0_EXPIDE)
	Endif
	
	//BEGIN TRANSACTION
	
	if !lImpressao
		BDE->(RecLock("BDE",.T.))
			BDE->BDE_FILIAL := xFilial("BDE")
			BDE->BDE_CODINT := cCodInt
			BDE->BDE_CODPLA := BA1->BA1_CODPLA
			BDE->BDE_CODIGO := cCodLote
			BDE->BDE_MOTIVO := cMotivo
			BDE->BDE_EMPDE  := BA1->BA1_CODEMP
			BDE->BDE_EMPATE := BA1->BA1_CODEMP
			BDE->BDE_CONDE  := BA1->BA1_CONEMP
			BDE->BDE_CONATE := BA1->BA1_CONEMP
			BDE->BDE_SUBDE  := BA1->BA1_SUBCON
			BDE->BDE_SUBATE := BA1->BA1_SUBCON 
			BDE->BDE_MATDE 	:= BA1->(BA1_MATRIC+BA1_TIPREG)
			BDE->BDE_MATATE	:= BA1->(BA1_MATRIC+BA1_TIPREG)
			If BDE->(FieldPos("BDE_PROTOC")) > 0 .and. Lweb
				BDE->BDE_PROTOC := cProtoc
			Endif
		BDE->(MsUnlock())
		
		M->BDE_NOMCAR := cNomCar
	endIf
	
	If ExistBlock(cExpRdm)
		aRet := ExecBlock(cExpRdm,.F.,.F.,{cCodLote,cMotivo,cCodInt,NIL,3,.f.,lImp,dDatVal,nil,Alltrim(MV_PAR05),Lweb,cProtoc,lImpressao})
	Else
		aRet := Plsa264({cCodLote,cMotivo,cCodInt,NIL,3,.f.,lImp,dDatVal,nil,Alltrim(MV_PAR05),,lImpressao},Lweb,cProtoc,lAutoma)
	EndIf
	
	If ValType(aRet) <> "A"
		aRet := {.F.,{0},{},{}}
	Endif

	If Lweb
		lImp   := .t.
	Endif		
	
	if !lImpressao
		If lImp .and. aRet[1] .And. aRet[2,1]>0
			BDE->(RecLock("BDE",.F.))
				BDE->BDE_UNILOC := "1"
				BDE->BDE_TIPGRU := "3"
				BDE->BDE_STACAR := "1"
				BDE->BDE_TIPGER := "1"
				BDE->BDE_NOMCAR := cNomCar
				BDE->BDE_QTD    := 1
			BDE->(MsUnlock())
		Else
			BDE->(RecLock("BDE",.F.))
				BDE->(DbDelete())
			BDE->(MsUnlock())
		EndIf
		ConfirmSX8()
	endIf
		
	//END TRANSACTION
	
Endif

If aRet[1] .And. aRet[2,1]>0 .and. !Empty(BED->BED_NUMTIT)
	Plsa261Bxt()
EndIf

If aRet[1]
	If !lWeb
		If !lAutoma
			MsgAlert(STR0061) //"Gerada solicitação com sucesso!"
		EndIf
	Else		
		aRet[3] := {"","Protocolo Numero [ "+cProtoc+ "]"}
	Endif
EndIf

Return(aRet)

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ Pls261Per  ³ Autor ³ Eduardo Motta       ³ Data ³ 16.04.04 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Validacao do pergunte		                              ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Pls261Per()
BA1->(DbSetOrder(2))
If !BA1->(DbSeek(xFilial("BA1")+MV_PAR01))
	MsgStop(STR0024) //"Usuário não encontrado!"
	Return .F.
EndIf
MV_PAR04 := BA1->BA1_DTVLCR
Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA261BXT ³ Autor ³ Eduardo Motta       ³ Data ³ 16.04.04 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Funcao que baixa titulo                                    ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function PLSA261Bxt

Local nRec
Local nRecBED := BED->(Recno())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Variavis PRIVATE devido a funcao F070TIT...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
PRIVATE aCaixaFin := BED->(xCxFina())
PRIVATE oFontLbl ; DEFINE FONT oFontLbl NAME "Arial" SIZE 6, 15 BOLD
PRIVATE nTotAGer  := 0
PRIVATE nTotADesc := 0
PRIVATE nTotAMul  := 0
PRIVATE nTotAJur  := 0
PRIVATE nTotADesp := 0
PRIVATE cLoteFin  := Space (4 )
PRIVATE cMarca    := GetMark()
PRIVATE cOld      := cCadastro
PRIVATE aCampos   := {}
PRIVATE cLote     := ""
PRIVATE lF070Auto  := .F.
PRIVATE lFini055	:= .F.
PRIVATE lValidou	:= .F. 
PRIVATE aDadosRef 		:= Array(7)
PRIVATE aDadosRet 		:= Array(7)
PRIVATE aDadosImp 		:= Array(3)
PRIVATE nIndexSE1 	:= ""
PRIVATE cIndexSE1 	:= ""
PRIVATE aAutoCab 	:= {}	//	Criado para evitar ERROR.LOG no FA070TIT()
PRIVATE lOracle		:= "ORACLE"$Upper(TCGetDB())

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicia os arrays de  impostos do zero                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
aFill(aDadosRef,0)
aFill(aDadosRet,0)
aFill(aDadosImp,0)

BA1->(DbSetOrder(2))
If BED->BED_FATUR <> "2"
	MsgStop(STR0027) //"Via de Cartão não possui titulos para liquidar."
	Return
EndIf
SE1->(DbSetOrder(1))
If ! SE1->(DbSeek(xFilial("SE1")+BED->BED_PREFIX+BED->BED_NUMTIT+BED->BED_PARCEL+BED->BED_TIPTIT))
	MsgStop(STR0028+BED->(BED_PREFIX+BED_NUMTIT+BED_PARCEL+BED_TIPTIT)) //"Titulo não encontrado - "
	Return
Endif
If SE1->E1_SALDO == 0
	MsgStop(STR0029+BED->(BED_PREFIX+BED_NUMTIT+BED_PARCEL+BED_TIPTIT)) //"Titulo já baixado - "
	Return
Endif
BEGIN TRANSACTION
	Pergunte("FIN070",.F.)
	nRec := SE1->(Recno())
	FA070Tit("SE1",0,SE1->(Recno()))
	SE1->(DbGoTo(nRec))
	If SE1->E1_SALDO == 0
		BED->(DbGoto(nRecBED))
		RecLock("BED",.F.)
		BED->BED_FATUR := "3"
		MsUnlock()
	
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Atualiza via do cartao do usuario... 		                        ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If BA1->(DbSeek(xFilial("BA1")+BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG)))
			RecLock("BA1",.F.)
			BA1->BA1_VIACAR := BED->BED_VIACAR
			BA1->BA1_CDIDEN := BED->BED_CDIDEN
			BA1->BA1_DTVLCR := BED->BED_DATVAL
			MsUnLock()
			GrvVldCarUsr(BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC),BED->BED_DATVAL)
		Else
			MsgStop(STR0030+BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG)) //"Usuário não encontrado: "
		Endif
	
	Else
		MsgStop(STR0031,STR0032) //"Para emitir o Cartão de Identificação o titulo deve ser liquidado."###"Atenção!"
	Endif
END TRANSACTION
If SE1->E1_SALDO == 0
	PLSA261REC()
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA261EFA ³ Autor ³ Eduardo Motta       ³ Data ³ 15.04.04 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Reemite familia                                            ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function  Plsa261EFA(cAlias,nReg,nOpc)

Local cExpRdm := ""
Local aRet    := {}
Local cCodInt := BED->BED_CODINT
Local cCodigo := BED->BED_CDIDEN

BA3->(DbSetOrder(1))
If ! BA3->(DbSeek(xFilial("BA3")+BED->(BED_CODINT+BED_CODEMP+BED_MATRIC)))
	MsgStop(STR0025) //"Família não encontrada!"
	Return
EndIf

BA0->(DbSetOrder(1))
If BA0->(DbSeek(xFilial("BA0")+cCodInt))
	If Empty(BA0->BA0_EXPIDE)
		cExpRdm := AllTrim(GetNewPar("MV_PLSEXPI",""))
	Else
		cExpRdm := AllTrim(BA0->BA0_EXPIDE)
	Endif
	If ExistBlock(cExpRdm)
		aRet := ExecBlock(cExpRdm,.F.,.F.,{cCodigo,BDE->BDE_MOTIVO,cCodInt,NIL,4,.t.})
	Else
		aRet := Plsa264({cCodigo,BDE->BDE_MOTIVO,cCodInt,NIL,4,.t.})
	EndIf
	If ValType(aRet) <> "A"
		aRet := {.F.,{0}}
	Endif
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ PLSA261EUS ³ Autor ³ Eduardo Motta       ³ Data ³ 15.04.04 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Reemite usuario                                            ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function  Plsa261EUS(cAlias,nReg,nOpc)

Local cExpRdm := ""
Local aRet 	  := {}
Local cCodInt := BED->BED_CODINT
Local cCodigo := BED->BED_CDIDEN

BA1->(DbSetOrder(2))
If !BA1->(DbSeek(xFilial("BA1")+BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG+BED_DIGITO)))
	MsgStop(STR0024) //"Usuário não encontrado!"
	Return
EndIf

BA3->(DbSetOrder(1))
If ! BA3->(DbSeek(xFilial("BA3")+BED->(BED_CODINT+BED_CODEMP+BED_MATRIC)))
	MsgStop(STR0025) //"Família não encontrada!"
	Return
EndIf

BA0->(DbSetOrder(1))
If BA0->(DbSeek(xFilial("BA0")+cCodInt))
	If Empty(BA0->BA0_EXPIDE)
		cExpRdm := AllTrim(GetNewPar("MV_PLSEXPI",""))
	Else
		cExpRdm := AllTrim(BA0->BA0_EXPIDE)
	Endif
	If ExistBlock(cExpRdm)
		aRet := ExecBlock(cExpRdm,.F.,.F.,{cCodigo,BDE->BDE_MOTIVO,cCodInt,NIL,3,.t.})
	Else
		aRet := Plsa264({cCodigo,BDE->BDE_MOTIVO,cCodInt,NIL,3,.t.})
	EndIf
	If ValType(aRet) <> "A"
		aRet := {.F.,{0}}
	Endif
Endif

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±±
±±³Funcao    ³ Plsa261Vus ³ Autor ³ Eduardo Motta       ³ Data ³ 16.04.04 ³±±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±±
±±³Descricao ³ Validacao do pergunte		                              ³±±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function Plsa261Vus()
BA1->(DbSetOrder(2))
If !BA1->(DbSeek(xFilial()+MV_PAR01))
	MsgStop(STR0024) //"Usuário não encontrado!"
	Return
EndIf
MV_PAR04 := BA1->BA1_DTVLCR
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³AjustaSX1 ºAutor  ³Thiago Machado Correaº Data ³  24/08/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Cria o pergunte padrao                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                          º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function AjustaSX1()

Local aRegs	:=	{}

aadd(aRegs,{"PLS262","05",STR0033  ,"","","mv_ch5","C", 60,0,0,"G","","mv_par05","","","","","","","","","","","","","","","","","","","","","","","","","BB3",""}) //"Local Grav."
aadd(aRegs,{"PLS262","06","Nome Cartão?","","","mv_ch6","C",01,0,0,"C","","mv_par06","Nome Cart.","","","","","Nome usuário","","","","","","","","","","","","","","","","","","","",""})

PlsVldPerg( aRegs )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PLSA261BLQ ³ Autor ³Daher				³ Data ³ 24.02.2005 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ (des)Bloqueio da via do cartao                               ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PLSA261BLQ(cAlias,nReg,nOpc)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Inicializa variaveis													 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oDlg
Local oSay
Local oGet
Local oFont, oFontAutor
Local nOpca := 0
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Uso na enchoiceBar...                                                    ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
LOCAL aButtons   := {}
LOCAL bOK        := {|| nOpca := 1,Iif(BlqConfDB("BG"+cMotBlo,dDatBlq,BED->BED_CODBLO,STR0034, "SX5"),; //" desta via de identificacao ? "
oDlg:End(),nOpca:=2),If(nOpca==1,oDlg:End(),.F.) }
LOCAL bCancel    := {|| oDlg:End() }
Local dDatBlq    := CTOD("")
Local cObsBlq
Local lDesBlo
Local lBlqVEnc   := GetNewPar("MV_PLBLQVE",.F.) 
Local lContCp    := BED->( FieldPos("BED_CTRBLO") ) > 0 .And. BED->( FieldPos("BED_STAANB") ) > 0
Local aLoiBlq    := {}
PRIVATE cMotBlo
PRIVATE cDesBlq
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica dicionario														 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If  BED->( FieldPos("BED_CODBLO") ) == 0 .or. ;
	BED->( FieldPos("BED_BLOIDE") ) == 0 .or. ;
	! PLSALIASEX("B1D")
	MsgStop(STR0019) //"Dicionario de dados desatualizado!!!"
	Return
Endif
cObsBlq  := Space(LEN(B1D->B1D_OBS))
lDesBlo  := val(Left(BED->BED_CODBLO,1)) < 5
cMotBlo  := Space(LEN(BED->BED_CODBLO)+1)
cDesBlq  := Space(30)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define fontes utilizadas somente nesta funcao...                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE FONT oFont NAME "Arial" SIZE 0,-11
DEFINE FONT oFontAutor NAME "Arial" SIZE 000,-017
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Define dialogo...                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DEFINE MSDIALOG oDlg TITLE cCadastro FROM 008.2,010.3 TO 034.4,100.3 OF GetWndDefault()

@ 014, 003 GROUP oGrupo TO 075, 350 PIXEL OF oDlg LABEL " "+STR0035 +" "  COLOR CLR_BLACK, CLR_HRED //"Dados do Beneficiario"
@ 024, 008  Say oSay PROMPT STR0036 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Operadora           "
@ 024, 070  Say oSay PROMPT ": "+BED->BED_CODINT+" - "+Posicione("BA0",1,xFilial("BA0")+BED->BED_CODINT,"BA0_NOMINT") SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
@ 034, 008  Say oSay PROMPT STR0037 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Matricula           "
@ 034, 070  Say oSay PROMPT ": "+ BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG+BED_DIGITO) PICTURE "@R !!!.!!!.!!!!.!!!!!!-!!-!" SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
@ 044, 008  Say oSay PROMPT STR0038 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Nome			     "
@ 044, 070  Say oSay PROMPT ": "+BED->BED_NOMUSR SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
@ 054, 008  Say oSay PROMPT STR0039 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Via Ident.			 "
@ 054, 070  Say oSay PROMPT ": "+alltrim(str(BED->BED_VIACAR)) SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
@ 064, 008  Say oSay PROMPT STR0040 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Data Validade		 "
@ 064, 070  Say oSay PROMPT ": "+DTOC(BED->BED_DATVAL) SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK

@ 084, 003 GROUP oGrupo TO 113, 350 PIXEL OF oDlg LABEL " "+STR0041 +" "  COLOR CLR_BLACK, CLR_HRED //"Motivo do Bloqueio"
If lDesBlo
	@ 092,008 Say oSay PROMPT STR0042 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"IDENTIFICACAO NAO BLOQUEADA"
Else
	@ 092, 008  Say oSay PROMPT STR0043 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Bloqueio"
	@ 092, 070  Say oSay PROMPT ": "+BED->BED_CODBLO+ " - " + Posicione("SX5",1,xFilial("SX5")+"BG"+BED->BED_CODBLO,"X5_DESCRI")  SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
	@ 102, 008  Say oSay PROMPT STR0044 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Data Bloqueio "
	If BED->(FieldPos("BED_DATBLO")) > 0
		@ 102, 070  Say oSay PROMPT ": "+DTOC(BED->BED_DATBLO) SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
	Endif
EndIf

@ 119, 003 GROUP oGrupo TO 190, 350 PIXEL OF oDlg LABEL " "+If(lDesBlo,"B",STR0045)+STR0046 +" "  COLOR CLR_BLACK, CLR_HRED //"Desb"###"loquear Identificao"

@ 125.5, 060   Say oSay PROMPT STR0047 SIZE 250,010 OF oDlg PIXEL FONT oFontAutor COLOR CLR_BLACK //"Tipo"
@ 125.5, 124.5 Say oSay PROMPT ": " SIZE 250,010 OF oDlg PIXEL FONT oFontAutor COLOR CLR_BLACK
@ 125.5, 130   Say oSay PROMPT If( lDesBlo,STR0043,STR0048) SIZE 250,010 OF oDlg PIXEL FONT oFontAutorAutor COLOR CLR_HRED //"Bloqueio"###"DesBloqueio"

@ 139, 060  Say oSay PROMPT STR0049 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Data"
@ 139, 125  Say oSay PROMPT ": " SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
@ 139, 130  MSGET oGet VAR dDatBlq SIZE 40,0 OF oDlg FONT oFont PICTURE "@D" PIXEL

@ 154, 060  Say oSay PROMPT STR0050+If(lDesBlo,"B",STR0045)+STR0051 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Motivo do "###"Desb"###"loqueio"
@ 154, 125  Say oSay PROMPT ": " SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
@ 154, 130  MSGET oGet VAR cMotBlo SIZE 0,0 OF oDlg FONT oFont PICTURE "99" F3 "BG" VALID PLMOTVALID(lDesBlo,cMotBlo) PIXEL

@ 154, 155  MSGET oGet VAR cDesBlq SIZE 0,0 OF oDlg FONT oFont PICTURE "@!" WHEN .F. PIXEL

@ 169, 060  Say oSay PROMPT STR0052 SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK //"Observação"
@ 169, 125  Say oSay PROMPT ": " SIZE 250,010 OF oDlg PIXEL FONT oFont COLOR CLR_BLACK
@ 169, 130  MSGET oGet VAR cObsBlq SIZE 0,0 OF oDlg FONT oFont PICTURE "@S35!" PIXEL

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ativa Dialog...                                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg, bOK, bCancel, .F., aButtons) Center

If nOpca == K_OK    

	BlqIdent(If(lDesBlo,"1","0"), dDatBlq, cMotBlo, cObsBlq)   
 
	If lBlqVEnc .And. lContCp

		BED->(RecLock("BED",.F.))
		
		If lDesblo
			BED->BED_STAANB := BED->BED_STACAR		   		
			BED->BED_STACAR := "3"   
			BED->BED_CTRBLO := BED->BED_CDIDEN
			BED->(MsUnlock())
		Else
			BED->BED_STACAR:= IIF(!Empty(BED->BED_STAANB),BED->BED_STAANB,"2")		   		
			BED->BED_CTRBLO := ""
		EndIf
		BED->(MsUnlock())
	
	
		AADD(aLoiBlq,{BED->BED_FILIAL, BED->BED_CODINT,BED->BED_CDIDEN})
	
		PLAJCABDE(aLoiBlq,If(lDesBlo,"1","0"))				
			
	EndIf
EndIf

Return

static function PLMOTVALID(lDesBlo,cMotBlo)
If lDesBlo .and. cMotBlo < "50"
	msginfo(STR0053)  //"Escolha um codigo referente a bloqueio."
	return .F.
elseif !lDesBlo .and. cMotBlo > "50"
	msginfo(STR0054) //"Escolha um codigo referente a desbloqueio."
	return .F.
endif
cDesBlq := Posicione("SX5",1,xFilial("SX5")+"BG"+cMotBlo,"X5_DESCRI")
return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BlqIdent	ºAutor  ³Daher			     º Data ³  22/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Grava uma Bloqueia ou Desbloqueia ident			          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function BlqIdent(cTipo,dDatBlq,cMotBlo,cObsBlq)
//cTipo = 1 Bloqueio
//cTipo = 0 Desbloqueio
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Grava historico de bloqueio/desbloq de identificacao    				 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
B1D->(RecLock("B1D",.T.))

B1D->B1D_FILIAL  := xFilial("B1D")
B1D->B1D_MATRIC  := BED->(BED_CODINT+BED_CODEMP+BED_MATRIC)
B1D->B1D_TIPREG  := BED->BED_TIPREG
B1D->B1D_DIGITO  := BED->BED_DIGITO
B1D->B1D_TIPO	 := cTipo
B1D->B1D_DATA	 := dDatBlq
B1D->B1D_MOTBLO  := cMotBlo
B1D->B1D_OBS	 := cObsBlq
B1D->B1D_USUOPE	 := PLSRtCdUsr()
B1D->B1D_VIACAR	 := BED->BED_VIACAR

B1D->(MsUnlock())
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ No Registro																 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
BED->(RecLock("BED",.F.))
BED->BED_CODBLO := cMotBlo
If BED->(FieldPos("BED_DATBLO")) > 0
	BED->BED_DATBLO := dDatBlq
Endif
BED->BED_BLOIDE := cTipo
BED->(MsUnlock())

return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³BlqConfDB ºAutor  ³Daher			     º Data ³  22/02/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Confirma se Bloqueia ou Desbloqueia ident			          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function BlqConfDB(cMotBlq,dDatBlq,cBloqueio, cOpcao, cAlias)
Local lRet := .F.
Local cTitulo := STR0055+If(Empty(cBloqueio) ,STR0043,STR0048)+cOpcao //"Confirma o "###"Bloqueio"###"DesBloqueio"

If Empty(cMotBlq) .OR. Empty(dDatBlq)
	MsgStop(STR0056) //"Campos Motivo do Bloqueio/Data do Bloqueio são obrigatórios!"
	lRet := .F.
Else
	&(cAlias)->( dbSetorder(01) )
	If ! &(cAlias)->( dbSeek(xFilial(cAlias)+cMotBlq) )
		MsgStop(STR0057)			 //"Motivo de bloqueio nao cadastrado na base de dados."
		lRet := .F.
	Else
		lRet := Aviso( If( val(Left(BED->BED_CODBLO,1)) < 5,STR0043,STR0048), cTitulo, { STR0058, STR0059}, 2 ) == 1 //"Bloqueio"###"DesBloqueio"###"Sim"###"Nao"
	EndIf
EndIf

Return(lRet)



Function PLSA261REC()

If FindFunction("PLSR737")
	If ! ExistBlock("PLS737IM")
		PLSR737()
	Else
		ExecBlock("PLS737IM",.F.,.F.)
	Endif
Endif

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³ PL261UVC   ³ Autor ³ Sandro Hoffman      ³ Data ³ 01.09.2006 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Retorna a ultima via de carteirinha emitida                  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function PL261UVC(cCodInt, cCodEmp, cMatric, cTipReg, nUltVia, nSkip)

Local cSQL, aRet, i
Local lCodAnt	:= BED->( FieldPos("BED_CODANT") ) <> 0 .And. BED->( FieldPos("BED_ORIGEM") ) <> 0
Default nUltVia := -1
Default nSkip   := 0

cSQL := "SELECT BED_VIACAR, BED_CDIDEN, BED_DATVAL "
If lCodAnt
	cSQL += ", BED_CODANT "
Endif
cSQL += "  FROM " + RetSqlName("BED")
cSQL += " WHERE BED_FILIAL = '" + xFilial("BED") + "'"
cSQL += "   AND BED_CODINT = '" + cCodInt + "'"
cSQL += "   AND BED_CODEMP = '" + cCodEmp + "'"
cSQL += "   AND BED_MATRIC = '" + cMatric + "'"
cSQL += "   AND BED_TIPREG = '" + cTipReg + "'"
cSQL += "   AND D_E_L_E_T_ = ' '"
cSQL += " ORDER BY BED_VIACAR DESC"

PlsQuery(cSQL,"TrbBED")

For i := 1 To nSkip
	TrbBED->(DbSkip())
Next i

If ! TrbBED->(Eof())
	If lCodAnt
		aRet := { TrbBED->BED_VIACAR, TrbBED->BED_CDIDEN, TrbBED->BED_DATVAL, TrbBED->BED_CODANT}
	Else
		aRet := { TrbBED->BED_VIACAR, TrbBED->BED_CDIDEN, TrbBED->BED_DATVAL}
	Endif
Else
	aRet := { nUltVia, "", StoD("") }
EndIf

TrbBED->(DbCloseArea())

Return aRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³MenuDef   ³ Autor ³ Darcio R. Sporl       ³ Data ³02/01/2007³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Utilizacao de menu Funcional                               ³±±
±±³          ³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array com opcoes da rotina.                                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Parametros do array a Rotina:                               ³±±
±±³          ³1. Nome a aparecer no cabecalho                             ³±±
±±³          ³2. Nome da Rotina associada                                 ³±±
±±³          ³3. Reservado                                                ³±±
±±³          ³4. Tipo de Transa‡„o a ser efetuada:                        ³±±
±±³          ³	  1 - Pesquisa e Posiciona em um Banco de Dados           ³±±
±±³          ³    2 - Simplesmente Mostra os Campos                       ³±±
±±³          ³    3 - Inclui registros no Bancos de Dados                 ³±±
±±³          ³    4 - Altera o registro corrente                          ³±±
±±³          ³    5 - Remove o registro corrente do Banco de Dados        ³±±
±±³          ³5. Nivel de acesso                                          ³±±
±±³          ³6. Habilita Menu Funcional                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function MenuDef()
	Private aRotina := {}

	If cMenu == 0

		aRotina := {	{ STR0001	, 'AxPesqui'  														, 0 , K_Pesquisar		, 0, .F.},; //"Pesquisar"
		{ STR0002	, 'AxVisual'  														, 0 , K_Visualizar	, 0, Nil},; //"Visualizar"
		{ STR0003	, 'PLSA261VIA(BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG+BED_DIGITO))', 0 , K_Visualizar	, 0, Nil},; //"Vias Usuario"
		{ STR0004	, 'PL261INC'														, 0 , K_Incluir			, 0, Nil},; //"Incluir"
		{ STR0005	, 'PLSA261BXT'														, 0 , K_Visualizar	, 0, Nil},; //"Baixa Titulo"
		{ STR0006	, 'PL261EXCMe'	, 0 , K_DefExc			, 0, Nil},; //"Excluir"
		{ STR0007	, 'Plsa261EFA'														, 0 , K_Visualizar	, 0, Nil},; //"Re-Emite Fam."
		{ STR0008	, 'Plsa261EUS'														, 0 , K_Visualizar	, 0, Nil},; //"Re-Emite Usr."
		{ STR0009	, 'Plsa261Blq'														, 0 , K_Alterar			, 0, Nil},; //"(des)Bloqueio"
		{ STR0010	, 'PLSA261REC'														, 0 , K_Alterar			, 0, Nil}} //"Imprimir Recibo"

	ElseIf cMenu == 1
		aRotina :=	{	{ STR0001 , 'AxPesqui', 0, K_Pesquisar  },; //"Pesquisar"
		{ STR0002   , 'AxVisual', 0, K_Visualizar },; //"Visualizar"
		{ STR0004   , 'AxInclui', 0, K_Incluir    },; //"Incluir"
		{ STR0012   , 'AxAltera', 0, K_Alterar    },; //"Alterar"
		{ STR0006	, 'AxDeleta', 0, K_Excluir    } } //"Excluir"

	Else
		aRotina :=  {	{ STR0001	, 'AxPesqui'  														, 0 , K_Pesquisar		, 0, .F.},; //"Pesquisar"
		{ STR0002	, 'AxVisual'  														, 0 , K_Visualizar	, 0, Nil},; //"Visualizar"
		{ STR0003	, 'PLSA261VIA(BED->(BED_CODINT+BED_CODEMP+BED_MATRIC+BED_TIPREG+BED_DIGITO))', 0 , K_Visualizar	, 0, Nil},; //"Vias Usuario"
		{ STR0004	, 'PL261INC'														, 0 , K_Incluir			, 0, Nil},; //"Incluir"
		{ STR0005	, 'PLSA261BXT'														, 0 , K_Visualizar	, 0, Nil},; //"Baixa Titulo"
		{ STR0006	, 'PL261EXCMe'	, 0 , K_DefExc			, 0, Nil},; //"Excluir"
		{ STR0007	, 'Plsa261EFA'														, 0 , K_Visualizar	, 0, Nil},; //"Re-Emite Fam."
		{ STR0008	, 'Plsa261EUS'														, 0 , K_Visualizar	, 0, Nil},; //"Re-Emite Usr."
		{ STR0009	, 'Plsa261Blq'														, 0 , K_Alterar			, 0, Nil},; //"(des)Bloqueio"
		{ STR0010	, 'PLSA261REC'														, 0 , K_Alterar			, 0, Nil},; //"Imprimir Recibo"
		{ STR0001   , 'AxPesqui', 0, K_Pesquisar  },; //"Pesquisar"
		{ STR0002   , 'AxVisual', 0, K_Visualizar },; //"Visualizar"
		{ STR0004   , 'AxInclui', 0, K_Incluir    },; //"Incluir"
		{ STR0012   , 'AxAltera', 0, K_Alterar    },; //"Alterar"
		{ STR0006	, 'AxDeleta', 0, K_Excluir    } } //"Excluir"


	Endif
Return(aRotina)

/*/{Protheus.doc} PLSA261EXC
Menu PLSA261EXC
@author Roberto Barbosa
@since 04/2019
/*/
Function PL261EXCMe()
	PLSA261EXC("BED", 5, BED->(Recno()))
Return