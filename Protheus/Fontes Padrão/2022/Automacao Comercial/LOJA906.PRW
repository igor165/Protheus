#INCLUDE "LOJA906.ch"
#include "protheus.ch"

Static _USER_ADMIN	:= FWIsAdmin()
Static _lUdsC6RES := NIL
//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA9006
Monitor de Serviços E-Commerce
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample LOJA906()

/*/ 
//------------------------------------------------------------------

Function LOJA906()
Local aFixes := {} //Array Fixos                                                   
Local aTarefas := {}  //Array tarefas      
Local oDlg, oLbx //Dialog, Label
Local oButton2, oButton3, oButton4, oButton5, oButton6, oButton7, oButton8, oButton9, oButton10, oButton11, oButton12 //Botoes
Local aBotoesTmp := {} //Botoes temporarios
Local aAreaSM0 := SM0->(GetArea()) //WorkArea SM0
Local lIntAgrup  := SuperGetMv( "MV_LJECMM3",, .F. ) //Utiliza a integração de Agrupadores?

Private aCores    := {}
Private cCadastro := STR0001  //"Monitor de Serviços E-Commerce"

Private aRotina := {{STR0002,"PesqBrw",0,1},; //"Pesquisar"
{STR0003          ,"Lj906Alt",0,2},; //"Alterar"
{STR0004         ,"Lj906Exc",0,2},; //"Executar"
{STR0005          ,"Lj906Log",0,3},;                     //"Legenda"
{STR0006        ,"LOJR902",0,3},; //"Relatório"
{STR0007    ,"LOJR903",0,3}} //"Ped. C/ Prob."


If ExistFunc("Lj904IntOk")
	Lj904IntOk()
EndIf


AADD(aCores,{"XX1_STATUS == '0'" ,"BR_VERDE" })
AADD(aCores,{"XX1_STATUS == '1'" ,"BR_VERMELHO" })
AADD(aCores,{"XX1_STATUS == '2'" ,"BR_PRETO" })

AADD(aFixes,{ STR0008  ,"XX1_ROTINA"}) //"Serviço"
AADD(aFixes,{ STR0009   ,"XX1_STATUS"}) //"Status"
AADD(aFixes,{ STR0010  ,"XX1_ULTDIA"}) //"Ult.Dia"
AADD(aFixes,{ STR0011 ,"XX1_ULTHOR"}) //"Ult.Hora"

//Reserva de estoque habilitada, verifica se o campo c6_reserva em uso
If !SuperGetMv("MV_RESAUT") .AND. SuperGetMv("MV_LJECOM0",.F., .F.)
	If ExistFunc("Lj901UsC6R") .AND. _lUdsC6RES = NIL
		_lUdsC6RES := Lj901UsC6R()
	EndIf
	If _lUdsC6RES <> NIL .AND.  !_lUdsC6RES				
		MsgAlert(STR0090)//"Habilitada a geração de reserva e-commerce através do parâmetro MV_LJECOM0, porém o campo C6_RESERVA não está em uso, não serão geradas reservas para os pedidos e-commerce até que o campo C6_RESERVA esteja como usado."
	EndIf
EndIf

//Inicializa cadastro das tarefas
Loja906W()

Lj906CrI(lIntAgrup)

aTarefas := Lj906BTar(lIntAgrup)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Mostra dados das tarefas					                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

RestArea(aAreaSM0)

DEFINE MSDIALOG oDlg FROM  0,0 TO 375,800 TITLE cCadastro   PIXEL
@ 009, 050 GROUP oGroup1 TO 171, 393 PROMPT STR0012 OF oDlg COLOR 0, 16777215 PIXEL //"Serviços"


@ 035,056	LISTBOX oLbx FIELDS ;
HEADER ;
STR0008,; //"Serviço"
STR0013,; //"Nome"
STR0009,; //"Status"
STR0014,; //"Último Sincronismo"
STR0015,; //"Resultado"
STR0050,; //"Sequência"
SIZE 333,147  NOSCROLL OF oDlg PIXEL 

oLbx:SetArray(aTarefas)


If Len(aTarefas) > 0
	oLbx:bLine:={ || {	IIF(oLbx:nAt > 0, aTarefas[oLbx:nAt,1],""),;
	IIF(oLbx:nAt > 0, Lj906GNTar(aTarefas[oLbx:nAt,1], lIntAgrup), ""),;
	IIF(oLbx:nAt > 0, aTarefas[oLbx:nAt,2], ""),;
	IIF(oLbx:nAt > 0, aTarefas[oLbx:nAt,3], ""),;
	IIF(oLbx:nAt > 0 , aTarefas[oLbx:nAt,4], ""),;
	IIF(oLbx:nAt > 0 , aTarefas[oLbx:nAt,5], "");
	}}
Else
	oLbx:bLine:={ || {	"",;
	"",;
	"",;
	"",;
	"",;
	"";
	}}
EndIf

oLbx:bLDblClick := {|| Lj906Log(@oLbx,@aTarefas, lIntAgrup)}

@ 036, 006 BUTTON oButton2 PROMPT STR0017 SIZE 037, 012 OF oDlg ACTION ( RestArea(aAreaSM0), Lj906Exc(@oLbx,@aTarefas), aTarefas := Lj906BTar(lIntAgrup), RestArea(aAreaSM0)) PIXEL //"  Executar   "
@ 052, 006 BUTTON oButton3 PROMPT STR0051 SIZE 037, 012 OF oDlg ACTION   Lj906EnvRec(aTarefas[oLbx:nAt,1], aTarefas[oLbx:nAt,5], 1) PIXEL //"XML Envio"
@ 068, 006 BUTTON oButton3 PROMPT STR0052 SIZE 037, 012 OF oDlg ACTION   Lj906EnvRec(aTarefas[oLbx:nAt,1], aTarefas[oLbx:nAt,5], 2) PIXEL //" XML Retorno"
@ 084, 006 BUTTON oButton4 PROMPT STR0018 SIZE 037, 012 OF oDlg ACTION Lj906Log(@oLbx,@aTarefas, lIntAgrup)	PIXEL //"    Log      "
@ 100, 006 BUTTON oButton6 PROMPT STR0007 SIZE 037, 012 OF oDlg ACTION LOJR903()				PIXEL     //"Ped. C/ Prob."
@ 116, 006 BUTTON oButton11 PROMPT STR0066 SIZE 037, 012 OF oDlg ACTION Lj906Track()	PIXEL //"Cons Tracker"
@ 132, 006 BUTTON oButton12 PROMPT STR0067 SIZE 037, 012 OF oDlg ACTION LOJA900H()				PIXEL     //"Val Produto"


aAdd(aBotoesTmp, { , { || LOJR902()  }, 	STR0019})

If _USER_ADMIN
	If FindFunction("LjIsLogEnable")
		aAdd(aBotoesTmp, { , { || Lj906AtLog() }, 	STR0068}) //"Atv/Inat Log"
	EndIf
	If FindFunction("LjGetLogFile")
		aAdd(aBotoesTmp, { , { || LjGetLogFile() }, STR0069}) //"Capturar Log"
	EndIf
	aAdd(aBotoesTmp, { , { || Lj906ConfPed() }, STR0080}) // "Confirmar Pedido"
	
EndIf

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{|| oDlg:End },{||oDlg:End()},,@aBotoesTmp, /* nRecno*/, /* cAlias*/, .F., .F., .F. , .F., .F., ) CENTERED

RestArea(aAreaSM0)

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} Loja906W
Wizard de Jobs da Integração e-commerce CiaShop
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Loja906W(()
/*/
//-------------------------------------------------------------------
Function Loja906W()
Local _nSeqXX1  := 0 //Sequencia do Job
Local _aTarefas := {} //Array de Tarefas
Local _cCodTarefa := "" //Codigo da Tarefa
Local _lExiste  := .T. //Tarefa cadastrada?
Local cAmbInteg := GetEnvServer() //ambiente a ser considerado no Schedule
Local cHoraInt  := "00:00" //Hora da integração
local _nX :=0 //Contador 2
Local _nI := 0 //Contador 3
Local aRotinas := {} //Array de Rotinas
Local aArea := GetArea() //WorkArea
Local nTamCod := 0 //Tamanho do codigo
Local lFuncXX1 := ExistFunc("FWOpenXX1")
Local lFuncXX2 := ExistFunc("FWOpenXX2")
Local cAmb := Upper(Alltrim(GetEnvServer() ) )

//Retorna as rotinas do Scheduler
aRotinas := Lj906RetRot()

//Cadastro de Tarefas
If !lFuncXX1
	DbSelectArea("XX1")
Else
	FWOpenXX1()
EndIf

//Cadastro de Tarefas
If !lFuncXX2
	DbSelectArea("XX2")
Else
	FWOpenXX2()
EndIf

XX1->(dbSetOrder(1))
XX1->(dbGoTop())
While !XX1->(eof())
	_nSeqXX1 := Val(XX1->XX1_CODIGO)
	
	For _nI := 1 To Len(aRotinas)	
		If RTrim(aRotinas[_nI]) == RTrim(XX1->XX1_ROTINA)
			//Verifica se o agendamento existe para a filial e o ambiente
			If AllTrim(Upper(XX1->XX1_ENV)) == cAmb .AND. Lj906AgFil(XX1->XX1_CODIGO, cEmpAnt, cFilAnt) 
				AADD(_aTarefas,{XX1->XX1_ROTINA})
			EndIf
		EndIf
	Next
	
	XX1->(DbSkip())
EndDo

nTamCod := Len(XX1->XX1_CODIGO)

If nTamCod = 0
	nTamCod := 6
EndIf

For _nI := 1 To Len(aRotinas)
	
	
	_lExiste := .F.
	
	_cRotina := aRotinas[_nI]
	
	For _nX := 1 to Len(_aTarefas)
		If Alltrim(_aTarefas[_nX][1]) == AllTrim(_cRotina)
			_lExiste := .T.
			Exit
		EndIf
	Next _nX
	
	If !_lExiste
		_nSeqXX1++
		_cCodTarefa := StrZero(_nSeqXX1,nTamCod)
		
		//Verifica se não existe o registro para não dar chave duplicada
		Do While XX1->(DbSeek(_cCodTarefa)) .OR. XX2->(DbSeek(_cCodTarefa))
			_nSeqXX1++
			_cCodTarefa := StrZero(_nSeqXX1,nTamCod)
		EndDo
			
		RecLock('XX1', .T.)
		XX1->XX1_CODIGO := _cCodTarefa
		XX1->XX1_USERID := "000000"
		XX1->XX1_ROTINA := _cRotina
		If ValType(XX1->XX1_DATA) == "C" 
			XX1->XX1_DATA   := DTOS(dDatabase)
		Elseif ValType(XX1->XX1_DATA) == "D" 
			XX1->XX1_DATA   := dDatabase
		EndIf
		XX1->XX1_HORA   := cHoraInt //"00:30"
		XX1->XX1_RECORR := "D(Each(.F.);Day(1);EveryDay(.T.););Execs(0000);Interval(00:00);"
		XX1->XX1_ENV    := cAmbInteg //"G0I95X"
		XX1->XX1_MODULO := 12
		XX1->XX1_STATUS := "1"
		MsUnlock()
		
		//Cadastro de Tarefas X Emp/Filial
		RecLock('XX2', .T.)
		XX2->XX2_AGEND := _cCodTarefa
		XX2->XX2_EMPFIL := cEmpAnt + "/" + cFilAnt
		MsUnLock()
	EndIf
	
Next _nI

RestArea(aArea)

Return .T.



//-------------------------------------------------------------------
/*/{Protheus.doc} Lj906GNTar
Retorna o Nome da tarefa
@param   	cAFunc -  Codigo da Rotina
@param  lIntAgrup - Integra Agrupadores
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj906GNTar(cAFunc)
/*/
//------------------------------------------------------------------
Static Function Lj906GNTar(cAFunc, lIntAgrup)

local cRet := "" //Retorno

default cAFunc := ""
Default lIntAgrup := .F.

cAFunc := AllTrim(Upper(cAFunc))

do case

	case cAFunc == "LOJA900"
		cRet := IIF(!lIntAgrup,  STR0021, STR0074)  //"Categorias"##"Agrupadores"

	case cAFunc == "LOJA900A"
		cRet := STR0022 //"Produtos"
		
	case cAFunc == "LOJA900B"
		cRet := IIF(!lIntAgrup, STR0023, STR0075) //"Produtos X Categorias"##
		
	case cAFunc == "LOJA900C"
		cRet := STR0024 //"Estoque / Preço"
		
	case cAFunc == "LOJA900D"
		cRet := STR0025 //"Características"
		
	case cAFunc == "LOJA901A"
		cRet := STR0026 //"Pedidos"
		
	case cAFunc == "LOJA901"
		cRet := STR0027 //"Compradores"
		
	case cAFunc == "LOJA900E"
		cRet := STR0028 //"Status de Pedidos"   
		
	case cAFunc == "LOJA900F"
		cRet := STR0058 //"Tabela de Preço Variante"  
		
	case cAFunc == "LOJA900I"
		cRet := STR0079 //"Cadastro de Filiais e Armazéns" 
		
	case cAFunc == "LOJA907"
		cRet := STR0055 //"Cancelamento de Boletos"
	case cAFunc == "LOJA900G"
		cRet :=  STR0060 //"Envio de Cadastros"	
		
	case cAFunc == "LOJA901C"
		cRet := STR0061 //"Recebimento de Dados"			
endcase

return cRet

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj906Log
Log de Serviço E-Commerce
@param   	oLbx - Linha do Grid
@param   	aTarefas - Array de Tarefas
@param 		lIntAgrup - Integra Agrupadores
@@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj906Log
/*/
//------------------------------------------------------------------
Static Function Lj906Log(oLbx,aTarefas, lIntAgrup)
Local _cStatus := 1 //Status da Tarefa
Local _cTarefa := Eval(oLbx:bLine)[1] //Codigo da Tarefa
Local oButton1 := NIL //Objeto Button1
Local oButton2 := NIL //Objeto Button2
Local oButton3 := NIL //Objeto Button3
Local oGet1 := NIL //Objeto Get1
Local oGroupLOG := NIL //Objeto grupo
Local oSay1 := NIL //Objeto Label
Local oDlg2 := NIL //Objeto Dialog
Local aLog := {} //Array de Log 
Local cDet := "" //Detalhe do erro     
Local cDet2 := "" //Detalhe


DEFINE MSDIALOG oDlg2 TITLE STR0029 FROM 000, 000  TO 300, 700 COLORS 0, 16777215 PIXEL //"Log de Serviço E-Commerce"

@ 003, 002 GROUP oGroupLOG TO 145, 344 PROMPT STR0030 OF oDlg2 COLOR  0, 16777215 PIXEL //"LOG"
@ 014, 020 SAY oSay1 PROMPT STR0008 SIZE 025, 007 OF oDlg2 COLORS 0, 16777215 PIXEL //"Serviço"
@ 013, 042 MSGET oGet1 VAR _cTarefa SIZE 073, 010   OF oDlg2 COLORS 0, 16777215 READONLY PIXEL

@ 026, 007 LISTBOX oLbxLog FIELDS ;
HEADER ;
STR0031,; //"Data"
STR0032,; //"Hora Inicial"
STR0033,; //"Hora Final"
STR0015,; //"Resultado" 
STR0050,;  //Sequencia
SIZE 330, 113 OF oDlg2 PIXEL ColSizes 50,50

aLog := Lj906BRes(_cTarefa)
oLbxLog:SetArray(aLog)

if Len(aLog) > 0
	oLbxLog:bLine:={ || {substr(aLog[oLbxLog:nAt,4],7,2)+"/"+substr(aLog[oLbxLog:nAt,4],5,2)+"/"+substr(aLog[oLbxLog:nAt,4],1,4),;
	aLog[oLbxLog:nAt,5],;
	aLog[oLbxLog:nAt,6],;
	IIF (aLog[oLbxLog:nAt,7] == "1",STR0034,IIF (aLog[oLbxLog:nAt,7] == "2",STR0035,"")),;//"Sucesso"###"Erro"
	aLog[oLbxLog:nAt,3] }}     
	cDet := aLog[oLbxLog:nAt,3]  
	cDet2 := aLog[oLbxLog:nAt,2]
EndIf

@ 012, 298 BUTTON oButton1 PROMPT STR0036   SIZE 037, 012 OF oDlg2 ACTION oDlg2:End() PIXEL //"Voltar"
@ 012, 258 BUTTON oButton2 PROMPT STR0037 SIZE 037, 012 OF oDlg2 ACTION Lj906Det(@oLbxLog,@aLog,@_cTarefa, IIf( oLbxLog:nAt > 0 .AND. Len(aLog) > 0 , aLog[oLbxLog:nAt,3] , cDet), lIntAgrup) PIXEL //"Detalhes"
@ 012, 218 BUTTON oButton3 PROMPT STR0038    SIZE 037, 012 OF oDlg2 ACTION  IIf( oLbxLog:nAt > 0 .AND. Len(aLog) > 0, Lj906Err(aLog[oLbxLog:nAt,2], aLog[oLbxLog:nAt,3]) , .T. )  PIXEL //"Erros"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³LOJA906   ºAutor  ³Microsiga           º Data ³  01/09/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

ACTIVATE MSDIALOG oDlg2 CENTERED

Return .T. 
//------------------------------------------------------------------
/*/{Protheus.doc} Lj906Err
Função para visualizar a descricao do erro
@param   	cAServ - Codigo do Serviço
@param   	aASeq - Sequencia de Execução
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj906Err(cAServ, aASeq) 
/*/
//------------------------------------------------------------------
Static function Lj906Err(cAServ, aASeq)    

local cError     := "" //Codigo do Erro do parser
local cWarning   := "" //Codigo de Altera do parsert
local cTexto     := "" //TExto
local oDlgErr  	:=  NIL //Objeto Dialog
local oMemo	:= NIL //Objeto Memo
local oButton1    := NIL //Obejto Botão
Local oRetXML   := 0 //Objeto XML Parseado

dbSelectArea("MGM")
MGM->(dbSetOrder(1))
if !MGM->(DBSeek(xFilial("MGM") + cAServ + aASeq)) 
	return
endif   
      
if "<?XML" == Upper(SubStr(MGM->MGM_XMLRET,1,5))    

	oRetXML := XmlParser(MGM->MGM_XMLRET, "_", @cError, @cWarning) 
	If !Empty(cError) .AND. Valtype(oRetXML) == "O"
		if AllTrim(MGM->MGM_SERVIC) == "LOJA901A"
			cTexto := oRetXML:_RECEIPTLIST:_RESULTCODE:TEXT + " - " + oRetXML:_RECEIPTLIST:_RESULTTEXT:TEXT  
			if Type("oRetXML:_RECEIPTLIST:_XMLERROR:_MESSAGE:TEXT") == "C"
				cTexto += Chr(13) + Chr(10) + oRetXML:_RECEIPTLIST:_XMLERROR:_MESSAGE:TEXT	
			endif
		elseif AllTrim(MGM->MGM_SERVIC) == "LOJA901"
			cTexto := oRetXML:_SHOPPERLIST:_RESULTCODE:TEXT + " - " + oRetXML:_SHOPPERLIST:_RESULTTEXT:TEXT  
			if Type("oRetXML:_SHOPPERLIST:_XMLERROR:_MESSAGE:TEXT") == "C"
				cTexto += Chr(13) + Chr(10) + oRetXML:_SHOPPERLIST:_XMLERROR:_MESSAGE:TEXT	
			endif			
		else
			cTexto := oRetXML:_RESULT:_RESULTCODE:TEXT + " - " + oRetXML:_RESULT:_RESULTTEXT:TEXT  
			if Type("oRetXML:_RESULT:_XMLERROR:_MESSAGE:TEXT") == "C"
				cTexto += Chr(13) + Chr(10) + oRetXML:_RESULT:_XMLERROR:_MESSAGE:TEXT	
			endif		
		endif
	Else
		cTexto := MGM->MGM_XMLRET
	EndIf
	
else
	cTexto := MGM->MGM_XMLRET
endif     

           
DEFINE MSDIALOG oDlgErr TITLE STR0038 FROM 0,0 TO 240,500 PIXEL   //"Erros"

oMemo := tMultiget():New(10,10,{|u|if(Pcount()>0,cTexto:=u,cTexto)},oDlgErr,230,95,,,,,,.T.)

@ 108, 203 BUTTON oButton1 PROMPT STR0036 SIZE 037, 012 OF oDlgErr ACTION oDlgErr:End() PIXEL //"Voltar"

ACTIVATE MSDIALOG oDlgErr CENTER

return


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj906Det
Função para buscar Detalhe de LOG de comunicação
@param   	oLbxLog -  Label
@param   	aParam - Array de Log
@param   	_cServico - Codigo do Serviço 
@param   	_cSeq - Sequencia
@param		lIntAgrup - Integra Agrupadores
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj906Det(oLbxLog,aLog,_cServico,_cSe
/*/
//-------------------------------------------------------------------
Static Function Lj906Det(oLbxLog,aLog,_cServico,_cSeq, lIntAgrup)
Local cAlias  := "" //Alias
Local aAlias  := {} //Dados do Alias

Local aFiltro := {}  //Filtro
local cFiltro := ""	//String do Filtro
local bFiltro	:= { || } //Code-block do filtro

If Len(aLog) > 0
	
	aAlias := Lj906BAli(_cServico, lIntAgrup)
	
	If len(aAlias) > 0
		
		cAlias := aAlias[1][2]
		
		nLinIni := 10
		nColIni := 0
		nLinFim := 300
		nColFim := 900      
		
		
		dbSelectArea(cAlias)
        (cAlias)->( DbSetOrder(1) )
		cFiltro := aAlias[1][4] + " == '" + xFilial(cAlias) + "' .AND. " + aAlias[1][5] + " == '" + _cSeq + "'"
		bFiltro := {|| FilBrowse(cAlias, @aFiltro, @cFiltro) }		 
		EndFilBrw(cAlias, @aFiltro)
		Eval(bFiltro, aFiltro)		
		
		aBotoes := {}
		aHeader := Lj906THdr(cAlias)
		aCols   := Lj906TCols(cAlias,aHeader)
		nOpcao  := Lj906TShow(cAlias,aAlias[1][3],aHeader,aCols,,nLinIni,nColIni,nLinFim,nColFim)
		
		EndFilBrw(cAlias, @aFiltro)
	EndIf
	
EndIf

Return .T.


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj906BTar
Busca Tarefas
@param lIntAgrup - Utiliza a Integracao de Agrupadores (default .F.)
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj906BTar()
/*/
//------------------------------------------------------------------
Static Function Lj906BTar(lIntAgrup)
Local aTarefas := {} //Array de Tarefas
Local cData := "" //Data da Tarefa
Local cRotina := "" //Rotina
Local aLog := {} //Log de Execução
Local cResultado := "" //Resultado
Local cSeq := "" //Sequencia
Local aLj900G := {} //Lista de rotinas executadas pelo Loja900G
Local aLj901C := {} //lista de rotinas executadas pelo LOJA901C
//Verifica se os jobs de integração estão ativos
Local lAtivo := .F. //job Ativo
Local nPosIni := 0 //Posicao Job
Local cJobIni := "" //Job
Local aLj900GT := {} //Lista de rotinas executadas pelo Loja900G
Local aLj901CT := {} //lista de rotinas executadas pelo LOJA901C
Local cAmb := Upper(Alltrim(GetEnvServer() ) )
Local cEmpAmb := cEmpAnt // Alltrim(FWGrpCompany())
Local cFilAmb := cFilAnt //AllTrim(FWCodFil())
Local aArea := GetArea()
Local lFuncXX1 := ExistFunc("FWOpenXX1")
Local lFuncXX2 := ExistFunc("FWOpenXX2")

Default lIntAgrup := .f.

If Lj906jAtb("LOJA900G")

	cRotina := "LOJA900G"
	aLog    := Lj906BRes(cRotina,.T., lIntAgrup)

    If Len(aLog) > 0
        cResultado := IIF (aLog[1][7] == "1",STR0034,STR0035) //"Sucesso"###"Erro"
        cData       := DToC(SToD(aLog[1,4])) + " - " + aLog[1,5]
        cSeq := aLog[1][3]
    EndIf

    AADD(aTarefas, {cRotina     ,;
                    STR0062     ,; //"Job Ativo"
                    cData       ,;
                    cResultado  ,;
                    cSeq}       )

    //Rotinas chamadas pelo job loja900G	
    aLj900G := {"LOJA900", "LOJA900A", "LOJA900B", "LOJA900C", "LOJA900D", "LOJA900E", "LOJA900F", "LOJA907"}

ElseIf Lj906TAtb("LOJA900G")
    aLj900GT := {"LOJA900", "LOJA900A", "LOJA900B", "LOJA900C", "LOJA900D", "LOJA900E", "LOJA900F", "LOJA907"}

EndIf

If Lj906jAtb("LOJA901C")
	cRotina := "LOJA901C"
	aLog    := Lj906BRes(cRotina,.T., lIntAgrup)

    If Len(aLog) > 0
        cResultado := IIF (aLog[1][7] == "1",STR0034,STR0035) //"Sucesso"###"Erro"
        cData      := DToC(SToD(aLog[1,4])) + " - " + aLog[1,5]
        cSeq       := aLog[1][3]
    EndIf

    AADD(aTarefas, {cRotina     ,;
                    STR0062     ,; //"Job Ativo"
                    cData       ,;
                    cResultado  ,;
                    cSeq}       )
			
	aLj901C := {"LOJA901", "LOJA901A", "LOJA901B"}

ElseIf Lj906TAtb("LOJA901C")
	aLj901CT := {"LOJA901", "LOJA901A", "LOJA901B"}

EndIf

If !lFuncXX1
	DbSelectArea("XX1")
Else
	FWOpenXX1()
EndIf

XX1->(dbSetOrder(1))
XX1->(dbGoTop())
While !XX1->(EOF())
	
	If ("LOJA900" $ XX1->XX1_ROTINA .OR.  "LOJA901" $ XX1->XX1_ROTINA .OR. "LOJA907" == Rtrim(XX1->XX1_ROTINA))  .AND. ;
		(AllTrim(Upper(XX1->XX1_ENV)) == cAmb .AND. Lj906AgFil( XX1->XX1_CODIGO, cEmpAmb, cFilAmb)) //Verifica se é este agendamento
		
		cRotina := Alltrim(XX1->XX1_ROTINA)
		
		if aScanX(aTarefas, {|X| X[1] == cRotina}) <= 0
			lAtivo     := .F. //job Ativo
			cResultado := ""
			cData      := ""
            cSeq       := ""

			aLog := Lj906BRes(cRotina,.T., lIntAgrup)

			If Len(aLog) > 0
				cResultado := IIF (aLog[1][7] == "1",STR0034,STR0035) //"Sucesso"###"Erro"
				cData      := DToC(SToD(aLog[1,4])) + " - " + aLog[1,5]
				cSeq       := aLog[1][3]
			EndIf
			
			//Tarefa Ativa?
			lAtivo := XX1->XX1_STATUS == "0"
			
			If !lAtivo //Verifica se a rotina está sendo chamada pelo Job
				nPosIni := 0 //Posicao Job
				cJobIni := "" //Job
				If 	"LOJA900" $ XX1->XX1_ROTINA .or. "LOJA907" == Rtrim(XX1->XX1_ROTINA) 
				 	If (nPosIni := (aScan(aLj900G, { |r| r == RTrim(XX1->XX1_ROTINA)} ))) > 0 //loja900C
				 		cJobIni := STR0063 + " LOJA900G" //"Job"
				 	ElseIf (nPosIni := (aScan(aLj900GT, { |r| r == RTrim(XX1->XX1_ROTINA)} ))) > 0
				 		cJobIni := STR0064 + " LOJA900G" //"Tar"
				 	EndIf
				EndIf
				If 	"LOJA901" $ XX1->XX1_ROTINA
				 	If (nPosIni := (aScan(aLj901C, { |r| r == RTrim(XX1->XX1_ROTINA)} ))) > 0 //loja901c
				 		cJobIni := STR0063 +" LOJA901C" //"Job"
				 	ElseIf (nPosIni := (aScan(aLj901CT, { |r| r == RTrim(XX1->XX1_ROTINA)} ))) > 0 
				 		cJobIni := STR0064+" LOJA901C" //"Tar"
				 	EndIf				
				
				EndIf
			EndIf
			
			AADD(aTarefas,{cRotina,;
			IIF (lAtivo,STR0039,IIF(nPosIni = 0, STR0040, cJobIni)) ,; //"Ativo"###"Inativo"#cJob
			cData,;
			cResultado, cSeq }) //Retorna último result da comunicação Webservice
		endif
	Endif
	XX1->(dbSkip())
EndDo

RestArea(aArea)

Return aTarefas


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj906BRes
Busca array de LOG de comunicação e-commerce
@param   	_cRotina - Rotina
@param   	lUlt - Ultimo [default ..f.]
@param 		lIntAgrup - Integra Agrupadorees (default .F.)
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj906BRes(_cRotina,lUlt
/*/
//-------------------------------------------------------------------
Static Function Lj906BRes(_cRotina,lUlt, lIntAgrup)
Local aLOG := {} //Array de Log
Local cAlias := "MGMTMP" //Alias Temporário
Local aArea := GetArea() //WorkArea Ativa

Default lUlt := .F.
Default lIntAgrup := .F.

If SELECT(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

BeginSql Alias cAlias
	
	SELECT MGM.MGM_FILIAL,
	MGM.MGM_SERVIC,
	MGM.MGM_SEQ,
	MGM.MGM_DATA,
	MGM.MGM_HORAIN,
	MGM.MGM_HORAFI,
	MGM.MGM_RESULT,
	MGM.R_E_C_N_O_
	FROM %Table:MGM% MGM
	WHERE MGM.%NotDel%
	AND MGM.MGM_FILIAL = %Exp:xFilial("MGM")%
	AND MGM.MGM_SERVIC = %Exp:_cRotina%
	ORDER BY MGM_FILIAL, MGM_SERVIC, MGM_DATA DESC,  MGM_HORAIN DESC      
	
EndSql

While !(cAlias)->(Eof())
	
	
	AADD(aLOG,{(cAlias)->MGM_FILIAL,;
	(cAlias)->MGM_SERVIC,;
	(cAlias)->MGM_SEQ,;
	(cAlias)->MGM_DATA,;
	(cAlias)->MGM_HORAIN,;
	(cAlias)->MGM_HORAFI,;
	(cAlias)->MGM_RESULT,;
	"",;  //MGM->MGM_XMLENV,;
	"",;  //MGM->MGM_XMLRET,;
	(cAlias)->R_E_C_N_O_})
	
	If lUlt
		Return aLOG
	EndIf
	
	(cAlias)->(DbSkip())
EndDo

If SELECT(cAlias) > 0
	(cAlias)->(DbCloseArea())
EndIf

RestArea(aArea)

Return aLOG

//-------------------------------------------------------------------
/*/{Protheus.doc} Lj906BAli
Busca Alias da tabela de LOG de comunicação e-commerce
@param   	_cServico - Codigo do Servicço
@param	   lIntAgrup  - Integra Agrupadores (default .F.)
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj906BAli(_cServico)
/*/
//-------------------------------------------------------------------

Static Function Lj906BAli(_cServico, lIntAgrup)
Local _aAlias := {} //Array de Alias

Default lIntAgrup := .F.

Do Case
	Case ( _cServico == "LOJA900" )
		AADD(_aAlias,{_cServico,;
		"MGO",;
		IF( !lIntAgrup, STR0041, STR0076),; //"LOG Categorias"##"LOG Agrupadores"
		"MGO_FILIAL",;
		"MGO_SEQ"})
		
	Case ( _cServico == "LOJA900A" )
		AADD(_aAlias,{_cServico,;
		"MGN",;
		STR0042,; //"LOG Produtos"
		"MGN_FILIAL",;
		"MGN_SEQ"})

	Case ( _cServico == "LOJA900B" )
		AADD(_aAlias,{_cServico,;
		"MGP",;
		IF( !lIntAgrup, STR0043, STR0077),; //"LOG Produtos X Categorias"##"LOG Produtos X Agrupadores"
		"MGP_FILIAL",;
		"MGP_SEQ"})
		
	Case ( _cServico == "LOJA900C" )
		AADD(_aAlias,{_cServico,;
		"MGR",;
		STR0044,; //"LOG Estoque / Preço"
		"MGR_FILIAL",;
		"MGR_SEQ"})
		
	Case ( _cServico == "LOJA900D" )
		AADD(_aAlias,{_cServico,;
		"MGQ",;
		STR0045,; //"LOG Características"
		"MGQ_FILIAL",;
		"MGQ_SEQ"})
	
	Case ( _cServico == "LOJA901A" )
		AADD(_aAlias,{_cServico,;
		"MGU",;
		STR0046,; //"LOG Pedidos"
		"MGU_FILIAL",;
		"MGU_SEQ"})
		
	Case ( _cServico == "LOJA901" )
		AADD(_aAlias,{_cServico,;
		"MGS",;
		STR0047,; //"LOG Compradores"
		"MGS_FILIAL",;
		"MGS_SEQ"})
		
	Case ( _cServico == "LOJA900E" )
		AADD(_aAlias,{_cServico,;
		"MGT",;
		STR0056,; //"LOG Status de Pedidos"
		"MGT_FILIAL",;
		"MGT_SEQ"})
		
	Case ( _cServico == "LOJA900F" )
		AADD(_aAlias,{_cServico,;
		"MGY",;
		STR0057,; //"LOG Tabela Preço Variante"
		"MGY_FILIAL",;
		"MGY_SEQ"})

EndCase

Return _aAlias


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj906Exc
Executa a função de sincronização selecionada
@param   	oLbx - Label
@param   	aTarefas - Array de Tarefa
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj906Exc(oLbx,aTarefas)
/*/
Static Function Lj906Exc(oLbx,aTarefas)
Local aArea := GetArea()
                                  
MsgRun( STR0048, STR0049, {|| &(aTarefas[oLbx:nAt,1] + "(.F.)") } )  //"Sincronizando dados com a loja virtual..."###"Processando"

RestArea(aArea)
Return

//-------------------------------------------------------------------
/*/{Protheus.doc} LOJA900A
Monta o aHeader de Um Arquivo Temporario
@param   	cAliasTmp - Alias
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj906THdr(cAliasTmp)
/*/
//-------------------------------------------------------------------
Function Lj906THdr(cAliasTmp)

Local nA := 1 //Contador
Local aHeaderTmp :=  {} //Header Temporario
Local aEstruTmp := {} //Estrtura Temporaria
Local aArea := GetArea()
Local nPos := 0
Local nPos2 := 0
Local nPos3 := 0
Local cCampoG := ""
Local cIniBRW := ""
/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Busco a estrutura do Arquivo Temporario                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
dbSelectArea(cAliasTmp)

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Busca no SX3 o Nome do Campo e Configuracoes                                 ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
//dbSelectArea('SX3')
SX3->(dbSetOrder(1))
SX3->(dbSeek(cAliasTmp))

While SX3->(!EOF() .AND. RTrim(X3_ARQUIVO)  == RTrim(cAliasTmp))

	bBloco := {}
	cCampo := ""
	cIniBRW := ""
	
	If SX3->X3_Context == "V" .AND. !Empty(SX3->X3_INIBRW)
		nPos := At( cAliasTmp + "->" , SX3->X3_INIBRW)
		If nPos > 0
			
			cCampo := Substr(SX3->X3_INIBRW, nPos+5, 10)
			If (nPos := At(",", cCampo) > 0)
				cCampo := Left(cCampo, nPos-1)
			EndIf
			
			If (nPos := At(")", cCampo) > 0)
				cCampo := Left(cCampo, nPos-1)
			EndIf
			
			cCampo := Alltrim(cCampo)
			
			cCampoG := cAliasTmp + "->" + cCampo
			
			cIniBRW := StrTran(SX3->X3_INIBRW, cCampoG, "x")
			
			cIniBRW := &( "{ |x| " + cIniBRW + "}") 				
		EndIf
		
	EndIf
	
	aAdd( aHeaderTmp , {Trim(SX3->(X3Titulo())) , SX3->X3_Campo , SX3->X3_Picture, SX3->X3_Tamanho,;
								 SX3->X3_Decimal, SX3->X3_Valid, SX3->X3_Usado,SX3->X3_Tipo, ;
								 SX3->X3_Arquivo , SX3->X3_Context, cIniBRW, cCampo } )
	SX3->(DbSkip(1))
EndDo

RestArea(aArea)

Return aHeaderTmp


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj906TCols
Monta Coluna Temporaria 
@param   	cAliasTmp - Alias Temporario
@param   	aHeaderTmp - Header Temporario
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj906TCols(cAliasTmp,aHeaderTmp)
/*/
//-------------------------------------------------------------------
Function Lj906TCols(cAliasTmp,aHeaderTmp)


Local nA := 1 //Contador
Local aColsTmp := {} //Colunas Temporaria
Local aArea := GetArea()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Busco a estrutura do Arquivo Temporario                                      ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
dbSelectArea(cAliasTmp)
//Set os Campos da Query pelo dicionario de dados
//U_CamposSql(cAliasTmp)

aEstruTmp := dbStruct()

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³Carrego o aCols Lendo a Estrutura do Arquivo temporario                      ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
dbSelectArea(cAliasTmp)
dbGoTop()
Do While !Eof()
	
	nTam := Len(aHeaderTmp)
	AADD(aColsTmp,Array(nTam+1))
	For nA := 1 To nTam
	
		If aHeaderTmp[nA,10] <> "V"
			aColsTmp[Len(aColsTmp),nA]:= FieldGet(FieldPos(aHeaderTmp[nA, 2]))
		ElseIf !Empty(aHeaderTmp[nA, 11]) .and. !Empty(aHeaderTmp[nA, 12]) .and. ValType(aHeaderTmp[nA, 11]) == "B"
			cCampo := aHeaderTmp[nA, 12] 
			aColsTmp[Len(aColsTmp),nA]:= Eval( aHeaderTmp[nA, 11], FieldGet( FieldPos(cCampo)) )
		EndIf
	Next
	aColsTmp[Len(aColsTmp),nTam+1]:=.F.
	
	dbSelectArea(cAliasTmp)
	dbSkip()
	
	
Enddo

RestArea(aArea)

Return aColsTmp


//-------------------------------------------------------------------
/*/{Protheus.doc} Lj906TShow
Mostra o Browse de Um Arquivo temporaio SQL  
@param   	cAliasTmp  - Alias temporario   
@param   	cTituloTmp - Titulo Temporario   
@param   	aHeaderTmp - Header do Browse
@param   	aColsTmp - Colunas do Browse 
@param   	aBotoesTmp - Botoes da EnchoiceBar  
@param   	aAlter - Colunas que podem ser alteradas 
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj906TShow(cAliasTmp,cTituloTmp,aHeaderTmp,aColsTmp,aBotoesTmp,nLinIni,nColIni,nLinFim,nColFim,aAlter)
/*/
//-------------------------------------------------------------------
/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Lj906TShow   ³ Autor ³ Alessandro Arnold     ³ Data ³ 01/03/2008±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Mostra o Browse de Um Arquivo temporaio SQL                 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ Lj906TCols(Exp1,Exp2,Exp3,Exp4,ExpC5)                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Seq|Variavel  | Tipo    |Descricao                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³01 ³cAliasTmp ³C        ³Alias temporario                   ³±±
±±³          ³02 ³cTituloTmp³C        ³Titulo Temporario                  ³±±
±±³          ³03 ³aHeaderTmp³Array    ³Header do Browse                   ³±±
±±³          ³04 ³aColsTmp  ³Array    ³Colunas do Browse                  ³±±
±±³          ³05 ³aBotoesTmp³Array    ³Botoes da EnchoiceBar              ³±±
±±³          ³06 ³aAlter    ³Array    ³Colunas que podem ser alteradas    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³ aColsTrg                                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Generico                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function Lj906TShow(cAliasTmp,cTituloTmp,aHeaderTmp,aColsTmp,;
							aBotoesTmp,nLinIni,nColIni,nLinFim,;
							nColFim,aAlter)

Local aSize      := MsAdvSize() //Tamanho da Janela
Local aInfo      := {aSize[1],aSize[2],aSize[3],aSize[4],3,3} //Dados da Janela
Local aObjects   := {} //Objetos
Local aPosObj    := {} //Posição dos Objetos
Local nOpcx      := 1 //Opção
Local nOpca      := 0 //Opção 
Local aHeader    := aHeaderTmp //Header
Local aCols      := aColsTmp //Colunas

If ValType(aRotina) == Nil
	Private aRotina    := {{STR0002 	 	,"AXPESQUI"   	,0,1}} //"Pesquisar  " //"Pesquisar"
EndIf

If ValType(aAlter) == Nil
	aAlter  := {}
EndIf



AADD(aObjects,{100,020,.T.,.F.,.F.})
AADD(aObjects,{100,100,.T.,.T.,.F.})
aPosObj:=MsObjSize(aInfo,aObjects)


If nLinIni == Nil
	nLinIni := aSize[7]
	nColIni := 0
	nLinFim := aSize[6]
	nColFim := aSize[5]
EndIf

nLinBrwI := 50
nColBrwI := nColIni + 05
nLinBrwF := nLinFim/2.4
nColBrwF := nColFim/2

DEFINE MSDIALOG oDlgTmp TITLE cTituloTmp OF oMainWnd PIXEL FROM nLinIni,0 TO nLinFim,nColFim
oGet := MSGetDados():New(nLinBrwI,nColBrwI,nLinBrwF,nColBrwF,nOpcX,"AllwaysTrue","AllwaysTrue",'',.T.,aAlter,NIL,NIL,999)

ACTIVATE MSDIALOG oDlgTmp ON INIT EnchoiceBar(oDlgTmp,{||IIF(oGet:TudoOK(),(oDlgTmp:End(),nOpca:=1),nOpca := 0)},{||oDlgTmp:End()},,aBotoesTmp) CENTERED

Return(nOpca)


//------------------------------------------------------------------
/*/{Protheus.doc} Lj906Err
Função para visualizar o Envio/Retorno
@param   	cAServ - Codigo do Serviço
@param   	aASeq - Sequencia de Execução
@param   	nRetorno - Tipo do Retorno (1 Envio/2 Retorno)
@author  Varejo
@version 	P11.8
@since   	28/10/2014
@obs     
@sample Lj906Err(cAServ, aASeq) 
/*/
//------------------------------------------------------------------
Static function Lj906EnvRec(cAServ, aASeq, nRetorno)    

local cError     := "" //Codigo do Erro do parser
local cWarning   := "" //Codigo de Altera do parsert
local cTexto     := "" //Texto
local oDlgErr  	:=  NIL //Objeto Dialog
local oMemo	:= NIL //Objeto Memo
local oButton1    := NIL //Objeto Botão
Local oRetXML   := 0 //Objeto XML Parseado
Local nTamSev   := MGM->(TamSx3("MGM_SERVIC")[1])
Local aArea := GetArea()

Default nRetorno := 1

dbSelectArea("MGM")
MGM->(dbSetOrder(1))
if !MGM->(DBSeek(xFilial("MGM") + PadR(cAServ,nTamSev) + aASeq)) 
	return
endif   
      
If nRetorno == 1
	cTexto := MGM->MGM_XMLENV
	
Else

	cTexto := MGM->MGM_XMLRET
endif     

           
DEFINE MSDIALOG oDlgErr TITLE IIf(nRetorno == 1,STR0053, STR0054) FROM 0,0 TO 240,500 PIXEL   //"Detalhes XML Envio"#"Detalhes XML Retorno"

oMemo := tMultiget():New(10,10,{|u|if(Pcount()>0,cTexto:=u,cTexto)},oDlgErr,230,95,,,,,,.T.)

@ 108, 203 BUTTON oButton1 PROMPT STR0036 SIZE 037, 012 OF oDlgErr ACTION oDlgErr:End() PIXEL //"Voltar"

ACTIVATE MSDIALOG oDlgErr CENTER

RestArea(aArea)

return

//------------------------------------------------------------------
/*/{Protheus.doc} Lj906JAtb
Função para verificar se o Job esta ativo
@param   	cRotina - Codigo do Job
@author  Varejo
@version 	P11.8
@Return 	lAtivo - Job Ativo(.t./.f.)
@since   	13/07/2015
@obs     
@sample Lj906JAtb(cRotina) 
/*/
//------------------------------------------------------------------   
Static Function Lj906JAtb(cRotina)
Local lAtivo := .F. //job Ativo
Local cJobs := "" //jobs do Ini
Local aJobs := {} //jobs do ini
Local nC := 0		//Contador
Local cMain := "" //Rotina cadastrada no Job
Local cAmb := "" //ambiente do Job
Local cParm1 := "" //Empresa do Job
Local cParm2 := "" //Filial do Job
Local cAmbAtu := Upper(GetEnvServer()) //Ambiente Atual
Local cEmpAtu := cEmpAnt //Empresa Atual
Local cFilAtu := cFilAnt  //Filial Atual
Local aArea := GetArea()

Default cRotina := ""

If !FindFunction(cRotina)
	Return .F.	
EndIf


If !Empty(cRotina)

	cJobs := AllTrim(GetPvProfString("OnStart","Jobs","",GetAdv97()))	
	If !Empty(cJobs)
		aJobs := StrTokArr ( StrTran(cJobs, " ", ""), ",")
	EndIf
	
	Do While !lAtivo .AND. (nC := nC + 1) <= Len(aJobs)
		//Realiza a busca dos Parametros do Job
		If (cMain := Upper(AllTrim(GetPvProfString(aJobs[nC],"Main","",GetAdv97()))))  == cRotina
			If (cAmb := Upper(AllTrim(GetPvProfString(aJobs[nC],"Environment","",GetAdv97())))) == cAmbAtu 
				If Val(AllTrim(GetPvProfString(aJobs[nC],"nParms","",GetAdv97()))) >= 2
					cParm1 := Upper(AllTrim(GetPvProfString(aJobs[nC],"Parm1","",GetAdv97())))
					cParm2 := Upper(AllTrim(GetPvProfString(aJobs[nC],"Parm2","",GetAdv97())))
					
					lAtivo := cParm1 == cEmpAtu .AND. cParm2 == cFilAtu
				EndIf
			EndIf
		EndIf
	EndDo
EndIf

RestArea(aArea)

Return lAtivo


//------------------------------------------------------------------
/*/{Protheus.doc} Lj906Ini
Função para relizar a gravação dos Jobs e-commerce no arquivo de configuração do server
@author  Varejo
@version 	P11.8
@since   	13/07/2015
@obs     
@sample Lj906Ini
/*/
//------------------------------------------------------------------   
Static Function Lj906Ini()
Local cJobs 	:= "" //Jobs cadastrados no server
Local cParm1 	:= "" //Empresa cadastrada para o Job EC
Local cParm2 	:= "" //filial cadastrada para o Job EC
Local cAmb 	:= "" //Ambiente do Job EC
Local cMain	:= "" //Rotina principal do Job EC
Local lAltEnv := .F. //Arquivo de configuração alterado?
Local cChave 	:= ""	//Nome da chave do Job EC
Local cRefresh := ""//RefreshRate


If !FindFunction("LOJA900G") .or. !FindFunction("LOJA901C")
	Return .F.	
EndIf

cParm1 := Alltrim(cEmpAnt)
cParm2 := AllTrim(cFilAtn)
cAmb := GetEnvServer()
cJobs := AllTrim(GetPvProfString("OnStart","Jobs","",GetAdv97()))	
cRefresh := AllTrim(GetPvProfString("OnStart","RefreshRate","50",GetAdv97()))

cMain := "LOJA900G"
If  !Lj906jAtb(cMain)
	lAltEnv := .T.
	cChave := StrTran("Integracao_ECCiashop_Envio_"+cParm1+"_"+cParm2,space(1), "_")
	If Empty(cJobs)
		
		cJobs := cChave
	Else
		cJobs += "," + cChave
	EndIf

		WritePProString(cChave, "Main",			cMain,	GetAdv97())
		WritePProString(cChave, "Environment",	cAmb,	GetAdv97())
		WritePProString(cChave, "nParms",		"2",		GetAdv97())
		WritePProString(cChave, "Parm1",			cParm1,	GetAdv97())
		WritePProString(cChave, "Parm2",			cParm2,	Getadv97())

EndIf

cMain := "LOJA901C"
If  !Lj906jAtb(cMain)
	lAltEnv := .T.
	cChave := StrTran("Integracao_ECCiashop_Receb_"+cParm1+"_"+cParm2,space(1), "_")
	If Empty(cJobs)
		
		cJobs := cChave
	Else
		cJobs += "," + cChave
	EndIf

		WritePProString(cChave, "Main",			cMain,	GetAdv97())
		WritePProString(cChave, "Environment",	cAmb,	GetAdv97())
		WritePProString(cChave, "nParms",		"2",		GetAdv97())
		WritePProString(cChave, "Parm1",			cParm1,	GetAdv97())
		WritePProString(cChave, "Parm2",			cParm2,	Getadv97())

EndIf

If lAltEnv
	WritePProString("OnStart", "Jobs", cJobs, GetAdv97())
	WritePProString("OnStart","RefreshRate",cRefresh,GetAdv97())
	If MsgYesNo(STR0065) //"Desativar tarefas configuradas no Scheduler"
		Lj901DsT()
	EndIf
EndIf

Return lAltEnv


//------------------------------------------------------------------
/*/{Protheus.doc} Lj901DsT
Função para relizar a desativação das tarefas do EC
@author  Varejo
@version 	P11.8
@since   	13/07/2015
@obs     
@sample Lj906Ini
/*/
//------------------------------------------------------------------   
Static Function Lj901DsT()
Local aRotinas := Lj906RetRot()
Local _aTarefas := {} //Array de Tarefas
Local _nX :=0 //Contador 2
Local _nI := 0 //Contador 3
Local _cRotina := "" //Rotina
Local cAmb := Upper(Alltrim(GetEnvServer() ) ) //Ambiente
Local cEmpAmb := cEmpAnt //Grupo de empresas
Local cFilAmb := cFilAnt //Filial
Local aArea := GetArea()
Local lFuncXX1 := ExistFunc("FWOpenXX1")
Local lFuncXX2 := ExistFunc("FWOpenXX2")

//Retorna as rotinas do Scheduler
aRotinas := Lj906RetRot()

//Cadastro de Tarefas
If !lFuncXX1
	DbSelectArea("XX1")
Else
	FWOpenXX1()
EndIf

If !lFuncXX2
	FWOpenXX2()
EndIf
XX1->(dbSetOrder(1))
XX1->(dbGoTop())

While !XX1->(eof())
	
	For _nI := 1 To Len(aRotinas)	
		If RTrim(aRotinas[_nI]) == RTrim(XX1->XX1_ROTINA) .AND. AllTrim(Upper(XX1->XX1_ENV)) == cAmb
			If XX2->(DbSeek(XX1->XX1_CODIGO)) .AND. Alltrim(XX2->XX2_EMPFIL) == Alltrim(cEmpAmb + "/" + cFilAmb)

	
				If Alltrim(XX1->XX1_STATUS) == "0" //Tarefa Ativa?
					RecLock("XX1", .F.)
					XX1->XX1_STATUS := "1"
					XX1->(MsUnLock())
				EndIf
				
				Exit
			EndIf		
		EndIf
	Next
	XX1->(DbSkip())
EndDo

RestArea(aArea)

Return

//------------------------------------------------------------------
/*/{Protheus.doc} Lj906RetRot
Função para retornar as funções do e-commerce
@author  Varejo
@version 	P11.8
@Return 	aRotinas - Array de Rotinas
@since   	13/07/2015
@obs     
@sample Lj906RetRot
/*/
//------------------------------------------------------------------  
Static Function Lj906RetRot()
Local aRotinas := {} //Array de Rotinas

If FindFunction("LOJA900G") .AND. FindFunction("LOJA901C")
	aRotinas := {"LOJA900G", "LOJA901C", "LOJA900", "LOJA900A", "LOJA900B", "LOJA900C", "LOJA900D","LOJA900E","LOJA900F", "LOJA901", "LOJA901A", "LOJA907"} //Array de Rotinas
Else
	aRotinas := {"LOJA900", "LOJA900A", "LOJA900B", "LOJA900C", "LOJA900D","LOJA900E","LOJA900F", "LOJA901", "LOJA901A", "LOJA907"} //Array de Rotinas
EndIf
If FindFunction("LOJA900I")
	aAdd(aRotinas, "LOJA900I")
EndIf	

Return aRotinas


//------------------------------------------------------------------
/*/{Protheus.doc} Lj906TAtb
Função para verificar se a tarefa esta ativa
@param   	cRotina - Codigo do Job
@author  Varejo
@version 	P11.8
@Return 	lAtivo - tarefa Ativa(.t./.f.)
@since   	13/07/2015
@obs     
@sample Lj906TAtb(cRotina) 
/*/
//------------------------------------------------------------------   
Static Function Lj906TAtb(cRotina)
//Verifica se a rotina foi executada
Local lAtivo := .F. //Tarefa Ativa
Local cAmb := Upper(Alltrim(GetEnvServer() ) ) //Ambiente
Local cEmpAmb := cEmpAnt //Alltrim(FWGrpCompany()) //Empresa do Ambiente
Local cFilAmb := cFilAnt //AllTrim(FWCodFil()) //Filial do Ambiente
Local aArea := GetArea()
Local lFuncXX1 := ExistFunc("FWOpenXX1")


Default cRotina := ""

If !FindFunction(cRotina)
	Return .F.	
EndIf


If !Empty(cRotina)
	//Cadastro de Tarefas
	If lFuncXX1
		FWOpenXX1()
	EndIf
	XX1->(dbSetOrder(1))
	XX1->(dbGoTop())
	
	While !XX1->(eof())
			If RTrim(cRotina) == RTrim(XX1->XX1_ROTINA) .AND. AllTrim(Upper(XX1->XX1_ENV)) == cAmb
				If Lj906AgFil(XX1->XX1_CODIGO, cEmpAmb, cFilAmb)
			
					lAtivo  := Alltrim(XX1->XX1_STATUS) == "0" //Tarefa Ativa?			
					Exit
				EndIf		
			EndIf
	
		XX1->(DbSkip())
	EndDo
EndIf

RestArea(aArea)
Return lAtivo


//------------------------------------------------------------------
/*/{Protheus.doc} Lj606AtLog
Função para ativa/desativar o log do Loja
@author  Varejo
@version 	P11.8
@since   	29/07/2015
@obs     
@sample Lj606AtLog() 
/*/
//------------------------------------------------------------------   
Static Function Lj906AtLog(oButton)

Default oButton := NIL

If !LjIsLogEnable() .AND. MsgYesNo(STR0070) //"Deseja habilitar o arquivo de log do Loja"
	LjSetLogEn(.T.) //Sehabilita o Log
ElseIf LjIsLogEnable() .AND. MsgYesNo(STR0071)//"Deseja desabilitar o arquivo de log do Loja"
	LjSetLogEn(.F.) 
EndIf

Lj906BtnLb(@oButton)

Return



//------------------------------------------------------------------
/*/{Protheus.doc} Lj606AtLog
Função para ativa/desativar o log do Loja
@author  Varejo
@version 	P11.8
@since   	29/07/2015
@obs     
@sample Lj606AtLog() 
/*/
//------------------------------------------------------------------  
Static Function Lj906BtnLb(oButton)
Local cTexto := ""
Local cNewTexto := ""
Local lEnable := .F.

If Valtype(oButton) == "O"
	 cTexto := RTrim(oButton:cCaption)
	 lEnable := LjIsLogEnable()
	 If lEnable
	 	cNewTexto := STR0072 //"Inativar log"
	 Else
	 	cNewTexto := STR0073//"Ativar log"
	 EndIf
	 If cTexto <> cNewTexto
	 	oButton:cCaption := cNewTexto
	 	oButton:Refresh()
	 EndIf
EndIf

Return
//------------------------------------------------------------------
/*/{Protheus.doc} Lj906Track
Consulta tracker
@author  Varejo
@version 	P11.8
@since   	29/07/2015
@obs     
@sample Lj606AtLog() 
/*/
//------------------------------------------------------------------  
Static Function Lj906Track()

If ExistFunc("LJECTracker")
	LJECTracker()
EndIf

Return

//------------------------------------------------------------------
/*/{Protheus.doc} Lj906CrInt
Cria o código da integração de agrupadores, caso não exista
@param lIntAgrup - Informa se utiliza a integração de Agrupadores (default .F.)
@author  Varejo
@version 	P11.8
@since   	29/07/2015
@obs     
@sample Lj606AtLog() 
/*/
//------------------------------------------------------------------ 
Function Lj906CrI(lIntAgrup)
Local aAreaAIP := {} //WorkArea AIP
Local nLenSx8	 := 0 //Tamanho do campo SX8
Local lRet		 := .T. //Retorno
Local cCodIteg := GetMv( "MV_LJECMM4",, .F. ) //codigo da Integração

Default lIntAgrup := .F.

If lIntAgrup
	If Select( "AIP" ) > 0
		aAreaAIP := AIP->( GetArea() )	
	Else
		DbSelectArea( "AIP" ) //Cadastro de Integrações
	EndIf	
	AIP->( DbSetOrder( 1 ) ) //AIP_FILIAL+AIP_CODIGO   
	
	If  Empty(cCodIteg) .OR.  !AIP->(DbSeek(xFilial("AIP") + cCodIteg))
	
		nLenSx8 := GetSx8Len()
		
		If RecLock( "AIP", .T. )
			AIP->AIP_CODIGO := GetSx8Num( "AIP", "AIP_CODIGO" )                     
			AIP->AIP_DESC   := STR0078 //"E-Commerce CiaShop - Agrupadores"	
			
			AIP->( MsUnLock() )
			ConfirmSX8()
		Else 
			lRet := .F.
			While GetSx8Len() > nLenSX8
			   	RollBackSX8()
	       EndDo		
		EndIf
	 	
		PutMv( "MV_LJECMM4", AIP->AIP_CODIGO)
	EndIf

	If !Empty( aAreaAIP )
		RestArea( aAreaAIP )
	EndIf

EndIf

Return
//------------------------------------------------------------------
/*/{Protheus.doc} Lj906ConfPed
Confirma o pedido
@author  Varejo
@version 	P11.8
@since   	29/07/2015
@obs     
@sample Lj606AtLog() 
/*/
//------------------------------------------------------------------  

Static Function Lj906ConfPed()
Local aArea      := GetArea() //WorkArea Atual
Local oDlg       := Nil//Objeto da Dialog principal
Local oTree      := Nil//Objeto do Tree da tela principal
Local oPanel     := Nil //Objeto do panel
Local oScrollBox := Nil//componente TGrid 
Local oBtn1  	   := Nil //Botaão que confirma a geracao da consulta 
Local oBtn2  	   := Nil //Botao que cancela a geração da consulta
Local oPedEcom   := Nil //Objeto MSGET de Orcamento
Local cPedECom   := Space(TamSx3("C5_PEDECOM")[1]) //Pedido E-Commerce
Local lConfPed  := .F. //Confirma a geração do pedido

//Montando a tela de filtro
DEFINE MSDIALOG oDlg FROM 000, 000 TO 150, 400 PIXEL TITLE OemToAnsi(STR0081) //"Filtro para confirmação de Pedido na CiaShop"

oScrollBox := TScrollBox():new(oDlg, 007, 007, 095, 230, .T., .T., .T.)
oScrollBox:Align := CONTROL_ALIGN_ALLCLIENT			

@ 012, 003 SAY OemToAnsi(STR0082) SIZE 080, 010 OF oScrollBox PIXEL COLOR CLR_HBLUE //"Pedido eCommerce:"
@ 010, 065 MSGET oPedEcom VAR cPedECom SIZE 040, 005  WHEN .T. OF oScrollBox PIXEL

DEFINE SBUTTON oBtn1 FROM 50, 135 TYPE 1 ENABLE OF oDlg ACTION (lConfPed := .T., oDlg:End()) When !Empty( cPedECom)
DEFINE SBUTTON oBtn2 FROM 50, 165 TYPE 2 ENABLE OF oDlg ACTION  oDlg:End()      

ACTIVATE MSDIALOG oDlg CENTERED

If lConfPed
	Processa({|lEnd| LjConfProc(cPedECom)}, STR0083, STR0084  ) 	 //"Aguarde..."##"Confirmando Pedido na CiaShop"  	       		
EndIf

//Restaura a entrada da rotina                                    
RestArea(aArea)

Return Nil

//------------------------------------------------------------------
/*/{Protheus.doc} Lj906ConfPed
Confirma o pedido
@Param cPedEcom - Pedido e-commerce
@author  Varejo
@version 	P11.8
@since   	29/07/2015
@obs     
@sample LjConfProc(cPedEcom)
/*/
//------------------------------------------------------------------ 
Static Function LjConfProc(cPedEcom)
Local aMGUArea := MGU->(GetArea())
Local nTamPed := MGU->(TamSx3("MGU_PEDECO")[1])
Local lPedConf := .F. //Confirma o pedido
Local cFilMGU := xFilial("MGU")
Local cChave := cFilMGU+ PadL(AllTrim(cPedEcom),nTamPed) 
Local nRec := 0
Local oWs := NIL
Local cXML := ""
Local cSeq := "" //Sequencia

cPedEcom := AllTrim(cPedEcom) 
MGU->(DbSetOrder(2)) //MGU_FILIAL+MGU_PEDECO

If MGU->(DbSeek(cChave))
	Do While  !lPedConf .AND. MGU->(!Eof() .AND. MGU_FILIAL+MGU_PEDECO == cChave)
		lPedConf := MGU->MGU_CONFIR <> "0"
		nRec := MGU->(Recno())
		MGU->(DbSkip(1))
	EndDo
	If !lPedConf
		//Instancia o Objeto WS para confirmar
		oWS := Lj904WS( )

		cXML := '<?xml version="1.0" encoding="utf-8" standalone="no" ?>'
		cXML += '<receipt_resultList xmlns="dsReceipt.xsd">'
	
		cXML += '<receipt_result'
		
		//Reservado
		cXML += ' xmlns=""'
		
		//Código do cliente na loja virtual
		cXML += ' order_id="' + AllTrim(cPedEcom) + '"'
		
		//Processado OK
		cXML += ' processed="1"'
		
		cXML += '/>'
	
		cXML += '</receipt_resultList>'

		If oWs:ConfirmaPedidos(, , @cXML)
			MGU->(DbGoTo(nRec))
			cSeq := MGU->MGU_SEQ
			RecLock("MGU", .F.)
			MGU->MGU_CONFIR := "9"
			MGU->(MsUnLock())
			
			//Gera o log do Pedido confirmado
			RecLock("MGT", .T.)
			MGT->MGT_FILIAL  := xFilial("MGT")
			MGT->MGT_SEQ     := cSeq
			MGT->MGT_PEDIDO  := "_"+AllTrim(cPedEcom)
			MGT->MGT_STATUS  := "CF"
			MGT->MGT_RASTR   := __cUserID + " " + cUserName
			MGT->MGT_PEDECO := cPedEcom
			MGT->(MsUnLock()) 	
			
			MsgInfo(STR0085 + " [" + cPedEcom + "]")	//"Confirmação enviada para o e-commerce. Pedido e-commerce"	

		Else
			MsgStop(STR0086 + " [" + cPedEcom + "]")//"Falha ao enviar cancelamento pelo WebService. Pedido e-commerce"
					
		EndIf
		FreeObj(oWs)
	Else
		MsgStop(STR0087 +" [" + cPedEcom + "] " + STR0088) //"Pedido e-commerce"##"já confirmado no log de execuções. Para cancelar é necessário que não exista um log de integração do Pedido confirmado"
		
	EndIf
Else
	MsgStop(STR0087 + cPedEcom + STR0089)//"Pedido e-commerce ["##"] não localizado no log de execuções. Para cancelar é necessário que exista um log de integração do Pedido não confirmado"
EndIf


RestArea(aMGUArea)
Return

//------------------------------------------------------------------
/*/{Protheus.doc} Lj906AgFil
Verifica se o agendamento existe para a filial
@Param cCodAgend -Código do Agendamento
@Param cEmpAg - Empresa do Agendamento
@Param cFilAg - Filial do Agendamento
@Return lRet - Existe o agendamento
@author  Varejo
@version 	P11.8
@since   	29/07/2015
@obs     
@sample Lj906AgFil(cCodAgend, cEmpAg, cFilAg)
/*/
//------------------------------------------------------------------ 
Static Function Lj906AgFil(cCodAgend, cEmpAg, cFilAg)
Local lRet := .F. //Retorno
Local lFuncXX2 := ExistFunc("FWOpenXX2")

If lFuncXX2
	FWOpenXX2()
EndIf
XX2->(DbSetOrder(1)) //XX2_AGEND
If XX2->(DbSeek(cCodAgend))
	Do While !lRet .AND. XX2->(!Eof() .AND. XX2_AGEND = cCodAgend)
		lRet := AllTrim(XX2->XX2_EMPFIL) == AllTrim(cEmpAg + "/" + cFilAg)
		XX2->(DbSkip(1))
	EndDo
EndIf				

Return lRet
