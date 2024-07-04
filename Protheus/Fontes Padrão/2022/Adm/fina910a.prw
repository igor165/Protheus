#Include "PROTHEUS.CH"
#Include "FINA910A.ch"
#Include "FWMVCDEF.CH"

#DEFINE TOT_DATA		1
#DEFINE TOT_CONC		2
#DEFINE TOT_QTDCONC		3
#DEFINE TOT_CPAR		4
#DEFINE TOT_QTDCPAR		5
#DEFINE TOT_CMAN		6
#DEFINE TOT_QTDCMAN		7
#DEFINE TOT_CNAO		8
#DEFINE TOT_QTDCNAO		9
#DEFINE TOT_GERAL		10
#DEFINE _CRLF			Chr(13)+Chr(10)

#Define BMPCAMPO        "BMPCPO.PNG"
#Define BMPSAIR         "FINAL.PNG"
#Define BMPVISUAL       "BMPVISUAL.PNG"
#Define BMPLEGEND		"NG_ICO_LEGENDA.PNG"

Static nCodTimeOut		:= 90  

Static lPontoF			:= ExistBlock("FINA910F")		//Variavel que verifica se ponto de entrada esta' compilado no ambiente

Static __nThreads 
Static __nLoteThr 
Static __lProcDocTEF
Static __lDefTop		:= NIL
Static __lConoutR		:= FindFunction("CONOUTR")
Static __aBancos		:= {}
Static __cFilSA6		:= Nil
Static __lDocTef		:= FieldPos("FIF_NUCOMP") > 0

Static nTamBanco
Static nTamAgencia
Static nTamCC
Static nTamCheque
Static nTamNatureza

Static nTamParc
Static nTamParc2
Static nTamNSUTEF
Static nTamDOCTEF

Static lMEP
Static lTamParc
Static lA6MSBLQL

Static cAdmFinanIni		:= ""		//Codigo Inicial da Administradora Financeira que esta' efetuando o pagamento para a empresa
Static cAdmFinanFim		:= ""		//Codigo Final da Administradora Financeira que esta' efetuando o pagamento para a empresa
Static cConcilia		:= ""		//Tipos de Baixa: 1- Baixa individual / 2-Baixa por lote
Static nQtdDias			:= 0		//O numero de dias anteriores ao da data de crédito que sera' utilizada como referencia de pesquisa nos titulos
Static nMargem			:= 0		//Parametro utilizado para que titulos que estao com valores a menor no SITEF possam entrar na pasta de conciliados mediante tolerancia em percentual informada
Static dDataCredI		:= cTod("")	//Data de credito inicial que a administradora credita o valor para a empresa
Static dDataCredF		:= cTod("")	//Data de credito final que a administradora credita o valor para a empresa
Static lUseFIFDtCred	:= .F.
Static lFifRecSE1
Static lUsaMep        	:= SuperGetMv("MV_USAMEP",.T.,.F.)
Static _oFINA910A					//Objeto para receber comandos da classe FwTemporaryTable
Static aRetThread		:= {}
Static oConc			:= Nil											//Objeto da funcao TWBrowse usado no Folder Conciliar
Static __l910Auto	    := .F. 
Static __lOracle		:= .F. 
Static __lPostGre   	:= TcGetDb() == "POSTGRES"

//---------------------------------------------------------------------------
/*/{Protheus.doc} FINA910A
Rotina que efetua a conciliacao entre os dados recebidos pelo arquivo do 
SITFEF e os dados do Contas a Receber

@type Function
@author Rafael Rosa da Silva
@since 05/08/2009
@version 12   
/*/
//---------------------------------------------------------------------------
Function FINA910A(cAlias,cReg,nOpcAuto,lAuto)
Local aButtons			:= {}											//Variavel para a inclusao de botoes na EnchoiceBar
Local aHeadTot			:= {}											//Array que guarda os nomes dos campos que aparecerao no Folder Totais
Local aHeader    	 	:= {}											//Array que guarda os nomes dos campos que aparecerao nos Folders Conciliadas, Conc. Parcialmente e Não Conciliadas
Local aHeadIndic 		:= {}											//Array que guarda os nomes dos campos que aparecerao no Rodape Conciliados Parcialmente
Local aHeadMan			:= {}											//Array que guarda os nomes dos campos que aparecerao no Folder Conc. Manualmente
Local aHeadSE1			:= {}											//Array que guarda os campos padroes da tabela SE1
Local aColsAux			:= {}											//Array auxiliar que guarda os valores padroes
Local aConc				:= {}											//Array que contem todos os registros que estao disponiveis no Folder Conciliar
Local aConcPar			:= {}											//Array que contem todos os registros que estao disponiveis no Folder Conc. Parcialmente
Local aConcMan			:= {}											//Array que contem todos os registros que estao disponiveis no Folder Conc. Manualmente
Local aNaoConc			:= {}											//Array que contem todos os registros que estao disponiveis no Folder Nao Conciliadas
Local aTitulos			:= {}											//Array que contem todos os titulos que se assemelham aos registros do Folder Nao Conciliadas
Local aTotais			:= {}											//Array que contem todos os registros que estao disponiveis no Folder Totais
Local aFolder			:= {}											//Nome dos Folders
Local aIndic			:= {}											//Array que armazena os itens parecidos para Conciliacao Parcial
Local oSelec			:= LoadBitmap(GetResources(), "BR_VERDE"	)	//Objeto de tela para mostrar como marcado um registro
Local oNSelec			:= LoadBitmap(GetResources(), "BR_BRANCO"	)	//Objeto de tela para mostrar como desmarcado um registro
Local oRedSelec			:= LoadBitmap(GetResources(), "BR_VERMELHO"	)	//Objeto de tela para mostrar como desmarcado um registro
Local oAmaSelec			:= LoadBitmap(GetResources(), "BR_AMARELO"	)	//Objeto de tela para mostrar como Divergente um registro
Local oConcPar			:= Nil											//Objeto da funcao TWBrowse usado no Folder Conc. Parcialmente
Local oConcMan			:= Nil											//Objeto da funcao TWBrowse usado no Folder Conc. Manualmente
Local oNaoConc			:= Nil											//Objeto da funcao TWBrowse usado no Folder Nao Conciliadas (Registros a serem conciliados)
Local oTitulos			:= Nil											//Objeto da funcao TWBrowse usado no Folder Nao Conciliadas (Registros do Contas a Receber)
Local oIndic			:= Nil											//Objeto da funcao TWBrowse usado no Folder Nao Conciliados
Local oTotais			:= Nil											//Objeto da funcao TWBrowse usado no Folder Totais
Local o910Dlg				:= Nil											//Objeto da tela principal
Local oBaroDlg			:= Nil 											//Objeto do botões
Local oFolder			:= Nil											//Objeto que cria os Folders
Local lRet				:= .T.		 									//Variavel para tratamento dos retornos de funcoes
Local cPerg				:= "FINA910A"									//Grupo de Perguntas para filtro de informacoes para a Tela de Conciliacao do SITEF
Local aCampos			:= {}
Local bEncCan			:= {|| Iif( MsgNoYes( STR0224 ) ,o910Dlg:End() ,.F.) }
Local aChave			:= {}
Local lWhenConc			:= .T.	

Private lMsErroAuto		:= .F.											//Variavel logica de retorno do MsExecAuto
Private nRandThread 	:= 0

Default nOpcAuto := 0
Default lAuto := .F. 

__l910Auto 		:= lAuto
//Inicializa o log de processamento
ProcLogIni( aButtons )
    
//Apresenta a tela de parametros para o usuario para delimitar
//os dados que serao apresentados em tela
If __l910Auto 
	Pergunte(cPerg,.F.) 
ElseIf !Pergunte(cPerg,.T.) 
    Return
EndIf

//Verifica o compartilhamento das tabelas SE1 e MEP
If AliasInDic("MEP") .and. (xFilial("SE1") <> xFilial("MEP"))
	//"Compartilhamento incorreto entre as tabelas SE1 e MEP"
	Help(" ",1,"A910Compart",,STR0223 ,1,0,,,,,,{STR0114})
	//"Para utilizar o Conciliador SiTEF múltiplos cartões, faz-se necessário que as tabelas SE1 e MEP possuam mesma forma de compartilhamento."
    Return .F.
EndIf

//Atualiza o log de processamento
ProcLogAtu(STR0137)

A910aIniVar()

ProcLogAtu(STR0138,STR0139)
AADD(aCampos, {"SOURCE","C",10,0})
AADD(aCampos, { "RECNO","C",10,0})

AADD(aChave, "SOURCE")
AADD(aChave, "RECNO")

CreateTMP(aCampos,"TMP",aChave)

ProcLogAtu(STR0138,STR0140)

//Montagem do Header dos Folders Conciliadas, Conciliadas Parcialmente, Conciliadas Manualmente, Nao Conciliadas
aFolder		:= {STR0001,STR0002,STR0003,STR0004,STR0005}							 				//"Conciliadas"	### "Conc. Parcialmente"	### "Conc. Manualmente"	### "Nao Conciliadas"	### "Totais"
aHeadTot	:= {STR0006,STR0007,STR0008,STR0009,STR0010,STR0011,STR0012,STR0013,STR0014,STR0015}	//"  Data Credito"### "  Conciliados"			### "  Qtd.Conciliados"	### "  Conc. Parc."		### " Qtd.Conc.Parc."	### "  Conc.Man."	### " Qtd.Conc.Man."	### "  Nao Conc."	### " Qtd.Nao Conc." ###	"  Total Geral"
	
aHeader		:= { "", STR0016, STR0017, STR0018, STR0019, STR0020, STR0021, STR0022,;				//"Cod Estab"		### "Nome do Estab"	### "Adminis"		### "Prefixo"		### "Titulo"			### "Tipo"			### "Nro Parc"
				STR0023, STR0024, STR0025, STR0026, STR0027, STR0028, STR0029, STR0080,;			//"Nro Comp"		### "DT Emissao"	### "DT Credito"	### "Valor"			### "Valor Sitef"		### "NSU"			### "Parc Sitef"	### "DocTef E1"
				STR0081, STR0082, STR0079, STR0083, STR0084, STR0085, STR0086}						//"NSU E1"			### "Dt Crédito E1"	### "Bco/Ag/Conta"	### "Status Conta"	### "Origem Trans"		### "RECNO SE1"		### "RECNO FIF"

aHeadIndic	:= { STR0030,STR0031,STR0032,STR0033,STR0034,STR0035,STR0036,STR0029,;					//"Vl Protheus" 	### "Vl Sitef"		### "NSU Protheus"	### "NSU Sitef"		### "Emissão Protheus"	### "Emissão Sitef"	### "Parc Protheus"	### "Parc Sitef"
				STR0019,STR0020,STR0021}															//"Prefixo"		### "Titulo"		### "Tipo"
	
aHeadSE1	:= { "" , STR0024, STR0037, STR0030, STR0032, STR0038, STR0019, STR0020,;				//"DT Emissao"	### "Vcto Protheus"	### "Vl Protheus"	### "NSU Protheus"	### "Comp Protheus"		### "Prefixo"		### "Titulo"
				STR0036, STR0021, STR0018, STR0029, STR0039, STR0087, STR0088}						//"Parc Protheus"	### "Tipo"				### "Adminis"		### "Parc Sitef"    ### "Loja"			   ### "Filial"			### "RECNO"

aHeadMan   := aClone(aHeader)
	
aColsAux   := {{	"",;				//1-Status oNSelec
					"", ;				//2-Codigo do Estabelecimento Sitef
					"", ;				//3-Codigo da Loja Sitef
					"", ;				//4-Codigo do Cliente (Administradora)
					"", ;				//5-Prefixo do titulo Protheus
					"", ;				//6-Numero do titulo Protheus
					"", ;				//7-Tipo do titulo Protheus
					"", ;				//8-Numero da parcela Protheus
					"", ;				//9-Numero do Comprovante Sitef
					cTod("  /  /  "),;//10-Data da Venda Sitef
					cTod("  /  /  "),;//11-Data de Credito Sitef
					0,  ;				//12-Valor do titulo Protheus
					0,  ;				//13-Valor liquido Sitef
					"", ;				//14-Numero NSU Sitef
					"", ;				//15-Numero da parcela Sitef
					"", ;				//16-Documento TEF Protheus
					"", ;				//17-NSU Sitef Protheus
					cTod("  /  /  "),;//18-Vencimento real do titulo
					"", ;				//19-banco/agencia/conta
					"", ;				//20-Informação de conta não cadastrada ou cadastrada
					"", ;				//21 - (0,2 ou 3 - Transação Sitef),(1 ou 4 - Outros/POS)
					0,  ;				//22 - RECNO do SE1
					0,  ;				//23 - RECNO do FIF
					"", ;				//24 - Agencia
					"", ;				//25 - Conta
					"", ;				//26 - Banco
					"" }}				//27 - Codigo da Loja

dDataCredI		:= MV_PAR03
dDataCredF		:= If(Empty(MV_PAR04), MV_PAR03, MV_PAR04)
cConcilia		:= MV_PAR07
nQtdDias		:= MV_PAR09
cAdmFinanIni	:= MV_PAR11
cAdmFinanFim	:= MV_PAR12
lUseFIFDtCred	:= ( MV_PAR13 == 2 ) // "Credito SITEF"
		
If Empty(MV_PAR10)
	//Não foi inserido percentual de tolerância para valor de TEF menor que o valor do título
	Help(" ",1,"A910Margem",,STR0076 ,1,0,,,,,,/*{STR0094}*/)
	nMargem := 0
Else
	nMargem = MV_PAR10
EndIf
	
//Atualiza os dados de itens de acordo com os filtros
//mostrados inicialmente, onde caso nao exista dados,
//o retorno será Falso e sai da rotina                   
ProcLogAtu("MENSAGEM","INI -> Filtrando os Registros")
If __l910Auto 
	lRet := A910AtuDados( @aConc, @aConcPar, @aNaoConc, @aConcMan,@aIndic, oNSelec, oRedSelec)
Else 
	LjMsgRun(	STR0041,,{||lRet := A910AtuDados( @aConc, @aConcPar, @aNaoConc, @aConcMan,@aIndic, oNSelec, oRedSelec)}) //"Filtrando os Registros..."
EndIf
If !lRet
	Return()
EndIf

//Atualiza o array totalizador
If __l910Auto 
	A910Total( aConc, aConcPar, aNaoConc, aConcMan, @aTotais, aHeader, aHeadMan)
Else 
	LjMsgRun(STR0042,,{|| A910Total( aConc, aConcPar, aNaoConc, aConcMan, @aTotais, aHeader, aHeadMan)}) //"Gerando os totalizadores..."
EndIf

ProcLogAtu(STR0138,STR0141)

//Verifica se existem informacoes para cada um dos arrays
If Len(aConc) == 0
	aColsAux[1][1] := oSelec	 // BR_VERDE
	aConc := aClone(aColsAux)
EndIf
	
If Len(aConcPar) == 0
	aColsAux[1][1] := oSelec	 // BR_VERDE
	aConcPar := aClone(aColsAux)
EndIf
	
If Len(aConcMan) == 0
	aColsAux[1][1] := oNSelec	 // BR_BRANCO
	aConcMan := aClone(aColsAux)
EndIf
	
If Len(aNaoConc) == 0
	aColsAux[1][1] := oNSelec	 // BR_BRANCO
	aNaoConc := aClone(aColsAux)
EndIf

If !__l910Auto 

	DEFINE MSDIALOG o910Dlg TITLE STR0043 FROM FA910ARES(170),FA910ARES(220) TO FA910ARES(665),FA910ARES(977) PIXEL //"Conciliador SITEF"
		
	//Adiciona as barras dos botões
	DEFINE BUTTONBAR oBaroDlg SIZE 10,10 3D TOP OF o910Dlg

	oButtTree   := TBtnBmp():NewBar( BMPSAIR,BMPSAIR,,,,bEncCan,.T.,oBaroDlg,,,STR0142 )
	oButtTree:cTitle := STR0142  
	oButtTree:Align := CONTROL_ALIGN_RIGHT 

	oButtTree   := TBtnBmp():NewBar( BMPVISUAL, BMPVISUAL,,,,{|| ProcLogView()  },.T.,oBaroDlg,,,STR0143 )
	oButtTree:cTitle := STR0143
	oButtTree:Align := CONTROL_ALIGN_RIGHT 

	oButtTree   := TBtnBmp():NewBar( BMPLEGEND, BMPLEGEND,,,,{|| FA910ALEG()  },.T.,oBaroDlg,,,"Legenda" )
	oButtTree:cTitle := "Legenda"
	oButtTree:Align := CONTROL_ALIGN_RIGHT 
Else
	o910Dlg := MSDialog():New(180,180,550,700,'Automato',,,,,CLR_BLACK,CLR_WHITE,,,.T.)
EndIf

// Cria as Folders do Sistema
oFolder	:= TFolder():New( FA910ARES(012), FA910ARES(002), aFolder,{},o910Dlg,,,,.T.,.F., FA910ARES(386), FA910ARES(230), )
oFolder:Align := CONTROL_ALIGN_ALLCLIENT 
	
//Tratamento do Folder -> Totais
oTotais := TWBrowse():New( FA910ARES(000),FA910ARES(000),FA910ARES(380),FA910ARES(200),,aHeadTot,,oFolder:aDialogs[5],,,,,,,,,,,,,,,,,,, )
oTotais:SetArray(aTotais)
oTotais:bLine := {||aEval( aTotais[oTotais:nAt],{|z,w|aTotais[oTotais:nAt,w]})}
oTotais:bHeaderClick := {|x,y,z|A910SelReg(@aTotais,@oTotais,oSelec,oNSelec,y,,.F.)}

If !__l910Auto		
	@ C(205),C(300) Button STR0192 Size C(073),C(012) Action Processa({||Fina910D(aConc, aTotais, aHeader, aHeadTot, 3)},STR0047) PIXEL OF oFolder:aDialogs[5] 
EndIf
	//Tratamento do Folder -> Conciliadas
oConc := TWBrowse():New( FA910ARES(000), FA910ARES(000), FA910ARES(380), FA910ARES(200),,aHeader,,oFolder:aDialogs[1],,,,,,,,,,,,,,,,,,, )
oConc:SetArray(aConc)
oConc:bLine :=	{||{	aConc[oConc:nAt,01],aConc[oConc:nAt,02],;
							aConc[oConc:nAt,03],aConc[oConc:nAt,04],aConc[oConc:nAt,05],aConc[oConc:nAt,06],aConc[oConc:nAt,07],;
							aConc[oConc:nAt,08],aConc[oConc:nAt,09],aConc[oConc:nAt,10],aConc[oConc:nAt,11],;
							aConc[oConc:nAt,12],aConc[oConc:nAt,13],aConc[oConc:nAt,14],aConc[oConc:nAt,15],;
							aConc[oConc:nAt,16],aConc[oConc:nAt,17],aConc[oConc:nAt,18],aConc[oConc:nAt,19],;
							aConc[oConc:nAt,20],Iif(aConc[oConc:nAt,21] == '1' .OR. aConc[oConc:nAt,21] == '4',STR0089,STR0090),;	//"OUTROS"	### "SITEF"
							aConc[oConc:nAt,22],aConc[oConc:nAt,23]}}
							
oConc:bHeaderClick := {|x,y,z|A910SelReg(@aConc,@oConc,oSelec,oNSelec,y)}
	
//Verifica se existem informacoes Conciliadas
If aConc[1][2] <> ""
	oConc:bLDblClick := {||A910SelReg(@aConc,@oConc,oSelec,oNSelec,1,oConc:nAt)}
EndIf

If !__l910Auto		
	@ FA910ARES(205),FA910ARES(002) Button STR0044 Size FA910ARES(073),FA910ARES(012) Action A910Efetiva(@aConc, @oConc, oRedSelec, oAmaSelec,,,, @aTotais, @oTotais, 1,,o910Dlg) PIXEL OF oFolder:aDialogs[1]		//"&Efetiva Conciliação"

	@ C(205),C(300) Button STR0193 Size C(073),C(012) Action Processa({||Fina910DX(aConc, aIndic, aHeader, aHeadIndic, 1)},STR0047) PIXEL OF oFolder:aDialogs[1] 
EndIf

//Tratamento do Folder -> Conciliadas Parcialmente
oConcPar := TWBrowse():New( FA910ARES(000), FA910ARES(000), FA910ARES(380), FA910ARES(140),,aHeader,,oFolder:aDialogs[2],,,,,,,,,,,,,,,,,,, )
oConcPar:SetArray(aConcPar)
oConcPar:bLine :=	{||{	aConcPar[oConcPar:nAt,01],aConcPar[oConcPar:nAt,02],;
							aConcPar[oConcPar:nAt,03],aConcPar[oConcPar:nAt,04], aConcPar[oConcPar:nAt,05],aConcPar[oConcPar:nAt,06],aConcPar[oConcPar:nAt,07],;
							aConcPar[oConcPar:nAt,08],aConcPar[oConcPar:nAt,09],aConcPar[oConcPar:nAt,10],aConcPar[oConcPar:nAt,11],;
							aConcPar[oConcPar:nAt,12],aConcPar[oConcPar:nAt,13],aConcPar[oConcPar:nAt,14],aConcPar[oConcPar:nAt,15],;
							aConcPar[oConcPar:nAt,16],aConcPar[oConcPar:nAt,17],aConcPar[oConcPar:nAt,18],aConcPar[oConcPar:nAt,19],;
							aConcPar[oConcPar:nAt,20],Iif(aConcPar[oConcPar:nAt,21] == '1' .OR. aConcPar[oConcPar:nAt,21] == '4',STR0089,STR0090),;	//"OUTROS"	### "SITEF"
							aConcPar[oConcPar:nAt,22],aConcPar[oConcPar:nAt,23]}}

oConcPar:bHeaderClick := {|x,y,z|A910SelReg(@aConcPar,@oConcPar,oSelec,oNSelec,y)}
	
//Verifica se existem informacoes Conciliadas Parcialmente
If aConcPar[1][2] <> ""
	oConcPar:bLDblClick := {||A910SelReg(@aConcPar,@oConcPar,oSelec,oNSelec,1,oConcPar:nAt)}
EndIf
oConcPar:bChange := {||A910AtuDiv(aConcPar,@aIndic,oConcPar:nAt,oIndic)}

If !__l910Auto		
	@ C(145),C(300) Button STR0048 Size C(073),C(012) Action Processa({||Fina910DX(aConcPar, aIndic, aHeader, aHeadIndic, 1)},STR0047) PIXEL OF oFolder:aDialogs[2] 	//"&Nao Conc Excel"###"Processando ..."
EndIf

//Tratamento Divergencias
oIndic := TWBrowse():New(FA910ARES(012),FA910ARES(000),FA910ARES(380),FA910ARES(040),,aHeadIndic,,oFolder:aDialogs[2],,,,,,,,,,,,,,,,,,,)
oIndic:SetArray(aIndic)
oIndic:bLine := {||aEval(aIndic[oIndic:nAt],{|z,w| aIndic[oIndic:nAt,w]})}

If !__l910Auto		
	@ C(205),C(002) Button STR0044 Size C(073),C(012) Action A910Efetiva(@aConcPar, @oConcPar,oRedSelec, oAmaSelec,,,, @aTotais, @oTotais, 2,,o910Dlg) PIXEL OF oFolder:aDialogs[2]		//"&Efetiva Conciliação"

	@ C(205),C(300) Button STR0136 Size C(073),C(012) Action Processa({||Fina910DX(aConcPar, aIndic, aHeader, aHeadIndic, 2)},STR0047) PIXEL OF oFolder:aDialogs[2] 	//"&Nao Conc Excel"###"Processando ..."
EndIf		

//Tratamento do Folder -> Nao Conciliadas
oNaoConc := TWBrowse():New(FA910ARES(000),FA910ARES(000),FA910ARES(380),FA910ARES(090),,aHeader,,oFolder:aDialogs[4],,,,,,,,,,,,,,,,,,,)

oNaoConc:SetArray(aNaoConc)
oNaoConc:bLine :=	{||{	aNaoConc[oNaoConc:nAt,01],aNaoConc[oNaoConc:nAt,02],;
							aNaoConc[oNaoConc:nAt,03],aNaoConc[oNaoConc:nAt,04], aNaoConc[oNaoConc:nAt,05],aNaoConc[oNaoConc:nAt,06],aNaoConc[oNaoConc:nAt,07],;
							aNaoConc[oNaoConc:nAt,08],aNaoConc[oNaoConc:nAt,09],aNaoConc[oNaoConc:nAt,10],aNaoConc[oNaoConc:nAt,11],;
							aNaoConc[oNaoConc:nAt,12],aNaoConc[oNaoConc:nAt,13],aNaoConc[oNaoConc:nAt,14],aNaoConc[oNaoConc:nAt,15],;
							aNaoConc[oNaoConc:nAt,16],aNaoConc[oNaoConc:nAt,17],aNaoConc[oNaoConc:nAt,18],aNaoConc[oNaoConc:nAt,19],;
							aNaoConc[oNaoConc:nAt,20],Iif(aNaoConc[oNaoConc:nAt,21] == '1' .OR. aNaoConc[oNaoConc:nAt,21] == '4',STR0089,STR0090),;	//"OUTROS"	### "SITEF"
							aNaoConc[oNaoConc:nAt,22],aNaoConc[oNaoConc:nAt,23]}}
						
oNaoConc:bHeaderClick := {|x,y,z|A910SelReg(@aNaoConc,@oNaoConc,oSelec,oNSelec,y,,.F.)}

//"Selecionar item correspondente no Rodape'"
oNaoConc:bLDblClick	  := {||MsgInfo(STR0045)}
	
//tratamento Rodape Nao Conciliadas
oTitulos := TWBrowse():New(FA910ARES(008),FA910ARES(000),FA910ARES(380),FA910ARES(090),,aHeadSE1,,oFolder:aDialogs[4],,,,,,,,,,,,,,,,,,,)

If !__l910Auto
	LjMsgRun(STR0091,,{||A910Titulos( aNaoConc, oNaoConc:nAt, oSelec, @aTitulos, oTitulos, oNSelec, aConc, aConcPar, @lWhenConc )})			//"Carregando os Títulos..."
			
		//Verifica se existem informacoes Nao Conciliadas
	If Len(aTitulos) > 0
		oTitulos:bLDblClick	:= {||A910SelReg(@aTitulos,@oTitulos,oSelec,oNSelec,1,oTitulos:nAt,.T.,@aNaoConc,oNaoConc:nAt,oNaoConc)}
	EndIf
		
	@ C(095),C(300) Button STR0046 Size C(073),C(012) Action Processa({||Fina910D(aNaoConc, aTitulos, aHeader, aHeadSE1, 1)},STR0047) PIXEL OF oFolder:aDialogs[4] 	//"&Nao Conc Excel"###"Processando ..."
		
	@ C(205),C(002) Button STR0044 Size C(073),C(012) Action A910Efetiva(	@aNaoConc,	@oNaoConc,	oRedSelec,	oAmaSelec,;												//"&Efetiva Conciliação"
																					aTitulos,	@aConcMan,	oConcMan,	@aTotais,;
																					@oTotais, 	3,			@oTitulos,	o910Dlg) PIXEL OF oFolder:aDialogs[4] WHEN lWhenConc
		
	@ C(205),C(300) Button STR0048 Size C(073),C(012) Action Processa({||Fina910D(aNaoConc, aTitulos, aHeader, aHeadSE1, 2)},STR0047) PIXEL OF oFolder:aDialogs[4] 	//"&Titulos Excel"###"Processando ..."
Else
	A910Titulos( aNaoConc, oNaoConc:nAt, oSelec, @aTitulos, oTitulos, oNSelec, aConc, aConcPar, @lWhenConc )
EndIf		

//Tratamento do Folder -> Conciliadas Manualmente
oConcMan := TWBrowse():New(FA910ARES(000),FA910ARES(000),FA910ARES(380),FA910ARES(200),,aHeader,,oFolder:aDialogs[3],,,,,,,,,,,,,,,,,,,)
oConcMan:SetArray(aConcMan)
oConcMan:bLine     := {|| A910Browse(aConcMan[oConcMan:nAt])}

If !__l910Auto
	@ C(205),C(300) Button STR0194 Size C(073),C(012) Action Processa({||Fina910DX(aConcMan, aIndic, aHeader, aHeadIndic, 1)},STR0047) PIXEL OF oFolder:aDialogs[3] 
		
	oConc:Refresh()
	oConcPar:Refresh()
	oNaoConc:Refresh()
	oTitulos:Refresh()
	
	ACTIVATE MSDIALOG o910Dlg CENTERED //ON INIT Eval( bInitDlg )
Else

	//Conciliados 
	If Len(aConc) > 0 
		A910Efetiva(@aConc, @oConc, oRedSelec, oAmaSelec,,,, @aTotais, @oTotais, 1,,o910Dlg)
	EndIf
	//Conciliados parcialmente 
	If Len(aConcPar) > 0
		A910Efetiva(@aConcPar, @oConcPar,oRedSelec, oAmaSelec,,,, @aTotais, @oTotais, 2,,o910Dlg)
	EndIf 

EndIf                            

A910CLOSEAREA("TMP")

dbSelectArea("SE1")
SE1->(MSRUNLOCK())

aConc		:= aSize(aConc,0)
aConcPar	:= aSize(aConcPar,0)
aNaoConc	:= aSize(aNaoConc,0)
aConcMan	:= aSize(aConcMan,0)
aIndic		:= aSize(aIndic,0)
	
aConc		:= {}
aConcPar	:= {}
aNaoConc	:= {}
aConcMan	:= {}
aIndic		:= {}
	
//Atualiza o log de processamento
ProcLogAtu("FIM")

Return(.T.)

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910AtuDados
Rotina que retorna os dados de conciliacao de acordo com o vinculo com o 
contas a receber                            

@type Function
@author Rafael Rosa da Silva
@since 05/08/2009
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A910AtuDados( aConc, aConcPar, aNaoConc, aConcMan, aIndic, oNSelec, oRedSelec ) 

Local cQry			:= ""						//Instrucao de query no banco
Local cAliasSitef	:= GetNextAlias()         	//Variavel que recebe o proximo Alias disponivel
Local cSubstring	:= ""						//Variavel para tratar a comando "SUBSTRING" no banco de dados
Local cValConta		:= ""						//Informacao de conta nao cadastrada ou cadastrada
Local cFilSitef		:= ""						//Filial informada no Sitef
Local aColsAux		:= {}						//Array auxiliar para carregar arrays de trabalho
Local aArea			:= GetArea()				//Array que armazena a ultima area utilizada
	
Local lRet			:= .T.						//Retorno da funcao
Local lExclusivo	:= !Empty(xFilial("SE1"))	//Verifica se SE1 esta' compartilhada ou exclusiva
Local lExclusFIF	:= !Empty(xFilial("FIF"))	//Verifica se FIF esta' compartilhada ou exclusiva
Local lExclusMEP	:= !Empty(xFilial("MEP"))
Local aDados		:= {}
Local cMSFIL		:= ""
Local cCodBco		:= ""
Local cCodAge		:= ""
Local cNumCC		:= ""
Local lUsaMep		:= SuperGetMv("MV_USAMEP",.T.,.F.)
Local lLJGERTX		:= SuperGetMv( "MV_LJGERTX" , .T. , .F. )
Local lMsgTef		:= .T.	
Local cDocSE1      	:= ""
Local cNsuSe1 		:= "" 
Local cNsuFIF  		:= "" 
Local cDocFIF  		:= "" 
Local cNsuDe 		:= ""
Local cNSUAte 		:= ""

//Zero as variaveis antes de atualizar
aConc		:= {}
aConcPar	:= {}
aNaoConc	:= {}
aConcMan	:= {}
aIndic		:= {}
	       
If ( AllTrim( Upper( TcGetDb() ) ) $ "ORACLE_INFORMIX" )
	cSubstring := "SUBSTR"
	__lOracle  := .T.
ElseIf ( AllTrim( Upper( TcGetDb() ) ) $ "DB2|DB2/400")
	cSubstring := "SUBSTR"
Else
	cSubstring := "SUBSTRING"
EndIf

If __lDefTop == Nil
	__lDefTop := FindFunction("IFDEFTOPCTB") .And. IfDefTopCTB() 
EndIf

If !__lProcDocTEF
	cNsuDe  := PADR("", nTamNSUTEF - len(Alltrim(MV_PAR05)),Iif(!Empty(MV_PAR05),'0',' ')) + Alltrim(MV_PAR05)
	cNSUAte := PADR("", nTamNSUTEF - len(Alltrim(MV_PAR06)),Iif(!Empty(MV_PAR06),'0','Z')) + Alltrim(MV_PAR06)
ElseIf __lDocTef
	cNsuDe  := PADR("", nTamDOCTEF - len(Alltrim(MV_PAR05)),Iif(!Empty(MV_PAR05),'0',' ')) + Alltrim(MV_PAR05)
	cNSUAte := PADR("", nTamDOCTEF - len(Alltrim(MV_PAR06)),Iif(!Empty(MV_PAR06),'0','Z')) + Alltrim(MV_PAR06)
Endif

If __lDefTop
    If !lMEP .or. !lUsaMep   //Não Existe a tabela MEP ou não usa.
        cQry := "SELECT FIF.FIF_CODEST, FIF.FIF_CODLOJ, SE1.E1_CLIENTE, FIF.FIF_NUCOMP, FIF.FIF_DTTEF, SE1.E1_VALOR,SE1.E1_SALDO, "
        cQry += "FIF.FIF_VLLIQ, FIF.FIF_NSUTEF, SE1.E1_PARCELA, FIF.FIF_PARCEL, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_TIPO, SE1.E1_MSFIL,SE1.E1_FILORIG, "
        cQry += "FIF.FIF_DTCRED, SE1.E1_DOCTEF, SE1.E1_NSUTEF, SE1.E1_VENCREA, SE1.E1_EMISSAO,FIF.FIF_STATUS, FIF.FIF_PREFIX, FIF.FIF_NUM, "
		cQry += "FIF.FIF_CODRED ,FIF.FIF_PARC, FIF.FIF_TIPO, FIF.R_E_C_N_O_ RECNO_FIF,FIF_PARALF, FIF.FIF_CODBCO, FIF.FIF_CODAGE, FIF.FIF_NUMCC, FIF.FIF_CAPTUR, SE1.R_E_C_N_O_ RECNO_SE1, SE1.E1_LOJA, FIF.FIF_VLBRUT, FIF.FIF_CODFIL "
	
        cQry += ", '"+ Space(nTamParc) +"' AS MEP_PARTEF "
        cQry += "FROM " + AllTrim(RetSqlName("FIF")) + " FIF "
        cQry += "INNER JOIN " + RetSqlName("SE1") + " SE1 "
        cQry += "ON ( SE1.E1_PARCELA = FIF.FIF_PARCEL OR SE1.E1_PARCELA = FIF.FIF_PARALF ) "
		
        cQry += "AND FIF.FIF_DTTEF = SE1.E1_EMISSAO "

        If !__lProcDocTEF
			If __lOracle .or. __lPostGre
				cQry += " AND LPAD(TRIM(SE1.E1_NSUTEF), "+Alltrim(STR(nTamNSUTEF))+" , '0') = LPAD(TRIM(FIF.FIF_NSUTEF), "+Alltrim(STR(nTamNSUTEF))+", '0') "
			Else
				cQry += " AND REPLICATE('0', "+Alltrim(STR(nTamNSUTEF))+" - LEN(SE1.E1_NSUTEF)) + RTrim(SE1.E1_NSUTEF) = REPLICATE('0', "+Alltrim(STR(nTamNSUTEF))+" - LEN(FIF.FIF_NSUTEF)) + RTrim(FIF.FIF_NSUTEF) "
			Endif
        Else
			If __lOracle .or. __lPostGre
				cQry += " AND CAST(SE1.E1_DOCTEF AS NUMBER) = CAST(FIF.FIF_NUCOMP AS NUMBER) "
			Else
				cQry += " AND CAST(SE1.E1_DOCTEF AS BIGINT) = CAST(FIF.FIF_NUCOMP AS BIGINT) "
			EndIf
        Endif

        cQry += "AND SE1.E1_SALDO > 0 "

        If MV_PAR08 == 1
            cQry += "AND SE1.E1_TIPO = 'CD' "
        ElseIf	MV_PAR08 == 2
            cQry += "AND SE1.E1_TIPO = 'CC' "
        Else
            cQry += "AND SE1.E1_TIPO IN ('CD','CC') "
        EndIf
			
        cQry += "AND SE1.E1_MSFIL = FIF.FIF_CODFIL "
			
        If lExclusivo
            cQry += "AND SE1.E1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
        Else
            cQry += "AND SE1.E1_MSFIL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
		EndIf
			
        cQry += "AND SE1.D_E_L_E_T_ = ' ' "
        cQry += "WHERE FIF.FIF_CODFIL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
		cQry += "AND FIF.FIF_DTCRED BETWEEN '" + dTos(dDataCredI) + "' AND '" + dTos(dDataCredF) + "'"
	
        If !__lProcDocTEF
			If __lOracle .or. __lPostGre
				cQry += "AND LPAD(TRIM(FIF.FIF_NSUTEF), "+Alltrim(STR(nTamNSUTEF))+", '0') BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' "
			Else
            	cQry += "AND REPLICATE('0', "+Alltrim(STR(nTamNSUTEF))+" - LEN(FIF.FIF_NSUTEF)) + RTrim(FIF.FIF_NSUTEF) BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' "
			Endif
        ElseIf __lDocTef
			If __lOracle .or. __lPostGre
				cQry += "AND LPAD(TRIM(FIF.FIF_NUCOMP), "+Alltrim(STR(nTamDOCTEF))+", '0') BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' "
			Else
				cQry += "AND REPLICATE('0', "+Alltrim(STR(nTamDOCTEF))+" - LEN(FIF.FIF_NUCOMP)) + RTrim(FIF.FIF_NUCOMP) BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' "
			Endif	
        Endif

        cQry += "AND FIF.FIF_STATUS IN ('1','3','4','6') "
			
        If !Empty(cAdmFinanIni)
            cQry += "AND FIF.FIF_CODRED>='" + cAdmFinanIni + "' "
        EndIf
			
        If !Empty(cAdmFinanIni) .AND. !Empty(cAdmFinanFim)
            cQry += "AND FIF.FIF_CODRED<='" + cAdmFinanFim + "' "
        EndIf
			
        If MV_PAR08 == 1
            cQry += "AND FIF.FIF_TPPROD IN ('D','V') "
        ElseiF	MV_PAR08 == 2
            cQry += "AND FIF.FIF_TPPROD='C' "
        Else
            cQry += "AND FIF.FIF_TPPROD IN ('D','V','C') "
        EndIf
			
        cQry += "AND FIF.D_E_L_E_T_=' ' "
		
		cQry += "UNION ALL " + STRTRAN(cQry,'INNER JOIN ','LEFT OUTER JOIN ')
		cQry += "AND SE1.E1_FILIAL IS NULL "
        cQry += "ORDER BY RECNO_SE1 "
    Else //Caso exista a tabela MEP, rodo a seguinte query

        cQry := "SELECT FIF.FIF_CODEST,FIF.FIF_CODLOJ,FIF.FIF_NUCOMP,FIF.FIF_DTTEF,FIF.FIF_VLLIQ,FIF.FIF_NSUTEF,"
        cQry += "FIF.FIF_PARCEL,FIF.FIF_DTCRED,FIF.FIF_STATUS,FIF.FIF_PREFIX,FIF.FIF_NUM,FIF.FIF_CODRED,FIF.FIF_PARC,"
        cQry += "FIF.FIF_TIPO,FIF.FIF_PARALF,FIF.FIF_CODBCO,FIF.FIF_CODAGE,FIF.FIF_NUMCC,FIF.FIF_CAPTUR,FIF.R_E_C_N_O_ RECNO_FIF,"
        cQry += "SE1.E1_PREFIXO,SE1.E1_NUM,SE1.E1_PARCELA,SE1.E1_TIPO,SE1.E1_CLIENTE,SE1.E1_LOJA,SE1.E1_VALOR,SE1.E1_SALDO,"
        cQry += "SE1.E1_EMISSAO,SE1.E1_VENCREA,SE1.E1_DOCTEF,SE1.E1_NSUTEF,SE1.E1_MSFIL,SE1.E1_FILORIG,SE1.R_E_C_N_O_ RECNO_SE1,MEP.MEP_PARTEF, FIF.FIF_VLBRUT, FIF.FIF_CODFIL  "
			
        cQry += " FROM " + RetSqlName("SE1") + " SE1 JOIN " + RetSqlName("FIF") + " FIF ON "
        If !__lProcDocTEF
			If __lOracle .or. __lPostGre
				cQry += " LPAD(TRIM(SE1.E1_NSUTEF), "+Alltrim(STR(nTamNSUTEF))+", '0') = LPAD(TRIM(FIF.FIF_NSUTEF), "+Alltrim(STR(nTamNSUTEF))+", '0')  AND "
			Else
				cQry += " REPLICATE('0', "+Alltrim(STR(nTamNSUTEF))+" - LEN(SE1.E1_NSUTEF)) + RTrim(SE1.E1_NSUTEF) = REPLICATE('0', "+Alltrim(STR(nTamNSUTEF))+" - LEN(FIF.FIF_NSUTEF)) + RTrim(FIF.FIF_NSUTEF) AND "
			Endif
        Else
            If __lOracle .or. __lPostGre
				cQry += " CAST(SE1.E1_DOCTEF AS NUMBER) = CAST(FIF.FIF_NUCOMP AS NUMBER) AND "
			Else
				cQry += " CAST(SE1.E1_DOCTEF AS BIGINT) = CAST(FIF.FIF_NUCOMP AS BIGINT) AND "
			EndIf
        Endif

        cQry += " SE1.E1_EMISSAO = FIF.FIF_DTTEF "
       	cQry += " AND  SE1.E1_MSFIL = FIF.FIF_CODFIL "
			
        cQry += " JOIN " + RetSqlName("MEP") + " MEP ON "
        cQry += " SE1.E1_FILIAL = MEP.MEP_FILIAL AND "
        cQry += " SE1.E1_PREFIXO = MEP.MEP_PREFIX AND "
        cQry += " SE1.E1_NUM = MEP.MEP_NUM AND "
        cQry += " SE1.E1_PARCELA = MEP.MEP_PARCEL AND "
        cQry += " SE1.E1_TIPO = MEP.MEP_TIPO AND "
        cQry += " SE1.E1_MSFIL = MEP.MEP_MSFIL "
			
        cQry += " WHERE
        If !lExclusFif
            cQry += " FIF.FIF_FILIAL = '' AND "
        EndIf
			
        If !lExclusivo
            cQry += " SE1.E1_FILIAL = '' AND "
        EndIf

        If MV_PAR08 == 1
            cQry += " SE1.E1_TIPO = 'CD' AND "
        ElseIf	MV_PAR08 == 2
            cQry += " SE1.E1_TIPO = 'CC' AND "
        Else
            cQry += " SE1.E1_TIPO IN ('CD','CC') AND "
        EndIf

        cQry += " SE1.E1_SALDO > 0 AND "
			
        If lExclusivo
            cQry += " SE1.E1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND "
        Else
            cQry += " SE1.E1_MSFIL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND "
		EndIf
		
        cQry += " SE1.D_E_L_E_T_ = ' ' AND "
			
        If lExclusMEP
            cQry += " MEP.MEP_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND "
            cQry += " MEP.MEP_FILIAL = FIF.FIF_CODFIL AND "
        Else
			cQry += " MEP.MEP_FILIAL = '  ' AND "
			cQry += " MEP.MEP_MSFIL = FIF.FIF_CODFIL AND "
        EndIf
			
        cQry += " FIF.FIF_CODFIL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND "
        cQry += " FIF.FIF_PARCEL = MEP.MEP_PARTEF AND "
        cQry += " FIF.FIF_DTCRED BETWEEN '" + dTos(dDataCredI) + "' AND '" + dTos(dDataCredF) + "' AND "
        
        If !__lProcDocTEF
			If __lOracle .or. __lPostGre
				cQry += " LPAD(TRIM(FIF.FIF_NSUTEF), "+Alltrim(STR(nTamNSUTEF))+", '0') BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' AND "
			Else	
            	cQry += " REPLICATE('0', "+Alltrim(STR(nTamNSUTEF))+" - LEN(FIF.FIF_NSUTEF)) + RTrim(FIF.FIF_NSUTEF) BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' AND "
			Endif	
        ElseIf __lDocTef
			If __lOracle .or. __lPostGre
				cQry += " LPAD(TRIM(FIF.FIF_NUCOMP), "+Alltrim(STR(nTamDOCTEF))+", '0') BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' AND "
			Else
				cQry += " REPLICATE('0', "+Alltrim(STR(nTamDOCTEF))+" - LEN(FIF.FIF_NUCOMP)) + RTrim(FIF.FIF_NUCOMP) BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' AND "
			Endif	
        Endif
        
        cQry += " FIF.FIF_STATUS IN ('1','3','4','6') AND
			
        If !Empty(cAdmFinanIni)
            cQry += " FIF.FIF_CODRED >= '" + cAdmFinanIni + "' AND "
        EndIf
			
        If !Empty(cAdmFinanIni) .AND. !Empty(cAdmFinanFim)
            cQry += " FIF.FIF_CODRED <= '" + cAdmFinanFim + "' AND "
        EndIf
			
        If MV_PAR08 == 1
            cQry += " FIF.FIF_TPPROD IN ('D','V') AND "
        ElseiF	MV_PAR08 == 2
            cQry += " FIF.FIF_TPPROD = 'C' AND "
        Else
            cQry += " FIF.FIF_TPPROD IN ('D','V','C') AND "
        EndIf
		
        cQry += " MEP.D_E_L_E_T_ = ' ' AND "
        cQry += " FIF.D_E_L_E_T_ = ' ' "
			
        cQry += " UNION ALL "
			
        cQry += "SELECT  FIF.FIF_CODEST,FIF.FIF_CODLOJ,FIF.FIF_NUCOMP,FIF.FIF_DTTEF,FIF.FIF_VLLIQ,FIF.FIF_NSUTEF,FIF.FIF_PARCEL,
        cQry += "FIF.FIF_DTCRED,FIF.FIF_STATUS,FIF.FIF_PREFIX,FIF.FIF_NUM,FIF.FIF_CODRED,FIF.FIF_PARC,FIF.FIF_TIPO,FIF.FIF_PARALF,"
        cQry += "FIF.FIF_CODBCO,FIF.FIF_CODAGE,FIF.FIF_NUMCC,FIF.FIF_CAPTUR,FIF.R_E_C_N_O_ RECNO_FIF,'' E1_PREFIXO,'' E1_NUM,"
        cQry += "'' E1_PARCELA,'' E1_TIPO,'' E1_CLIENTE,'' E1_LOJA,0 E1_VALOR,0 E1_SALDO,'' E1_EMISSAO,'' E1_VENCREA,'' E1_DOCTEF,"
        cQry += "'' E1_NSUTEF,'' E1_FILORIG,'' E1_MSFIL,0 RECNO_SE1,'' MEP_PARTEF, FIF.FIF_VLBRUT, FIF.FIF_CODFIL  "
			
        cQry += " FROM " + RetSqlName("FIF") + " FIF WHERE "
			
        If !lExclusFif
            cQry += " FIF.FIF_FILIAL = '' AND "
        EndIf
			
        cQry += " FIF.FIF_CODFIL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND "
        cQry += " FIF.FIF_DTCRED BETWEEN '" + dTos(dDataCredI) + "' AND '" + dTos(dDataCredF) + "' AND "

        If !__lProcDocTEF
			If __lOracle .or. __lPostGre
				cQry += " LPAD(TRIM(FIF.FIF_NSUTEF), "+Alltrim(STR(nTamNSUTEF))+", '0') BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' AND "
			Else
            	cQry += " REPLICATE('0', "+Alltrim(STR(nTamNSUTEF))+" - LEN(FIF.FIF_NSUTEF)) + RTrim(FIF.FIF_NSUTEF) BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' AND "
			Endif	
        ElseIf __lDocTef 
			If __lOracle .or. __lPostGre
				cQry += " LPAD(TRIM(FIF.FIF_NUCOMP), "+Alltrim(STR(nTamDOCTEF))+", '0') BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' AND "
			Else
				cQry += " REPLICATE('0', "+Alltrim(STR(nTamDOCTEF))+" - LEN(FIF.FIF_NUCOMP)) + RTrim(FIF.FIF_NUCOMP) BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' AND "
			Endif	
        EndIf
        cQry += " FIF.FIF_STATUS IN ('1','3','4','6') AND "
			
        If !Empty(cAdmFinanIni)
            cQry += " FIF.FIF_CODRED >= '" + cAdmFinanIni + "' AND "
        EndIf
			
        If !Empty(cAdmFinanIni) .AND. !Empty(cAdmFinanFim)
            cQry += " FIF.FIF_CODRED <= '" + cAdmFinanFim + "' AND "
        EndIf
			
        If MV_PAR08 == 1
            cQry += " FIF.FIF_TPPROD IN ('D','V') AND "
        ElseiF	MV_PAR08 == 2
            cQry += " FIF.FIF_TPPROD = 'C' AND "
        Else
            cQry += " FIF.FIF_TPPROD IN ('D','V','C') AND "
        EndIf

        cQry += " FIF.R_E_C_N_O_ NOT IN ( "
        cQry += " SELECT AUXFIF.R_E_C_N_O_ "
			
        cQry += " FROM " + RetSqlName("SE1") + " SE1 JOIN " + RetSqlName("FIF") + " AUXFIF ON "
        
        If !__lProcDocTEF
			If __lOracle .or. __lPostGre
				cQry += " LPAD(TRIM(SE1.E1_NSUTEF), "+Alltrim(STR(nTamNSUTEF))+", '0') = LPAD(TRIM(AUXFIF.FIF_NSUTEF), "+Alltrim(STR(nTamNSUTEF))+", '0') AND "
			Else	
				cQry += " REPLICATE('0', "+Alltrim(STR(nTamNSUTEF))+" - LEN(SE1.E1_NSUTEF)) + RTrim(SE1.E1_NSUTEF) = REPLICATE('0', "+Alltrim(STR(nTamNSUTEF))+" - LEN(AUXFIF.FIF_NSUTEF)) + RTrim(AUXFIF.FIF_NSUTEF) AND "
			Endif	
        Else
            If __lOracle .or. __lPostGre
				cQry += " CAST(SE1.E1_DOCTEF AS NUMBER) = CAST(AUXFIF.FIF_NUCOMP AS NUMBER) AND "
			Else
				cQry += " CAST(SE1.E1_DOCTEF AS BIGINT) = CAST(AUXFIF.FIF_NUCOMP AS BIGINT) AND "
			EndIf
        Endif

        cQry += " SE1.E1_EMISSAO = AUXFIF.FIF_DTTEF AND "
        cQry += " SE1.E1_MSFIL = AUXFIF.FIF_CODFIL "
			
        cQry += " JOIN " + RetSqlName("MEP") + " MEP ON "
        cQry += " SE1.E1_FILIAL = MEP.MEP_FILIAL AND "
        cQry += " SE1.E1_PREFIXO = MEP.MEP_PREFIX AND "
        cQry += " SE1.E1_NUM = MEP.MEP_NUM AND "
        cQry += " SE1.E1_PARCELA = MEP.MEP_PARCEL AND "
        cQry += " SE1.E1_TIPO = MEP.MEP_TIPO AND "
        cQry += " SE1.E1_MSFIL = MEP.MEP_MSFIL "

        cQry += " WHERE "
        If !lExclusFif
            cQry += " AUXFIF.FIF_FILIAL = '' AND "
        EndIf
			
        If !lExclusivo
            cQry += " SE1.E1_FILIAL = '' AND "
        EndIf

        If MV_PAR08 == 1
            cQry += " SE1.E1_TIPO = 'CD' AND "
        ElseIf	MV_PAR08 == 2
            cQry += " SE1.E1_TIPO = 'CC' AND "
        Else
            cQry += " SE1.E1_TIPO IN ('CD','CC') AND "
        EndIf

        cQry += " SE1.E1_SALDO > 0 AND "
			
        If lExclusivo
            cQry += " SE1.E1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND "
        Else
            cQry += " SE1.E1_MSFIL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND "
        EndIf
			
        cQry += " SE1.D_E_L_E_T_ = ' ' AND "
			
        If lExclusMEP
            cQry += " MEP.MEP_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND "
            cQry += " MEP.MEP_FILIAL = AUXFIF.FIF_CODFIL AND "
        Else
			cQry += " MEP.MEP_FILIAL = '  ' AND "
			cQry += " MEP.MEP_MSFIL  = AUXFIF.FIF_CODFIL AND "
        EndIf
			
        cQry += " AUXFIF.FIF_CODFIL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND "
        cQry += " AUXFIF.FIF_PARCEL = MEP.MEP_PARTEF AND "
        cQry += " AUXFIF.FIF_DTCRED BETWEEN '" + dTos(dDataCredI) + "' AND '" + dTos(dDataCredF) + "' AND "

        If !__lProcDocTEF
			If __lOracle .or. __lPostGre
				cQry += " LPAD(TRIM(AUXFIF.FIF_NSUTEF), "+Alltrim(STR(nTamNSUTEF))+", '0') BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' AND "
			Else
            	cQry += " REPLICATE('0', "+Alltrim(STR(nTamNSUTEF))+" - LEN(AUXFIF.FIF_NSUTEF)) + RTrim(AUXFIF.FIF_NSUTEF) BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' AND "
			Endif	
        ElseIf __lDocTef
			If __lOracle .or. __lPostGre
				cQry += " LPAD(TRIM(FIF.FIF_NUCOMP), "+Alltrim(STR(nTamDOCTEF))+", '0') BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' AND "
			Else
				cQry += " REPLICATE('0', "+Alltrim(STR(nTamDOCTEF))+" - LEN(AUXFIF.FIF_NUCOMP)) + RTrim(AUXFIF.FIF_NUCOMP) BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' AND "
			Endif	
        Endif

        cQry += " AUXFIF.FIF_STATUS IN ('1','3','4','6') AND "
			
        If !Empty(cAdmFinanIni)
            cQry += " AUXFIF.FIF_CODRED >= '" + cAdmFinanIni + "' AND "
        EndIf
			
        If !Empty(cAdmFinanIni) .AND. !Empty(cAdmFinanFim)
            cQry += " AUXFIF.FIF_CODRED <= '" + cAdmFinanFim + "' AND "
        EndIf
			
        If MV_PAR08 == 1
            cQry += " AUXFIF.FIF_TPPROD IN ('D','V') AND "
        ElseiF	MV_PAR08 == 2
            cQry += " AUXFIF.FIF_TPPROD = 'C' AND "
        Else
            cQry += " AUXFIF.FIF_TPPROD IN ('D','V','C') AND "
        EndIf
        cQry += " MEP.D_E_L_E_T_ = ' ' AND "
        cQry += " AUXFIF.D_E_L_E_T_ = ' ' "
        cQry += " ) AND "
        cQry += " FIF.D_E_L_E_T_ = '' "
			
        cQry += " ORDER BY "
        cQry += " RECNO_SE1 "
    EndIf

    cQry := ChangeQuery(cQry)
    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),cAliasSitef,.F.,.T.)
                       
    dbSelectArea("SA6")
    SA6->(dbSetOrder(1))

    dbSelectArea("FIF")
    FIF->(dbSetOrder(5))
		
    If !(cAliasSitef)->(Eof())
			
        While !(cAliasSitef)->(Eof())
			//Limpa o array auxiliar
            aColsAux := {}
			// somente verifica novamente na SX6 se MSFil mudar
            If cMSFIL <> (cAliasSitef)->FIF_CODFIL
                cFilSitef := SuperGetMv("MV_EMPTEF",.F.,,(cAliasSitef)->FIF_CODFIL)
                cMSFIL := (cAliasSitef)->FIF_CODFIL				
                If Empty(cFilSitef) .and. lMsgTef
					If __l910Auto
						lMsgTef:= .F.
					Else
                		lMsgTef:= MsgYesNo(STR0162 + Alltrim((cAliasSitef)->FIF_CODFIL) + STR0163) // "Não existe o parâmetro MV_EMPTEF para a Empresa/Filial " ## ". O movimento não será conciliado. Continua exibindo alerta?" 
					EndIf
                EndIf
            EndIf
				
            cValConta := ''

            If lPontoF
                aDados := ExecBlock('FINA910F', .F., .F., {(cAliasSitef)->FIF_CODBCO, (cAliasSitef)->FIF_CODAGE, (cAliasSitef)->FIF_NUMCC})
					
                If !(ValType(aDados) == 'A')
                    cValConta := STR0103      //"CONTA NAO CADASTRADA"
                    lPontoF := .f.
                Else
                    cValConta := STR0104	//"OK"
                EndIf
            Else
                If !Empty((cAliasSitef)->FIF_CODBCO) .And. !Empty((cAliasSitef)->FIF_CODAGE) .And. !Empty((cAliasSitef)->FIF_NUMCC) 
                    If !A910VLDBCO(  Padr(Alltrim((cAliasSitef)->FIF_CODBCO), nTamBanco), Padr(Alltrim((cAliasSitef)->FIF_CODAGE), nTamAgencia), Padr(Alltrim(StrTran((cAliasSitef)->FIF_NUMCC,"-","")), nTamCC))
                        cValConta := STR0103     //'CONTA NAO CADASTRADA'
                    Else
                        cValConta := STR0104     //'OK'
                    EndIf
                EndIf
            EndIf

			If !Empty((cAliasSitef)->FIF_NSUTEF)
				cNsuFIF := PADR("", nTamNSUTEF - len(Alltrim((cAliasSitef)->FIF_NSUTEF)),'0') + Alltrim((cAliasSitef)->FIF_NSUTEF)
			Endif
			If !Empty((cAliasSitef)->FIF_NUCOMP)
				cDocFIF := PADR("", nTamDOCTEF - len(Alltrim((cAliasSitef)->FIF_NUCOMP)),'0') + Alltrim((cAliasSitef)->FIF_NUCOMP)
			Endif

			If !Empty((cAliasSitef)->E1_NSUTEF)
				cNsuSe1 := PADR("", nTamNSUTEF - len(Alltrim((cAliasSitef)->E1_NSUTEF)),'0') + Alltrim((cAliasSitef)->E1_NSUTEF)
			Endif
			If !Empty((cAliasSitef)->E1_DOCTEF)
				cDocSE1 := PADR("", nTamDOCTEF - len(Alltrim((cAliasSitef)->E1_DOCTEF)),'0') + Alltrim((cAliasSitef)->E1_DOCTEF)
			Endif
				
            aAdd(aColsAux,'')								//1-Status oNSelec
            aAdd(aColsAux,(cAliasSitef)->FIF_CODEST)		//2-Codigo do Estabelecimento Sitef
            aAdd(aColsAux,(cAliasSitef)->FIF_CODLOJ)		//3-Codigo da Loja Sitef
            aAdd(aColsAux,(cAliasSitef)->E1_CLIENTE)		//4-Codigo do Cliente (Administradora)
            aAdd(aColsAux,(cAliasSitef)->E1_PREFIXO)		//5-Prefixo do titulo Protheus
            aAdd(aColsAux,(cAliasSitef)->E1_NUM)			//6-Numero do titulo Protheus
            aAdd(aColsAux,(cAliasSitef)->E1_TIPO)			//7-Tipo do titulo Protheus
            aAdd(aColsAux,(cAliasSitef)->E1_PARCELA)		//8-Numero da parcela Protheus
            aAdd(aColsAux,RIGHT(cDocFIF,12))				//9-Numero do Comprovante Sitef
            aAdd(aColsAux,Stod((cAliasSitef)->FIF_DTTEF))	//10-Data da Venda Sitef
            aAdd(aColsAux,StoD((cAliasSitef)->FIF_DTCRED))	//11-Data de Credito Sitef
            aAdd(aColsAux,(cAliasSitef)->E1_SALDO)			//12-Valor do titulo Protheus
            If lLJGERTX 
            	aAdd(aColsAux,(cAliasSitef)->FIF_VLBRUT)	//13-Valor Bruto Sitef
            Else
            	aAdd(aColsAux,(cAliasSitef)->FIF_VLLIQ)		//13-Valor liquido Sitef
            EndIf
            aAdd(aColsAux,RIGHT(cNsuFIF,12))	//14-Numero NSU Sitef
            aAdd(aColsAux,(cAliasSitef)->FIF_PARCEL)			//15-Numero da parcela Sitef
            aAdd(aColsAux,RIGHT(cDocSE1,12))					//16-Documento TEF Protheus
            aAdd(aColsAux,RIGHT(cNsuSe1,12))					//17-NSU Sitef Protheus
            aAdd(aColsAux,StoD((cAliasSitef)->E1_VENCREA))		//18-Vencimento real do titulo

            If !lPontoF 
                aAdd(aColsAux,(cAliasSitef)->FIF_CODBCO +' / '+(cAliasSitef)->FIF_CODAGE+' / '+(cAliasSitef)->FIF_NUMCC)//19-banco/agencia/conta
                cCodBco := Padr(Alltrim((cAliasSitef)->FIF_CODBCO) ,nTamBanco )
                cCodAge := Padr(Alltrim((cAliasSitef)->FIF_CODAGE) ,nTamAgencia )
                cNumCC  := Padr(Alltrim((cAliasSitef)->FIF_NUMCC)  ,nTamCC )
            Else 
                aAdd(aColsAux,aDados[1] +' / '+aDados[2]+' / '+aDados[3])//19-banco/agencia/conta
                cCodBco := Padr(Alltrim( aDados[1]),nTamBanco )
                cCodAge := Padr(Alltrim( aDados[2]),nTamAgencia )
                cNumCC  := Padr(Alltrim( aDados[3]),nTamCC )
            EndIF

            aAdd(aColsAux,cValConta)       //20-Informação de conta não cadastrada ou cadastrada
            aAdd(aColsAux,(cAliasSitef)->FIF_CAPTUR)       //21 - (0,2 ou 3 - Transação Sitef),(1 ou 4 - Outros/POS)
            aAdd(aColsAux,(cAliasSitef)->RECNO_SE1)        //22 - RECNO do SE1
            aAdd(aColsAux,(cAliasSitef)->RECNO_FIF)        //23 - RECNO do FIF
				
            If !lPontoF 
                aAdd(aColsAux, Padr(Alltrim((cAliasSitef)->FIF_CODAGE), nTamAgencia) )      //24 - Agencia
                aAdd(aColsAux, Padr(Alltrim((cAliasSitef)->FIF_NUMCC), nTamCC)   )          //25 - Conta
                aAdd(aColsAux, Padr(Alltrim((cAliasSitef)->FIF_CODBCO), nTamBanco) )        //26 - Banco
            Else
                aAdd(aColsAux, aDados[2] )     //24 - Agencia
                aAdd(aColsAux, aDados[3] )     //25 - Conta
                aAdd(aColsAux, aDados[1] )     //26 - Banco 	aDados
            EndIf
				
            aAdd(aColsAux,(cAliasSitef)->E1_LOJA)          //27 - Codigo da Loja
            aAdd(aColsAux,(cAliasSitef)->FIF_CODFIL)	  //28 - FILIAL
				
			//Tratamento para Conciliados Manualmente
            If (cAliasSitef)->FIF_STATUS == '4'
                If A910VLDBCO(cCodBco,cCodAge,cNumCC) .And.; //Valido se a conta está bloqueada, caso esteja (.F.), marco o flag como preto e mudo o status da conta para BLOQUEADA
                    AllTrim(Upper(cValConta)) == "OK"
                    aColsAux[1] := LoadBitmap(GetResources(), "BR_BRANCO") //"BR_BRANCO"
                Else
                    aColsAux[1] := LoadBitmap(GetResources(), "BR_PRETO") //"BR_PRETO"

                    If AllTrim(Upper(cValConta)) == "OK"
                        aColsAux[20] := STR0131
                    EndIf
                EndIf
				
                aColsAux[5] := (cAliasSitef)->FIF_PREFIX //Rastro Prefixo SE1
                aColsAux[6] := (cAliasSitef)->FIF_NUM    //Rastro Num SE1
                aColsAux[8] := (cAliasSitef)->FIF_PARC   //Rastro Parcela SE1
                aColsAux[7] := (cAliasSitef)->FIF_TIPO   //Rastro Tipo SE1
					
                aAdd(aConcMan,aColsAux)
                If RecLock("TMP",.T.)
                    TMP->SOURCE	:= PadR('CONCMAN',10,' ')
                    TMP->RECNO		:= StrZero((cAliasSitef)->RECNO_SE1, 10)
                    TMP->(MSUNLOCK())
                EndIf
					
            Else
				//Tratamento para os Nao Conciliados
                If Empty((cAliasSitef)->E1_NSUTEF)
						
                    aColsAux[22] := 0   //limpa o recno do se1
						
                    If A910VLDBCO(cCodBco,cCodAge,cNumCC) .And.; //Valido se a conta está bloqueada, caso esteja (.F.), marco o flag como preto e mudo o status da conta para BLOQUEADA
                        AllTrim(Upper(cValConta)) == "OK"
                        aColsAux[1] := LoadBitmap(GetResources(), "BR_BRANCO") //"BR_BRANCO"
                    Else
                        aColsAux[1]	 := LoadBitmap(GetResources(), "BR_PRETO") //"BR_PRETO"
                        If AllTrim(Upper(cValConta)) == "OK"
                            aColsAux[20] := STR0131
                        EndIf
                    EndIf

                    aAdd(aNaoConc,aColsAux)
						
				//Tratamento para os Conciliados
                ElseIf (cAliasSitef)->FIF_VLLIQ >= (cAliasSitef)->E1_SALDO - ((cAliasSitef)->E1_SALDO * (nMargem/100))  .AND.;
                        AllTrim(cNsuFIF) ==  cNsuSe1  .AND.; //NSU SITEF
                    AllTrim((cAliasSitef)->FIF_DTTEF)  ==  AllTrim((cAliasSitef)->E1_EMISSAO) .AND.; // Data emissão
                    AllTrim(cFilSitef) == AllTrim((cAliasSitef)->FIF_CODLOJ) .AND.; //Inserido por Carlos Queiroz em 10/02/11
                    ( AllTrim((cAliasSitef)->MEP_PARTEF) == AllTrim((cAliasSitef)->FIF_PARCEL ) .Or. ; // Fabiana 29/06/11 - Incluida a validacao para mep_parctf
                    ( Empty((cAliasSitef)->MEP_PARTEF)  .AND. ( Val((cAliasSitef)->FIF_PARCEL) ==  Val((cAliasSitef)->E1_PARCELA) .OR. ;
                        Val((cAliasSitef)->FIF_PARALF) == Val((cAliasSitef)->E1_PARCELA) ;
                        ) ;
                        );
                        )

					//-------------------------------------------------------------------------------------
					// Existe a possibilidade de existir um registro na FIF com os dados iguais
					// FIF_FILIAL / FIF_DTTEF / FIF_NSUTEF / FIF_PARCEL E FIF_CODLOJ
					// Isto ocorre por causa das transacoes feitas em POS, com isso, teremos
					// dois ou mais registros na FIF com referencia ao mesmo registro da SE1.
					// Neste caso, so iremos conciliar o primeiro que foi encontrado e o outro(s)
					// ira(ao) para a pasta de não conciliados.
					// Procura no array de conciliados o recno do SE1
					//-------------------------------------------------------------------------------------
                    If Empty(aConc) .or. (aConc[Len(aConc)][22] <> aColsAux[22])
						//Valido se a conta está bloqueada, caso esteja (.F.), marco o flag como preto e mudo o status da conta para BLOQUEADA
                        If A910VLDBCO(cCodBco,cCodAge,cNumCC) .And. AllTrim(Upper(cValConta)) == "OK"
							SE1->(DbGoTo((cAliasSitef)->RECNO_SE1))
							If SE1->(MsRLock())
								aColsAux[1] := LoadBitmap(GetResources(), "BR_VERDE") //"BR_BRANCO"
							else
								aColsAux[1] := LoadBitmap(GetResources(), "BR_BRANCO") //"BR_BRANCO"
							EndIf 
                        Else
                            aColsAux[1]	 := LoadBitmap(GetResources(), "BR_PRETO") //"BR_PRETO"
                            If AllTrim(Upper(cValConta)) == "OK"
                                aColsAux[20] := STR0131
                            EndIf
                        EndIf
						
                        aAdd(aConc,aColsAux)
						
                        If RecLock("TMP",.T.)
                            TMP->SOURCE	:= PadR('CONC',10,' ')
                            TMP->RECNO		:= StrZero((cAliasSitef)->RECNO_SE1, 10)
                            TMP->(MSUNLOCK())
                        EndIf
                    Else
						//Valido se a conta está bloqueada, caso esteja (.F.), marco o flag como preto e mudo o status da conta para BLOQUEADA
                        If A910VLDBCO(cCodBco,cCodAge,cNumCC) .And. AllTrim(Upper(cValConta)) == "OK"
                            aColsAux[1] := LoadBitmap(GetResources(), "BR_BRANCO") //"BR_BRANCO"
                        Else
                            aColsAux[1]	 := LoadBitmap(GetResources(), "BR_PRETO") //"BR_PRETO"
							
                            If AllTrim(Upper(cValConta)) == "OK"
                                aColsAux[20] := STR0131
                            EndIf
                        EndIf
					
                        aAdd(aNaoConc,aColsAux)
                    EndIf
						
					//Tratamento para os Conciliados Parcialmente
                Else
					//Valido se a conta está bloqueada, caso esteja (.F.), marco o flag como preto e mudo o status da conta para BLOQUEADA
                    If A910VLDBCO(cCodBco,cCodAge,cNumCC) .And. AllTrim(Upper(cValConta)) == "OK"
						If __l910Auto
                        	aColsAux[1] := LoadBitmap(GetResources(), "BR_VERDE") //"BR_VERDE"
						Else
							aColsAux[1] := LoadBitmap(GetResources(), "BR_BRANCO") //"BR_BRANCO"
						EndIf

                    Else
                        aColsAux[1] := LoadBitmap(GetResources(), "BR_PRETO") //"BR_PRETO"
						
                        If AllTrim(Upper(cValConta)) == "OK"
                            aColsAux[20] := STR0131
                        EndIf
                    EndIf
					
                    	aAdd(aConcPar,aColsAux)  
					
                    If RecLock("TMP",.T.)
                        TMP->SOURCE	:= PadR('CONCPAR',10,' ')
                        TMP->RECNO		:= StrZero((cAliasSitef)->RECNO_SE1, 10)
                        TMP->(MSUNLOCK())
                    EndIf
						
					//Armazena os indicadores para exibir as divergencias (Rodape Conciliados Parcialmente)
                    aAdd(aIndic,{	(cAliasSitef)->E1_SALDO			,;
                        			(cAliasSitef)->FIF_VLLIQ		,;
                        			(cAliasSitef)->E1_NSUTEF		,;
                        			RIGHT((cAliasSitef)->FIF_NSUTEF,12)		,;
                        			StoD((cAliasSitef)->E1_EMISSAO)	,;
                        			StoD((cAliasSitef)->FIF_DTTEF)	,;
                        			(cAliasSitef)->E1_PARCELA		,;
                        			(cAliasSitef)->FIF_PARCEL		,;
                        			(cAliasSitef)->E1_PREFIXO		,;
                        			(cAliasSitef)->E1_NUM			,;
                        			(cAliasSitef)->E1_TIPO			})
                EndIf
            EndIf
            (cAliasSitef)->(dbSkip())
        EndDo
    EndIf

    (cAliasSitef)->(dbCloseArea())

    RestArea(aArea)
EndIf
		
//Carrega o array de Divergencias
If Len(aIndic) == 0
	aAdd(aIndic,{0,0,"","",cTod("  /  /  "),cTod("  /  /  "),"","","","",""})
EndIf
	
If Len(aConc) == 0 .AND. Len(aConcPar) == 0 .AND. Len(aNaoConc) == 0
	//"Não foram encontradas informacoes com os parametros repassados, favor verificar novamente"
	Help(" ",1,"A910NoInfo",,STR0049 ,1,0,,,,,,/*{STR0094}*/)
	lRet := .F.
EndIf
	
Return(lRet)

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910Total
Atualiza o array com o valor total dos registros                            

@type Function
@author Rafael Rosa da Silva
@since 05/08/2009
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A910Total( aConc, aConcPar, aNaoConc, aConcMan, aTotais, aHeader, aHeadMan )
Local nI   	:= 0						//Variavel para incrementar intervalo selecionado
Local nPos 	:= 0						//Variavel para verificar se existe valor no array aTotais
Local dData	:= CTOD("  /  /    ")

//Percorre o array aConc somando os registros de acordo com a data
For nI := 1 to Len(aConc)
	
	//Verifica se ja existe um registro para a data em questao
	If nPos == 0 .or. dData <> aConc[nI][11]
		dData := aConc[nI][11]
		nPos := aScan(aTotais,{|x| x[1] == aConc[nI][11] })
	EndIf
					
	If nPos == 0
		aAdd(aTotais,{	aConc[nI][11]	,;	//Data de Credito
						aConc[nI][13]	,;	//Valor Total da Coluna Conciliados
						1				,;	//Quantidade de registros da coluna Conciliados
						0				,;	//Valor Total da Coluna Conciliados Parcialmente
						0				,;	//Quantidade de registros da coluna Conciliados Parcialmente
						0				,;	//Valor Total da Coluna Conciliados Manualmente
						0				,;	//Quantidade de registros da coluna Conciliados Manualmente
						0				,;	//Valor Total da Coluna Nao Conciliados
						0				,;	//Quantidade de registros da coluna Nao Conciliados
						0})					//Total Geral
	Else
		aTotais[nPos][TOT_CONC] += aConc[nI][13] //Somatorio Conciliados
		aTotais[nPos][TOT_CONC] := Round(aTotais[nPos][TOT_CONC],2)
		aTotais[nPos][TOT_QTDCONC] += 1
	EndIf
Next nI
	
//Percorre o array aConcPar somando os registros de acordo com a data
dData	:= CTOD("  /  /    ")
nPos 	:= 0

For nI := 1 to Len(aConcPar)
	//Verifica se ja existe um registro para a data em questao
	If nPos == 0 .or. dData <> aConcPar[nI][11]
		dData := aConcPar[nI][11]
		nPos := aScan(aTotais,{|x| x[1] == aConcPar[nI][11] })
	EndIf

	If nPos == 0
		aAdd(aTotais,{	aConcPar[nI][11],;	//Data de Credito
						0				,;	//Valor Total da Coluna Conciliados
						0				,;	//Quantidade de registros da Coluna Conciliados
						aConcPar[nI][13],;	//Valor Total da Coluna Conciliados Parcialmente
						1				,;	//Quantidade de registros da coluna Conciliados Parcialmente
						0				,;	//Valor Total da Coluna Conciliados Manualmente
						0				,;	//Quantidade de registros da coluna Conciliados Manualmente
						0				,;	//Valor Total da Coluna Nao Conciliados
						0				,;	//Quantidade de registros da coluna Nao Conciliados
						0})					//Total Geral
	Else
		aTotais[nPos][TOT_CPAR] += aConcPar[nI][13] //Somatorio Conciliados Parcialmente
		aTotais[nPos][TOT_CPAR] := Round(aTotais[nPos][TOT_CPAR],2)
		aTotais[nPos][TOT_QTDCPAR] += 1
	EndIf
Next nI
		
//Percorre o array aNaoConc somando os registros de acordo com a data
dData	:= CTOD("  /  /    ")
nPos	:= 0

For nI := 1 to Len(aNaoConc)
	//Verifica se ja existe um registro para a data em questao       
	If nPos == 0 .or. dData <> aNaoConc[nI][11]
		dData := aNaoConc[nI][11]
		nPos := aScan(aTotais,{|x| x[1] == aNaoConc[nI][11] })
	EndIf

	If nPos == 0
		aAdd(aTotais,{	aNaoConc[nI][11],;	//Data de Credito
						0				,;	//Valor Total da Coluna Conciliados
						0				,;	//Quantidade de registros da Coluna Conciliados
						0				,;	//Valor Total da Coluna Conciliados Parcialmente
						0				,;	//Quantidade de registros da coluna Conciliados Parcialmente
						0				,;	//Valor Total da Coluna Conciliados Manualmente
						0				,;	//Quantidade de registros da coluna Conciliados Manualmente
						aNaoConc[nI][13],;	//Valor Total da Coluna Nao Conciliados
						1				,;	//Quantidade de registros da coluna Nao Conciliados
						0})					//Total Geral
	Else
		aTotais[nPos][TOT_CNAO] += aNaoConc[nI][13] //Somatorio Nao Conciliados
		aTotais[nPos][TOT_CNAO] := Round(aTotais[nPos][TOT_CNAO],2)
		aTotais[nPos][TOT_QTDCNAO] += 1
	EndIf
Next nI
	
dData	:= CTOD("  /  /    ")
nPos	:= 0

For nI := 1 to Len(aConcMan)
	//Verifica se ja existe um registro para a data em questao
	If nPos == 0 .or. dData <> aConcMan[nI][11]
		dData := aConcMan[nI][11]
		nPos := aScan(aTotais,{|x| x[1] == aConcMan[nI][11]})
	EndIf

	If nPos == 0
		aAdd(aTotais,{	aConcMan[nI][11],;	//Data de Credito
						0				,;	//Valor Total da Coluna Conciliados
						0				,;	//Quantidade de registros da Coluna Conciliados
						0				,;	//Valor Total da Coluna Conciliados Parcialmente
						0				,;	//Quantidade de registros da coluna Conciliados Parcialmente
						aConcMan[nI][13],;	//Valor Total da Coluna Conciliados Manualmente
						1				,;	//Quantidade de registros da coluna Conciliados Manualmente
						0				,;	//Valor Total da Coluna Nao Conciliados
						0				,;	//Quantidade de registros da coluna Nao Conciliados
						0})					//Total Geral
	Else
		aTotais[nPos][TOT_CMAN] += aConcMan[nI][13] //Somatorio Conciliados Manualmente
		aTotais[nPos][TOT_CMAN] := Round(aTotais[nPos][TOT_CMAN],2)
		aTotais[nPos][TOT_QTDCMAN] += 1
	EndIf
Next nI
		
//Percorre o array aConcMan somando os registros de acordo com a data
For nI := 1 to Len(aTotais)
	aTotais[nI][TOT_GERAL] := aTotais[nI][TOT_CONC]+aTotais[nI][TOT_CPAR]+aTotais[nI][TOT_CMAN]+aTotais[nI][TOT_CNAO]
	aTotais[nI][TOT_GERAL] := Round(aTotais[nI][TOT_GERAL],2)
Next nI
	
	//caso nao exista nenhum registro de somatoria, crio uma linha em branco para evitar erro
If Len(aTotais) == 0
	aAdd(aTotais,{cTod("  /  /  "),0,0,0,0,0,0,0,0,0})
EndIf
	
Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910Titulos
Funcao que retorna todos os titulos do contas a receber que possuam dados 
parecidos com os recebidos do arquivo de Conciliacao do SITEF                                       

@type Function
@author Rafael Rosa da Silva
@since 06/08/2009
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A910Titulos( aDados, nLinha, oSelec, aTitulos, oTitulos, oNSelec, aConc, aConcPar, lWhenConc )

Local cQry	    		:= ""						//Instrucao de query no banco
Local cAliasSitef    	:= GetNextAlias()         	//Variavel que recebe o proximo Alias disponivel
Local nNaoConc			:= 1						//Verificador se titulo possui vinculo com arquivos Sitef
Local nNaoConcPa		:= 1						//Verificador se titulo possui vinculo com arquivos Sitef
Local lExclusivo		:= !Empty(xFilial("SE1"))	//Verifica se SE1 esta' compartilhada ou exclusiva
Local lExclusFIF		:= !Empty(xFilial("FIF"))	//Verifica se FIF esta' compartilhada ou exclusiva
Local lExclusMEP		:= !Empty(xFilial("MEP"))	//Verifica se MEP esta' compartilhada ou exclusiva
Local cSubstring		:= ""
Local lUsaMep       	:= SuperGetMv("MV_USAMEP",.T.,.F.)
Local cDocSE1      		:= ""
Local cNsuSe1 			:= ""
Local cNsuDe 			:= ""
Local cNSUAte 			:= ""

If !__lProcDocTEF
	cNsuDe  := PADR("", nTamNSUTEF - len(Alltrim(MV_PAR05)),Iif(!Empty(MV_PAR05),'0',' ')) + Alltrim(MV_PAR05)
	cNSUAte := PADR("", nTamNSUTEF - len(Alltrim(MV_PAR06)),Iif(!Empty(MV_PAR06),'0','Z')) + Alltrim(MV_PAR06)
ElseIf __lDocTef
	cNsuDe  := PADR("", nTamDOCTEF - len(Alltrim(MV_PAR05)),Iif(!Empty(MV_PAR05),'0',' ')) + Alltrim(MV_PAR05)
	cNSUAte := PADR("", nTamDOCTEF - len(Alltrim(MV_PAR06)),Iif(!Empty(MV_PAR06),'0','Z')) + Alltrim(MV_PAR06)
Endif

If __lDefTop == Nil
	__lDefTop := FindFunction("IFDEFTOPCTB") .And. IfDefTopCTB() 
EndIf
	
If !Empty(aDados[nLinha][2]) .AND. !Empty(aDados[nLinha][3])
    If __lDefTop
        If ( AllTrim( Upper( TcGetDb() ) ) $ "ORACLE_INFORMIX" )
            cSubstring := "SUBSTR"
			__lOracle  := .T.
        ElseIf ( AllTrim( Upper( TcGetDb() ) ) $ "DB2|DB2/400")
            cSubstring := "SUBSTR"
        Else
            cSubstring := "SUBSTRING"
        EndIf
			
		 //Query para buscar os titulos no financeiro semelhantes aos titulos Sitef
        If !lMEP .or. !lUsaMep
            cQry := "SELECT SE1.E1_EMISSAO, SE1.E1_VENCREA, SE1.E1_NSUTEF, SE1.E1_DOCTEF ,SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_FILORIG, "
            cQry += "SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_VALOR, SE1.E1_SALDO, SE1.E1_MSFIL, SE1.E1_FILIAL, SE1.R_E_C_N_O_ RECNOSE1, "

            cQry += " '"+ Space(nTamParc) +"' AS MEP_PARTEF "
            cQry += "FROM " + RetSqlName("SE1") + " SE1 "

            cQry += "WHERE SE1.D_E_L_E_T_=' ' "

            If lExclusivo
                cQry += "AND SE1.E1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
            Else
                cQry += "AND SE1.E1_MSFIL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
            EndIf
				
            If	MV_PAR08 == 1
                cQry += "AND SE1.E1_TIPO = 'CD' "
            ElseIf	MV_PAR08 == 2
                cQry += "AND SE1.E1_TIPO = 'CC' "
            Else
                cQry += "AND SE1.E1_TIPO IN ('CC','CD') "
            EndIf
				
            cQry += "AND SE1.E1_VENCREA  BETWEEN '" + dTos(dDataCredI - nQtdDias) + "' AND '" + dTos(dDataCredF) + "' "
            cQry += "AND SE1.E1_SALDO > 0 "
            cQry += "ORDER BY SE1.E1_VALOR "
        Else
            cQry += " SELECT SE1.E1_EMISSAO, SE1.E1_VENCREA, SE1.E1_NSUTEF, SE1.E1_DOCTEF, SE1.E1_PREFIXO, SE1.E1_NUM, SE1.E1_PARCELA, SE1.E1_TIPO, SE1.E1_FILORIG, "
            cQry += " SE1.E1_CLIENTE, SE1.E1_LOJA, SE1.E1_VALOR, SE1.E1_SALDO, SE1.E1_MSFIL, SE1.E1_FILIAL,	SE1.R_E_C_N_O_ RECNOSE1, MEP.MEP_PARTEF "
            cQry += " FROM " + RetSqlName("SE1") + " SE1 LEFT JOIN " + RetSqlName("MEP") + " MEP ON "
			
            If lExclusivo
                cQry += " SE1.E1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
            Else
                cQry += " SE1.E1_FILIAL = '' "
                cQry += " AND SE1.E1_MSFIL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
            EndIf
			
            cQry += " AND SE1.E1_FILIAL = MEP.MEP_FILIAL "
            cQry += " AND SE1.E1_PREFIXO = MEP.MEP_PREFIX "
            cQry += " AND SE1.E1_NUM = MEP.MEP_NUM "
            cQry += " AND SE1.E1_PARCELA = MEP.MEP_PARCEL "
            cQry += " AND SE1.E1_TIPO = MEP.MEP_TIPO "
			
            If !lExclusMEP
                cQry += " AND MEP.MEP_FILIAL = '' "
            EndIf
			
            cQry += " AND MEP.D_E_L_E_T_ = ''  "

            If lExclusivo
                cQry += " WHERE SE1.E1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
            Else
                cQry += " WHERE SE1.E1_FILIAL = '' "
                cQry += " AND SE1.E1_MSFIL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' "
            EndIf
            cQry += " AND SE1.E1_VENCREA BETWEEN '" + DtoS(dDataCredI - nQtdDias) + "' AND '" + DtoS(dDataCredF) + "' "

            If MV_PAR08 == 1
                cQry += " AND SE1.E1_TIPO = 'CD' "
            ElseIf	MV_PAR08 == 2
                cQry += " AND SE1.E1_TIPO = 'CC' "
            Else
                cQry += " AND SE1.E1_TIPO IN ('CD','CC') "
            EndIf

            cQry += " AND SE1.E1_SALDO > 0 "

            If !__lProcDocTEF
				If __lOracle .or. __lPostGre
					cQry += " AND LPAD(TRIM(SE1.E1_NSUTEF), "+Alltrim(STR(nTamNSUTEF))+", '0') NOT IN ( "
                	cQry += " SELECT LPAD(TRIM(AUXFIF.FIF_NSUTEF), "+Alltrim(STR(nTamNSUTEF))+", '0') "
				Else
               	 	cQry += " AND REPLICATE('0', "+Alltrim(STR(nTamNSUTEF))+" - LEN(SE1.E1_NSUTEF)) + RTrim(SE1.E1_NSUTEF) NOT IN ( "
                	cQry += " SELECT REPLICATE('0', "+Alltrim(STR(nTamNSUTEF))+" - LEN(AUXFIF.FIF_NSUTEF)) + RTrim(AUXFIF.FIF_NSUTEF) "
				Endif	
            Else
				If __lOracle .or. __lPostGre
					cQry += " AND LPAD(TRIM(SE1.E1_DOCTEF), "+Alltrim(STR(nTamDOCTEF))+", '0') NOT IN ( "
                	cQry += " SELECT LPAD(TRIM(AUXFIF.FIF_NUCOMP), "+Alltrim(STR(nTamDOCTEF))+", '0') "
				Else
                	cQry += " AND REPLICATE('0', "+Alltrim(STR(nTamDOCTEF))+" - LEN(SE1.E1_DOCTEF)) + RTrim(SE1.E1_DOCTEF) NOT IN ( "
                	cQry += " SELECT REPLICATE('0', "+Alltrim(STR(nTamDOCTEF))+" - LEN(AUXFIF.FIF_NUCOMP)) + RTrim(AUXFIF.FIF_NUCOMP)"
				Endif
            Endif

            cQry += " FROM " + RetSqlName("SE1") + " SE1 "

            cQry += " JOIN " + RetSqlName("FIF") + " AUXFIF "
            cQry += " ON SE1.E1_MSFIL = AUXFIF.FIF_CODFIL "
            cQry += " AND SE1.E1_EMISSAO = AUXFIF.FIF_DTTEF "

            If !__lProcDocTEF
				If __lOracle .or. __lPostGre
					cQry += " AND LPAD(TRIM(SE1.E1_NSUTEF), "+Alltrim(STR(nTamNSUTEF))+", '0') = LPAD(TRIM(AUXFIF.FIF_NSUTEF), "+Alltrim(STR(nTamNSUTEF))+", '0') "
				Else
					cQry += " AND REPLICATE('0', "+Alltrim(STR(nTamNSUTEF))+" - LEN(SE1.E1_NSUTEF)) + RTrim(SE1.E1_NSUTEF) = REPLICATE('0', "+Alltrim(STR(nTamNSUTEF))+" - LEN(AUXFIF.FIF_NSUTEF)) + RTrim(AUXFIF.FIF_NSUTEF) "
				Endif	
            Else
				If __lOracle .or. __lPostGre
					cQry += " AND CAST(SE1.E1_DOCTEF AS NUMBER) = CAST(AUXFIF.FIF_NUCOMP AS NUMBER) "
				Else
					cQry += " AND CAST(SE1.E1_DOCTEF AS BIGINT) = CAST(AUXFIF.FIF_NUCOMP AS BIGINT) "
				EndIf
            Endif

            cQry += " JOIN " + RetSqlName("MEP") + " MEP "
            cQry += " ON SE1.E1_FILIAL = MEP.MEP_FILIAL "
            cQry += " AND SE1.E1_PREFIXO = MEP.MEP_PREFIX "
            cQry += " AND SE1.E1_NUM = MEP.MEP_NUM "
            cQry += " AND SE1.E1_PARCELA = MEP.MEP_PARCEL "
            cQry += " AND SE1.E1_TIPO = MEP.MEP_TIPO "
            cQry += " AND SE1.E1_MSFIL = MEP.MEP_MSFIL "

            cQry += " WHERE "
            If !lExclusFif
                cQry += " AUXFIF.FIF_FILIAL = '' AND "
            EndIf
				
            If !lExclusivo
                cQry += " SE1.E1_FILIAL = '' AND "
            EndIf

            cQry += " SE1.E1_SALDO > 0 AND "
				
            If lExclusivo
                cQry += " SE1.E1_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND "
            Else
                cQry += " SE1.E1_MSFIL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND "
            EndIf
				
            cQry += " SE1.D_E_L_E_T_ = ' ' AND "
				
            If lExclusMEP
                cQry += " MEP.MEP_FILIAL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND "
                cQry += " MEP.MEP_FILIAL = AUXFIF.FIF_CODFIL AND "
            Else
                cQry += " MEP.MEP_FILIAL = '  ' AND "
            EndIf
				
            cQry += " AUXFIF.FIF_CODFIL BETWEEN '" + MV_PAR01 + "' AND '" + MV_PAR02 + "' AND "
            cQry += " AUXFIF.FIF_PARCEL = MEP.MEP_PARTEF AND "
            cQry += " AUXFIF.FIF_DTCRED BETWEEN '" + dTos(dDataCredI) + "' AND '" + dTos(dDataCredF) + "' AND "

            If !__lProcDocTEF
				If __lOracle .or. __lPostGre
					cQry += " LPAD(TRIM(AUXFIF.FIF_NSUTEF), "+Alltrim(STR(nTamNSUTEF))+", '0') BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' AND "
				Else
                	cQry += " REPLICATE('0', "+Alltrim(STR(nTamNSUTEF))+" - LEN(AUXFIF.FIF_NSUTEF)) + RTrim(AUXFIF.FIF_NSUTEF) BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' AND "
				Endif	
            ElseIf __lDocTef 
				If __lOracle .or. __lPostGre
					cQry += " LPAD(TRIM(AUXFIF.FIF_NUCOMP), "+Alltrim(STR(nTamDOCTEF))+", '0') BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' AND "
				Else
					cQry += " REPLICATE('0', "+Alltrim(STR(nTamDOCTEF))+" - LEN(AUXFIF.FIF_NUCOMP)) + RTrim(AUXFIF.FIF_NUCOMP) BETWEEN '" + cNsuDe + "' AND '" + cNsuAte + "' AND "
				Endif	
            Endif

            cQry += " AUXFIF.FIF_STATUS IN ('1','3','4','6') AND "
				
            If !Empty(cAdmFinanIni)
                cQry += " AUXFIF.FIF_CODRED >= '" + cAdmFinanIni + "' AND "
            EndIf
				
            If !Empty(cAdmFinanIni) .AND. !Empty(cAdmFinanFim)
                cQry += " AUXFIF.FIF_CODRED <= '" + cAdmFinanFim + "' AND "
            EndIf
				
            If MV_PAR08 == 1
                cQry += " AUXFIF.FIF_TPPROD IN ('D','V') AND "
            ElseiF	MV_PAR08 == 2
                cQry += " AUXFIF.FIF_TPPROD = 'C' AND "
            Else
                cQry += " AUXFIF.FIF_TPPROD IN ('D','V','C') AND "
            EndIf
			
            cQry += " MEP.D_E_L_E_T_ = ' ' AND "
            cQry += " AUXFIF.D_E_L_E_T_ = ' ' )"
            cQry += " AND SE1.D_E_L_E_T_ = ' ' "
                                         
            cQry += " ORDER BY SE1.E1_VALOR "
        EndIf

        cQry := ChangeQuery(cQry)
        dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQry),cAliasSitef,.F.,.T.)
			
        While !(cAliasSitef)->(Eof())
				
			//Verifica se o titulo retornado encontra-se na pasta de conciliados
			//Se existir, nao sera exibido na pasta de nao conciliados
            nNaoConc := If( TMP->(MSSeek(PadR('CONC',10)+STRZERO((cAliasSitef)->RECNOSE1,10))), 1, 0 )
				
			//Verifica se o titulo retornado encontra-se na pasta de conciliados
			//Se existir, nao sera exibido na pasta de conciliados parcialmente
            nNaoConcPa := If( TMP->(MSSeek(PadR('CONCPAR',10)+STRZERO((cAliasSitef)->RECNOSE1,10))), 1, 0 )
				
            If (nNaoConc + nNaoConcPa) = 0 //Se nao encontrar o item e Nao Conciliado
					
                aColsAux := {}

				If !Empty((cAliasSitef)->E1_NSUTEF)
					cNsuSe1 := PADR("", nTamNSUTEF - len(Alltrim((cAliasSitef)->E1_NSUTEF)),'0') + Alltrim((cAliasSitef)->E1_NSUTEF)
				Endif
				If !Empty((cAliasSitef)->E1_DOCTEF)
					cDocSE1 := PADR("", nTamDOCTEF - len(Alltrim((cAliasSitef)->E1_DOCTEF)),'0') + Alltrim((cAliasSitef)->E1_DOCTEF)
				Endif

                aAdd(aColsAux,LoadBitmap(GetResources(), "BR_BRANCO"))	//1-Status
                aAdd(aColsAux,StoD((cAliasSitef)->E1_EMISSAO))			//2-Emissao do Titulo
                aAdd(aColsAux,StoD((cAliasSitef)->E1_VENCREA))			//3-Vencimento real do titulo
                aAdd(aColsAux,(cAliasSitef)->E1_SALDO)					//4-Valor do titulo
                aAdd(aColsAux,RIGHT(cNsuSe1,12))						//5-Numero NSU Sitef
                aAdd(aColsAux,RIGHT(cDocSE1,12))						//6-Numero Documento Sitef
                aAdd(aColsAux,(cAliasSitef)->E1_PREFIXO)				//7-Prefixo do Titulo
                aAdd(aColsAux,(cAliasSitef)->E1_NUM)					//8-Numero do Titulo
                aAdd(aColsAux,(cAliasSitef)->E1_PARCELA)				//9-Parcela do titulo
                aAdd(aColsAux,(cAliasSitef)->E1_TIPO)					//10-Tipo do titulo
                aAdd(aColsAux,(cAliasSitef)->E1_CLIENTE)				//11-Cliente (Administradora)
                aAdd(aColsAux,(cAliasSitef)->MEP_PARTEF )           	//12 Parcela Sitef
					
					
                aAdd(aColsAux,(cAliasSitef)->E1_LOJA)				//13-Loja da venda
                aAdd(aColsAux,(cAliasSitef)->E1_MSFIL)				//14-Loja da venda
                aAdd(aColsAux,(cAliasSitef)->RECNOSE1)				//15-RECNO DO TITULO
                aAdd(aColsAux,(cAliasSitef)->E1_VALOR)				//16-vALOR DO TITULO
                aAdd(aColsAux,(cAliasSitef)->E1_FILORIG)	            //17-FILIAL DA SE1
					
                If Len(aColsAux) > 1
                    aAdd(aTitulos,aColsAux)
                EndIf
            EndIf
				
            (cAliasSitef)->(dbSkip())
        EndDo

        (cAliasSitef)->(dbCloseArea())
    EndIf
EndIf
	
//Atualiza objeto oTitulos com as informacoes encontradas na consulta
If Len(aTitulos) > 0
    oTitulos:SetArray(aTitulos)
    oTitulos:bLine := {||aEval(aTitulos[oTitulos:nAt],{|z,w| aTitulos[oTitulos:nAt,w]})}
    oTitulos:Refresh()
    lWhenConc := .T.
Else //Se nao encontrar titulos carrega array para evitar erro no objeto
    aAdd(aTitulos,{"",cTod("  /  /  "),cTod("  /  /  "),0,"","","","","","","","","","",0})
    oTitulos:SetArray(aTitulos)
    oTitulos:bLine := {||aEval(aTitulos[oTitulos:nAt],{|z,w| aTitulos[oTitulos:nAt,w]})}
    oTitulos:Refresh()
    lWhenConc := .F.
EndIf
	
Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910Efetiva
Funcao que é executada a partir do botao de efetivar conciliacao dos Folders 
Conciliadas, Conc. Parcialmente e Não Conciliadas, tendo como funcionalidade 
baixar os titulos do Contas a Receber e alterar o status do mesmo na tabela 
FIF 

@type Function
@author Unknown
@since 28/04/2011
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A910Efetiva( aDados, oObj, oRedSelec, oAmaSelec, aTitulos, aConcMan, oConcMan, aTotais, oTotais, nTpConc, oTitulos, o910Dlg )

Local cMensagem := ''	//Mensagem utilizada na funcao processa
	
If cConcilia == 2
    //Baixa por lote
	cMensagem := STR0093
Else
	//"Baixa de Títulos Individual..."
	cMensagem := STR0105
EndIf

ProcLogAtu("MENSAGEM","INI -> Efetivando registros")

Do Case
	//Efetivacao dos conciliados e conciliados parcial
	Case nTpConc == 1 .OR. nTpConc == 2
       ProcLogAtu(STR0138,STR0144)
		If __l910Auto 
			A910EfConc(aDados,oObj,o910Dlg,oRedSelec,oAmaSelec,aTotais,oTotais,nTpConc)
		Else
			Processa(	{|| A910EfConc(aDados,oObj,o910Dlg,oRedSelec,oAmaSelec,aTotais,oTotais,nTpConc)},;
						STR0092,cMensagem)				//"Aguarde..."	### "Preparando Dados para Baixa..."
		EndIf
	//Efetivação dos não conciliados (Manualmente)					
	Case nTpConc == 3
       ProcLogAtu(STR0138,STR0145)
		If __l910Auto 
			A910EfNaoConc(aDados,oObj,aTitulos,o910Dlg,aConcMan,oConcMan,oRedSelec,oTitulos,aTotais,oTotais)
		Else
			Processa(	{|| A910EfNaoConc(aDados,oObj,aTitulos,o910Dlg,aConcMan,oConcMan,oRedSelec,oTitulos,aTotais,oTotais)},;
					STR0092, cMensagem)				//"Aguarde..."	### "Preparando Dados para Baixa..."
		EndIf
EndCase

ProcLogAtu(STR0138,STR0146)

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910EfNaoConc
Funcao que é executada a partir do botao de efetivar conciliacao dos Folders 
Não Conciliadas, tendo como funcionalidade baixar os titulos do Contas a 
Receber e alterar o status do mesmo na tabela FIF 

@type Function
@author Unknown
@since 06/08/2009
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A910EfNaoConc( aNaoConc, oNaoConc, aTitulos, o910Dlg, aConcMan, oConcMan, oRedSelec, oTitulos, aTotais, oTotais )

Local nPos			:= 0		//Posicao do titulo selecionado
Local nCount		:= 0		//Contador utilizado para varrer o array da FIF
Local aLotes		:= {}		//Array com os lotes para baixa
Local lRet			:= .F.		//Retorno da função de baixa individual
Local cFilOri		:= cFilAnt  
Local aDadoBanco	:= {}		//Array com os dados de banco, agencia e conta
Local nLote			:= 0		//Posicao do lote no array
Local aTitInd		:= {}		//Dados do titulo individual  
	
//Verifica se algum item foi selecionado nos titulos
If (nPos := aScan(aTitulos,{|x| x[1]:cName == "BR_VERDE" })) == 0
	//"Nao ha' nenhum registro marcado"
	Help(" ",1,"A910NoSelec",,STR0051 ,1,0,,,,,,{STR0221})
	//"Selecione ao menos um registro para que seja conciliado"
	Return Nil
EndIf

ProcRegua(Len(aNaoConc))
	
DbSelectArea("SE1")
SE1->(DbSetOrder(1)) //E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	                                                                                   
For nCount := 1 To Len(aNaoConc)

	//Verifica se o item esta selecionado
	If AllTrim(oNaoConc:aArray[nCount][1]:cName) == "BR_VERDE"
		
		//Procura no array de titulos não conciliados o recno correspondente a FIF
		If (nPos := aScan(aTitulos,{|x| x[15] == oNaoConc:aArray[nCount][22] })) <> 0
			cFilAnt := aTitulos[nPos][17]
		
			//Verifica se existe o registro no SE1
			If !SE1->(dbSeek(xFilial("SE1")+aTitulos[nPos][7]+aTitulos[nPos][8]+aTitulos[nPos][9]+aTitulos[nPos][10]))
				//"Arquivo não encontrado no Financeiro"
				Help(" ",1,"A910NoSelec",,STR0050 ,1,0,,,,,,{STR0222})
				//Selecione um título valido no Financeiro
			Else
				//Lote - prepara os dados para baixa dos titulos em lote
				//Baixa Individual - prepara e ja executa a baixa do titulo.
				lRet := .F.

				//Busca banco / agencia / conta. Efetua atualização do SE1
				aDadoBanco := BuscarBanco(oNaoConc:aArray[nCount][26], oNaoConc:aArray[nCount][24],oNaoConc:aArray[nCount][25],oNaoConc:aArray[nCount][13])
					
				//Conciliacao por lote
				If cConcilia == 2
						
					//Verifica se ja existe um lote para este Banco, Agencia, Conta e Data do Credito
					If Len(aLotes) > 0 .AND. ;
						(nLote := AScan (aLotes, {|aX| aX[2] + aX[3] + aX[4] + DToS(aX[8]) == oNaoConc:aArray[nCount][26] + oNaoConc:aArray[nCount][24] + oNaoConc:aArray[nCount][25] + DToS(Iif (lUseFIFDtCred, oNaoConc:aArray[nCount][11],dDataBase))})) > 0
							
						//Adiciona ao lote o recno de mais um titulo SE1
						AADD(aLotes[nLote ][9], oNaoConc:aArray[nCount][22])
					Else
						//Busca o numero do lote
						cLote := BuscarLote()
							
						//Cria um lote com o titulo SE1
						AADD(	aLotes, {cLote, oNaoConc:aArray[nCount][26], oNaoConc:aArray[nCount][24], oNaoConc:aArray[nCount][25], aDadoBanco[1], aDadoBanco[2], ;
								aDadoBanco[3], Iif (lUseFIFDtCred, oNaoConc:aArray[nCount][11],dDataBase), {oNaoConc:aArray[nCount][22]}})
					EndIf
						
					lRet := .T.
				Else
					//Array com os dados do titulo para baixa individual
					aTitInd	:= {{"E1_PREFIXO"	,oNaoConc:aArray[nCount][5]	 	 																				,NiL},;
								{"E1_NUM"		,oNaoConc:aArray[nCount][6]			 																			,NiL},;
								{"E1_PARCELA"	,oNaoConc:aArray[nCount][8]	     																				,NiL},;
								{"E1_TIPO"		,oNaoConc:aArray[nCount][7]       	 																			,NiL},;
								{"E1_CLIENTE"	,oNaoConc:aArray[nCount][4]     																				,NiL},;
								{"E1_LOJA"		,oNaoConc:aArray[nCount][27]       	 																			,NiL},;
								{"AUTMOTBX"		,"NOR"					     			 																		,Nil},;
								{"AUTBANCO"		,(PadR(aDadoBanco[1],Len(SE8->E8_BANCO)))   																	,Nil},;
								{"AUTAGENCIA"	,(PadR(aDadoBanco[2],Len(SE8->E8_AGENCIA)))																		,Nil},;
								{"AUTCONTA"		,If(lPontoF,(PadR(aDadoBanco[3],Len(SE8->E8_CONTA))),(PadR(StrTran(aDadoBanco[3],"-",""),Len(SE8->E8_CONTA))))	,Nil},;
								{"AUTDTBAIXA"	,Iif (lUseFIFDtCred, oNaoConc:aArray[nCount][11],dDataBase)														,Nil},;
								{"AUTDTCREDITO"	,Iif (lUseFIFDtCred, oNaoConc:aArray[nCount][11],dDataBase)														,Nil},;
								{"AUTHIST"		,STR0110			           			 																		,Nil},; //"Conciliador SITEF"
								{"AUTDESCONT"	,0					    	 			 																		,Nil},; //Valores de desconto
								{"AUTACRESC"	,0					 	    			 																		,Nil},; //Valores de acrescimo - deve estar cadastrado no titulo previamente
								{"AUTDECRESC"	,0					 		 			 																		,Nil},; //Valore de decrescimo - deve estar cadastrado no titulo previamente
								{"AUTMULTA"		,0					 		 			 																		,Nil},; //Valores de multa
								{"AUTJUROS"		,0					 				 	 																		,Nil},; //Valores de Juros
								{"AUTVALREC"	,oNaoConc:aArray[nCount][13]   	 																				,Nil}}  //Valor recebido
												
					//Efetua baixa individual
					A910EfetuaBX (aTitInd, o910Dlg, , @lRet)
				EndIf

				//TRECHO NOVO EXPERIMENTAL
				cFilAnt := cFilOri
				
				If lRet
					//Atualiza Folder Conciliados Manualmente Dinamicamente
					A910AtuMan(@aConcMan, @oConcMan, aTitulos, aNaoConc, nPos, nCount, oRedSelec, @oNaoConc, @oTitulos)
						
					//Atualizo folder de totais dinamicamente
					aTotais[01][TOT_CNAO] := aTotais[01][TOT_CNAO] - aNaoConc[nCount][13]
					aTotais[01][TOT_CMAN] := aTotais[01][TOT_CMAN] + aNaoConc[nCount][13]
						
					If Len(aConcMan) > 0
							
						//Atualizacao do Objeto na Aba Nao Conciliados	
						If Empty(aConcMan[1][2])
							aDel(aConcMan,1)
							aSize(aConcMan,Len(aConcMan)-1)
							oConcMan:SetArray(aConcMan)
							oConcMan:bLine := {||aEval(aConcMan[oConcMan:nAt],{|z,w| aConcMan[oConcMan:nAt,w]})}
							oConcMan:Refresh()
						EndIf
							
						aTotais[01][TOT_QTDCMAN] := Len(aConcMan)
					EndIf
	
					aTotais[01][TOT_GERAL] := aTotais[01][TOT_CONC]+aTotais[01][TOT_CPAR]+aTotais[01][TOT_CNAO]+aTotais[01][TOT_CMAN]
					aTotais[01][TOT_GERAL] := Round(aTotais[01][TOT_GERAL],2)
					//Inserir AtuTot
					aNaoConc[nCount][1]:cName := "BR_VERMELHO"
				Else
					aNaoConc[nCount][1]:cName := "BR_AMARELO"
				EndIf
					
			EndIf
		Else
			//"Nao ha' nenhum registro marcado"
			Help(" ",1,"A910NoSelec",,STR0051 ,1,0,,,,,,{STR0221})
			//"Selecione ao menos um registro para que seja conciliado"
		EndIf
	EndIf
	If !__l910Auto			
		IncProc()
	EndIf
Next
If !__l910Auto	
	oNaoConc:Refresh()
EndIf	
	//Efetua a baixa por lote
If cConcilia == 2
	If __l910Auto
		A910EfetuaBX (aLotes, o910Dlg, aNaoConc, @lRet)
	Else
		Processa({|| A910EfetuaBX (aLotes, o910Dlg, aNaoConc, @lRet)},STR0106,STR0107) //"Aguarde..."#"Efetuando Baixa de Títulos Lote..."
	EndIf	

	If !lRet
		Aeval(aNaoConc, {|x| x[1]:cName := IIF(x[1]:cName == "BR_VERMELHO", "BR_AMARELO", x[1]:cName)})
	EndIf
Endif

If lRet
	If __l910Auto
		AtuTabFIF (aNaoConc)
	Else
		oNaoConc:Refresh()
		Processa({|| AtuTabFIF (aNaoConc)},STR0106,STR0108) //"Aguarde..."#"Atualizando Tabela FIF..."
		MsgInfo(STR0109) //"Baixa efetuada com sucesso!!!"
	EndIf
EndIf
	
Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910EfConc
Funcao que é executada a partir do botao de efetivar conciliacao dos Folders 
Conciliadas e Conc. Parcialmente, tendo como funcionalidade baixar os titulos
do Contas a Receber e alterar o status do mesmo na tabela FIF 

@type Function
@author Unknown
@since 06/08/2009
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A910EfConc( aConc, oConc, o910Dlg, oRedSelec, oAmaSelec, aTotais, oTotais, nTpConc )
Local nCount		:= 0	//Contador utilizado para varrer o array da FIF
Local aLotes		:= {}	//Array com os lotes para baixa
Local lRet			:= .F.	//Retorno de Execução da função de baixa individual
Local lMenorSitef	:= .F.	//Variavel para controlar a exibição de mensagem de valor menor sitef
Local lExist		:= .F.
Local aDadoBanco	:= {}	//Array com os dados de banco, agencia e conta
Local nLote			:= 0	//Posicao do lote no array
Local aTitInd		:= {}	//Dados do titulo individual

If Len(aConc) <= 1 .And. Empty(aConc[1][6])
	//"Não existem registros a conciliar"
	Help(" ",1,"A910NoConc",,STR0147 ,1,0,,,,,,{STR0221})
	//"Selecione ao menos um registro para que seja conciliado"
	Return Nil
EndIf
	
ProcRegua(Len(aConc))
	
DbSelectArea("SE1")
SE1->(DbSetOrder(1)) //E1_FILIAL + E1_PREFIXO + E1_NUM + E1_PARCELA + E1_TIPO
	
For nCount := 1 To Len(aConc)
    If cFilAnt<>aConc[nCount][28]
		cFilAnt := aConc[nCount][28]
	EndIf		
		//Verifica se o item esta selecionado
	If AllTrim(oConc:aArray[nCount][1]:cName) == "BR_VERDE"

		//Verifica se existe o registro no SE1
		If !SE1->(DbSeek(xFilial("SE1")+aConc[nCount][5]+aConc[nCount][6]+aConc[nCount][8]+aConc[nCount][7]))
			//"Arquivo não encontrado no Financeiro"
			Help(" ",1,"A910NoSelec",,STR0050 ,1,0,,,,,,{STR0222})
			//Selecione um título valido no Financeiro
		Else
			lExist := .T.
			//Tratamento Valor Sitef deve ser maior ou igual ao Valor no Financeiro
			If !(aConc[nCount][13] >= SE1->E1_SALDO - (SE1->E1_SALDO * (nMargem/100))) .and. nTpConc == 1
				lMenorSitef := .T.
				aConc[nCount][01] := oAmaSelec
				Loop
			Else
				//Lote - prepara os dados para baixa dos titulos em lote
				//Baixa Individual - prepara e ja executa a baixa do titulo.
				lRet := .F.
				
				//Busca banco / agencia / conta. Efetua atualização do SE1
				aDadoBanco := BuscarBanco(oConc:aArray[nCount][26], oConc:aArray[nCount][24],oConc:aArray[nCount][25],oConc:aArray[nCount][13])
				
				//Conciliacao por lote
				If cConcilia == 2
						
					//Verifica se ja existe um lote para este Banco, Agencia, Conta e Data do Credito
					If Len(aLotes) > 0 .AND. (nLote := AScan (aLotes, {|aX| aX[2] + aX[3] + aX[4] + DToS(aX[8]) == oConc:aArray[nCount][26] + oConc:aArray[nCount][24] + oConc:aArray[nCount][25] + DToS(Iif (lUseFIFDtCred, oConc:aArray[nCount][11],dDataBase))})) > 0
						//Adiciona ao lote o recno de mais um titulo SE1
						AADD(aLotes[nLote ][9], oConc:aArray[nCount][22])
					Else
						//Busca o numero do lote
						cLote := BuscarLote()

						//Cria um lote com o titulo SE1
						AADD(aLotes, {cLote, oConc:aArray[nCount][26], oConc:aArray[nCount][24], oConc:aArray[nCount][25], aDadoBanco[1], aDadoBanco[2], ;
										aDadoBanco[3], Iif (lUseFIFDtCred, oConc:aArray[nCount][11],dDataBase), {oConc:aArray[nCount][22]}})
					EndIf
						
					lRet := .T.
				Else
						
					//Array com os dados do titulo para baixa individual
					aTitInd	:=	{	{"E1_PREFIXO"			,oConc:aArray[nCount][5]	 	 							,NiL},;
										{"E1_NUM"			,oConc:aArray[nCount][6]			 						,NiL},;
										{"E1_PARCELA"		,oConc:aArray[nCount][8]	     							,NiL},;
										{"E1_TIPO"			,oConc:aArray[nCount][7]       	 							,NiL},;
										{"E1_CLIENTE"		,oConc:aArray[nCount][4]     								,NiL},;
										{"E1_LOJA"			,oConc:aArray[nCount][27]       	 						,NiL},;
										{"AUTMOTBX"			,"NOR"					     			 					,Nil},;
										{"AUTBANCO"			,(PadR(aDadoBanco[1],Len(SE8->E8_BANCO)))   				,Nil},;
										{"AUTAGENCIA"		,(PadR(aDadoBanco[2],Len(SE8->E8_AGENCIA)))					,Nil},;
										{"AUTCONTA"			,If(lPontoF,(PadR(aDadoBanco[3],Len(SE8->E8_CONTA))),(PadR(StrTran(aDadoBanco[3],"-",""),Len(SE8->E8_CONTA)))),Nil},;
										{"AUTDTBAIXA"		,Iif (lUseFIFDtCred, oConc:aArray[nCount][11],dDataBase)	,Nil},;
										{"AUTDTCREDITO"		,Iif (lUseFIFDtCred, oConc:aArray[nCount][11],dDataBase)	,Nil},;
										{"AUTHIST"			,STR0110			           			 					,Nil},; //"Conciliador SITEF"
										{"AUTDESCONT"		,0					    	 			 					,Nil},; //Valores de desconto
										{"AUTACRESC"		,0					 	    			 					,Nil},; //Valores de acrescimo - deve estar cadastrado no titulo previamente
										{"AUTDECRESC"		,0					 		 			 					,Nil},; //Valore de decrescimo - deve estar cadastrado no titulo previamente
										{"AUTMULTA"			,0					 		 			 					,Nil},; //Valores de multa
										{"AUTJUROS"			,0					 				 	 					,Nil},; //Valores de Juros
										{"AUTVALREC"		,oConc:aArray[nCount][13]   	 							,Nil}}  //Valor recebido
								
						//Efetua baixa individual
					A910EfetuaBX (aTitInd, o910Dlg, , @lRet)

					If !lRet //Erro na Baixa do Título
						aConc[nCount][1] := LoadBitmap(GetResources(), "BR_AMARELO") //"BR_AMARELO"
						Loop
					Else
						aConc[nCount][1] := LoadBitmap(GetResources(), "BR_VERMELHO") //"BR_VERMELHO"
					EndIf

				EndIf

				//Atualiza Folder Totais Dinamicamente
				aTotais[01][TOT_CONC]	:= aTotais[01][TOT_CONC] - aConc[nCount][13]
				aTotais[01][TOT_GERAL]	:= aTotais[01][TOT_CONC] + aTotais[01][TOT_CPAR]+aTotais[01][TOT_CNAO]+aTotais[01][TOT_CMAN]
				aTotais[01][TOT_GERAL]	:= Round(aTotais[01][TOT_GERAL],2)
			EndIf
		EndIf
	EndIf
	If !__l910Auto		
		IncProc()
	EndIf
Next

//Verifica se algum item foi selecionado
If !lExist
	//"Nao ha' nenhum registro marcado"
	Help(" ",1,"A910NoSelec",,STR0051 ,1,0,,,,,,{STR0221})
	//"Selecione ao menos um registro para que seja conciliado"
	Return Nil
EndIf
	
If lMenorSitef .And. __lConoutR
	ConoutR(STR0052)		//"Valor Sitef menor que o Valor Protheus, necessário corrigir no Financeiro"
EndIf

oConc:Refresh()
	
//Atualizacao do Objeto na Aba Totais
oTotais:SetArray(aTotais)
oTotais:bLine := {||aEval(aTotais[oTotais:nAt],{|z,w| aTotais[oTotais:nAt,w]})}
oTotais:Refresh()

//Efetua a baixa por lote
If cConcilia == 2
    ProcLogAtu(STR0138,STR0148)
    If __l910Auto
		A910EfetuaBX(aLotes, o910Dlg, aConc, @lRet)
	Else
		Processa({|| A910EfetuaBX(aLotes, o910Dlg, aConc, @lRet)},STR0106,STR0107) //"Aguarde..."#"Efetuando Baixa de Títulos Lote..."
    EndIf
    ProcLogAtu(STR0138,STR0151)
	
	If lRet
		Aeval(aConc, {|x| x[1]:cName := IIF(x[1]:cName == "BR_VERDE", "BR_VERMELHO", x[1]:cName)})
	Else
		Aeval(aConc, {|x| x[1]:cName := IIF(x[1]:cName == "BR_VERDE", "BR_AMARELO", x[1]:cName)})
	EndIf	

Endif

If __l910Auto
	AtuTabFIF (aConc)
Else 
	If lRet
		oConc:Refresh()
		Processa({|| AtuTabFIF (aConc)},STR0106,STR0108) //"Aguarde..."#"Atualizando Tabela FIF..."   
		MsgInfo(STR0109) //"Baixa efetuada com sucesso!!!"
	Else
		MsgInfo(STR0191) //"Houve titulos não conciliados. Favor verificar"
	EndIf
EndIf
	
Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} BuscarBanco
Busca os dados de banco, agencia e conta (Ponto de entrada), se nao existir, 
matem os parametros que foram passados para a função.                                                     
Atualiza informacoes do SE1                                 

@type Function
@author Unknown
@since 06/08/2009
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function BuscarBanco(cBancoFIF,cAgFIF,cContaFIF,nVlLiqFIF)
Local aDados	:= {}				//Dados do retorno banco/agencia/conta
Local aArea		:= GetArea()		//Salva area local
Local aAliasSE1	:= SE1->(GetArea()) //Salva area SE1
Local aAliasFIF	:= FIF->(GetArea()) //Salva area FIF
Local nACRESC	:= 0
Local nDECRESC	:= 0

If !lPontoF
	aDados := {cBancoFIF, cAgFIF, cContaFIF}
Else
	aDados := ExecBlock('FINA910F', .F., .F., {cBancoFIF, cAgFIF, cContaFIF})
	
	If !(ValType(aDados) == 'A' .AND. Len(aDados) == 3)
		aDados := {cBancoFIF, cAgFIF, cContaFIF}
	EndIf
EndIf

If nVlLiqFIF > SE1->E1_SALDO
	nACRESC 	:= nVlLiqFIF - SE1->E1_SALDO
EndIf

If nVlLiqFIF < SE1->E1_SALDO
	nDECRESC := (nVlLiqFIF - SE1->E1_SALDO) * (-1)
EndIf

RecLock("SE1",.F.)
		
SE1->E1_PORTADO	:= aDados[1]
SE1->E1_AGEDEP	:= aDados[2]
SE1->E1_CONTA	:= aDados[3]
	
If nAcresc <> 0
	SE1->E1_ACRESC	:= nAcresc
	SE1->E1_SDACRES	:= nAcresc
EndIf
	
If nDECRESC <> 0
	SE1->E1_DECRESC	:= nDECRESC
	SE1->E1_SDDECRE	:= nDECRESC
EndIf
	
SE1->(MsUnlock())

//Restaura areas
RestArea(aAliasSE1)
RestArea(aAliasFIF)
RestArea(aArea)

Return aDados

//---------------------------------------------------------------------------
/*/{Protheus.doc} BuscarLote
Busca o numero do proximo lote para baixa dos titulos

@type Function
@author Unknown
@since 28/04/2011
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function BuscarLote()
Local aArea		:= GetArea()		//Salva area local
Local aOrdSE5 	:= SE5->(GetArea())	//Salva area SE5
Local cLoteFin	:= ''				//Numero do lote
	
cLoteFin := GetSxENum("SE5","E5_LOTE","E5_LOTE"+cEmpAnt,5)
	
DbSelectArea("SE5")
DbSetOrder(5)
	
While SE5->(MsSeek(xFilial("SE5")+cLoteFin))
	If (__lSx8)
		ConfirmSX8()
	EndIf
		
	cLoteFin := GetSxENum("SE5","E5_LOTE","E5_LOTE"+cEmpAnt,5)
EndDo
	
ConfirmSX8()
	
//Restaura areas
RestArea(aArea)
RestArea(aOrdSE5)
	
Return cLoteFin

//---------------------------------------------------------------------------
/*/{Protheus.doc} AtuTabFIF
Atualiza os dados da FIF apos a baixa dos titulos

@type Function
@author Unknown
@since 28/04/2011
@version 12   
/*/
//---------------------------------------------------------------------------
Function AtuTabFIF(aRegConc As Array)

Local nCount	As Numeric //Utilizada para ler todos os registros baixados
Local aArea		As Array   //Salva area local
Local aAliasFIF	As Array   //Salva area FIF

nCount		:= 0				//Utilizada para ler todos os registros baixados
aArea		:= GetArea()		//Salva area local
aAliasFIF	:= FIF->(GetArea()) //Salva area FIF

If !__l910Auto	
	ProcRegua(Len(aRegConc))
	IncProc(STR0108) //"Atualizando tabela FIF..."
EndIf

DbSelectArea("FIF")
DbSetOrder(5)
	
For nCount := 1 To Len(aRegConc)

	//Os registros que estiverem marcados como vermelho, são aqueles que foram conciliados e baixados
	If AllTrim(aRegConc[nCount][1]:cName) == "BR_VERMELHO"

		If !Empty(aRegConc[nCount][23])
			FIF->( dbGoTo(aRegConc[nCount][23]) ) // Faz a busca pelo FIF.R_E_C_N_O_
			If FIF->( !Eof() ) .And. FIF->( Recno() ) == aRegConc[nCount][23] .and. !FIF->FIF_STATUS $ ('7/2')
				If !__l910Auto	
					IncProc()
				EndIf
				RecLock("FIF",.F.)
				FIF->FIF_STATUS := IIf( FIF->FIF_STATUS == '6', '7', '2' )	//'2' - Conciliado / '7' - Antecipado
				FIF->FIF_PREFIX := aRegConc[nCount][5]						//Rastro Prefixo SE1
				FIF->FIF_NUM    := aRegConc[nCount][6]						//Rastro Num SE1
				FIF->FIF_PARC   := aRegConc[nCount][8]						//Rastro Parcela SE1
				FIF->FIF_TIPO   := aRegConc[nCount][7]						//Rastro Tipo SE1
							
				If lFifRecSE1
					FIF->FIF_RECSE1 := aRegConc[nCount][22]    //Rastro Recno SE1
				EndIf
				FIF->(MsUnlock())
			EndIf
		EndIf
	EndIf
	
	If !__l910Auto	
		IncProc()
	Endif
		
Next nCount

//Restaura areas
RestArea(aAliasFIF)
RestArea(aArea)
	
Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910SelReg
Funcao usada para atualizar a selecao do registro que esta posicionado ou de 
todos do array ou ordenar os registros  

@type Function
@author Rafael Rosa da Silva
@since 08/06/2009
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A910SelReg( aDados, oObj, oSelec, oNSelec, nColPos, nPos, lCheck, aNaoConc, nPosNConc, oNaoConc, oBlcSelec )

Local nI		:= 0	//Variavel contadora
Local lLockReg  := .F.  
Default nPos	:= 0
Default nColPos	:= 1
Default lCheck	:= .T.
	
oSelec		:= LoadBitmap(GetResources(), "BR_VERDE")	//Objeto de tela para mostrar como marcado um registro
oNSelec		:= LoadBitmap(GetResources(), "BR_BRANCO")	//Objeto de tela para mostrar como desmarcado um registro
oBlcSelec	:= LoadBitmap(GetResources(), "BR_PRETO")	//Objeto de tela para mostrar como desmarcado um registro

//Itens baixados
If nPos <> 0 .And. ValType(nPosNConc) <> "U"
	If Alltrim(oObj:aArray[nPos][5]) <> Alltrim(aNaoConc[nPosNConc][14]) .And. MV_PAR14 == 1
		MsgStop(STR0116)			//"NSU e Nº Comprovante selecionados estão divergentes"
		Return()
	ElseIf aNaoConc[nPosNConc][1]:cName == "BR_PRETO"
		MsgStop(STR0132)
		Return()
	Endif

	If Alltrim(oObj:aArray[nPos][1]:cName) == "BR_VERMELHO"
		Return()
	Else
		If !Empty(aNaoConc)
			If (Alltrim(oObj:aArray[nPos][1]:cName) == "BR_BRANCO" .AND. (aNaoConc[nPosNConc][1]:cname == "BR_VERDE" .OR. ;
					aNaoConc[nPosNConc][1]:cname == "BR_VERMELHO"))
				Return()
			EndIf
		EndIf
	EndIf
EndIf
	
If nColPos == 1 .AND. lCheck //Atualiza selecao do registro posicionado
	If nPos > 0
		If Alltrim(oObj:aArray[nPos][1]:cName) == "BR_BRANCO"
			If Empty(aNaoConc)
				If aDados[nPos][20] = STR0104 //"OK"
					SE1->(DbGoto(oObj:aArray[nPos][22]))
					If SE1->(MsRLock()) .and. SE1->E1_SALDO > 0 
						oObj:aArray[nPos][1] := oSelec
					Else 
						//Registro bloqueado em outra operação de conciliação
						Help(" ",1,"A910RegInUse",,STR0226 ,1,0,,,,,,{STR0228})
						//Aguarde a finalização do processo de conciliação feito por outro usuário.
					Endif 
				Else
					MsgStop(STR0101)			//"Este registro não pode ser selecionado, pois não existe a conta cadastrada."
					Return()
				EndIf
			Else
				If aNaoConc[nPosNConc][20] = STR0104 //"OK"
					oObj:aArray[nPos][1]:cName := "BR_VERDE"
				Else
					MsgStop(STR0101) 			//"Este registro não pode ser selecionado, pois não existe a conta cadastrada."
					Return()
				EndIf
			EndIf
		ElseIf Alltrim(oObj:aArray[nPos][1]:cName) == "BR_PRETO"
			MsgStop(STR0133)			//"Este registro não pode ser selecionado, pois não existe a conta cadastrada."
			Return()
		ElseIf Alltrim(oObj:aArray[nPos][1]:cName) == "BR_VERMELHO"
			MsgStop(STR0134)
			Return()
		ElseIf Alltrim(oObj:aArray[nPos][1]:cName) == "BR_AMARELO"
			MsgStop(STR0052)
			Return()
		Else
			If Empty(aNaoConc)
				//aDados[nPos][1] := oNSelec
				oObj:aArray[nPos][1] := oNSelec
				SE1->(DbGoto(oObj:aArray[nPos][22]))
				SE1->(MsUnlock())
			Else
				//Desmarca selecao dos nao conciliados
				//Verifica se o registro selecionado da FIF eh o mesmo do momento da selecao.
				If oNaoConc:aArray[nPosNConc][22] <> oObj:aArray[nPos][15] .and. (MV_PAR14 == 1) .OR. oNaoConc:aArray[nPosNConc][1]:cName <> "BR_VERDE" .and. (MV_PAR14 == 1)
					MsgStop(STR0113)  //"Não é possível desfazer a seleção, porque o registro selecionado da FIF não corresponde ao da SE1."
					Return()
				Else
					oObj:aArray[nPos][1] := oNSelec
				EndIf
					
			EndIf
		EndIf
	Else
		If Len(aDados) == 1
			MsgStop(STR0102)					//"Não existe registro para selecionar"
			Return()
		EndIf
		For nI := 1 to Len(aDados)
			If Alltrim(oObj:aArray[nI][1]:cName) <> "BR_VERMELHO"
				If Alltrim(oObj:aArray[nI][1]:cName) == "BR_BRANCO"
					SE1->(DbGoto(oObj:aArray[nI][22]))	
					If SE1->(MsRLock())	.AND. SE1->E1_SALDO > 0 
						//aDados[nI][1] := oSelec
						oObj:aArray[nI][1] := oSelec
					Else 
						lLockReg := .T. 		
					EndIf
				ElseIf Alltrim(oObj:aArray[nI][1]:cName) == "BR_PRETO"
					oObj:aArray[nI][1] := oBlcSelec
				Else
					//aDados[nI][1] := oNSelec
					oObj:aArray[nI][1] := oNSelec
					SE1->(DbGoto(oObj:aArray[nI][22]))
					SE1->(MsUnlock())
				EndIf
			EndIf
		Next nI
		If lLockReg
			//Um ou mais registros esta(ão) bloqueado(s) em outra operação de conciliação
			Help(" ",1,"A910RegInUse",,STR0227,1,0,,,,,,{STR0228})
			//Aguarde a finalização do processo de conciliação feito por outro usuário.
		EndIf

		EndIf
Else //Ordena registros
	aDados := aSort(aDados,,,{|x,y| x[nColPos] <= y[nColPos] })
EndIf
	
	//Atualiza Objeto oNaoConc
If (ValType(aNaoConc) <> "U" .AND. Len(aNaoConc) > 0)
	If Alltrim(oObj:aArray[nPos][1]:cName) == "BR_BRANCO"
		oNaoConc:aArray[nPosNConc][1] := oNSelec
		
		SE1->(DbGoto(oNaoConc:aArray[nPosNConc][22]))
		SE1->(MsUnlock())
		//Limpa os dados quando registro for desmarcado
		oNaoConc:aArray[nPosNConc][22] 	:= 0 							//recno SE1
		oNaoConc:aArray[nPosNConc][5] 	:= ""							//prefixo SE1
		oNaoConc:aArray[nPosNConc][7] 	:= ""							//tipo SE1
		oNaoConc:aArray[nPosNConc][8] 	:= ""							//parcela SE1
		oNaoConc:aArray[nPosNConc][6] 	:= ""							//num SE1
		oNaoConc:aArray[nPosNConc][27] 	:= ""							//loja SE1
	ElseIf Alltrim(oObj:aArray[nPos][1]:cName) == "BR_PRETO"
		oNaoConc:aArray[nPosNConc][1] := oBlcSelec
	Else
		SE1->(DbGoto(oObj:aArray[nPos][15]))
		If SE1->(MsRLock())	
			oNaoConc:aArray[nPosNConc][1]:cName := "BR_VERDE"

			//Atribui os valores do se1 no array da fif
			oNaoConc:aArray[nPosNConc][22] 	:= oObj:aArray[nPos][15]		//recno se1
			oNaoConc:aArray[nPosNConc][5] 	:= oObj:aArray[nPos][7]		//prefixo se1
			oNaoConc:aArray[nPosNConc][7] 	:= oObj:aArray[nPos][10]		//tipo se1
			oNaoConc:aArray[nPosNConc][8] 	:= oObj:aArray[nPos][9]		//parcela se1
			oNaoConc:aArray[nPosNConc][6] 	:= oObj:aArray[nPos][8]		//num se1
			oNaoConc:aArray[nPosNConc][27] 	:= oObj:aArray[nPos][12]		//loja se1
		Else 
			//Registro bloqueado em outra operação de conciliação
			Help(" ",1,"A910RegInUse",,STR0226 ,1,0,,,,,,{STR0228})
			//Aguarde a finalização do processo de conciliação feito por outro usuário.
			oObj:aArray[nPos][1]:cName := "BR_BRANCO"
		EndIf 
	EndIf

	oNaoConc:Refresh()
EndIf
	
oObj:Refresh()
	
Return

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} FA910RES
Função responsável por manter o layout da janela, indepedentemente da resolução
horizontal de tela onde o client está sendo executado

@type Function
@author Norbert, Ernani e Mansano
@since 10/05/2005
@version 12
/*/
//-------------------------------------------------------------------------------------
Static Function FA910ARES( nTam )

Local nHRes := 0 
If !__l910Auto
	nHRes := oMainWnd:nClientWidth // Resolucao horizontal do monitor
EndIf 	
If nHRes == 640	// Resolucao 640x480 (soh o Ocean e o Classic aceitam 640)
	nTam *= 0.8
ElseIf (nHRes == 798) .OR. (nHRes == 800)		// Resolucao 800x600
	nTam *= 1
Else	// Resolucao 1024x768 e acima
	nTam *= 1.28
EndIf

Return Int(nTam)

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910AtuDiv
Localiza as divergencias em Conciliados Parcialmente para exibir no Rodape                                        

@type Function
@author Alessandro Santos
@since 17/11/2009
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A910AtuDiv( aConcPar, aIndic, oConcPar, oIndic )

Local nPos	:= oConcPar	//Posicao Titulo Conciliado Parcialmente
Local aAux	:= {}		//Array auxiliar
Local nI	:= 0		//Variavel para contador
	
//Verifica se arrays nao estao vazios
If aConcPar[1][14] <> ""
		
	//Compara item do Rodape com itens Sitef Conciliados Parcialmente para encontrar referencia
	For nI := 1 To Len(aIndic)
		If (aIndic[nI][9] == aConcPar[nPos][5] .AND. aIndic[nI][10] == aConcPar[nPos][6];
			.AND. aIndic[nI][11] == aConcPar[nPos][7] .AND. aIndic[nI][7] == aConcPar[nPos][8];
			.AND. aIndic[nI][8] == aConcPar[nPos][15])
			
			aAdd(aAux,aIndic[nI])
		EndIf
	Next nI
		
		//Atualiza Objeto oIndic
	If Len(aAux) > 0
		oIndic:SetArray(aAux)
		oIndic:bLine := {||aEval(aAux[oIndic:nAt],{|z,w| aAux[oIndic:nAt,w]})}
		oIndic:Refresh()
	EndIf
		
EndIf

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910AtuMan
Atualizacao Dinamica da Aba Conciliados Manualmente apos a Conciliacao de 
item Nao Conciliado                                                               

@type Function
@author Alessandro Santos
@since 11/12/2009
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A910AtuMan( aConcMan, oConcMan, aTitulos, aDados, nPos, nPosCol, oRedSelec, oObj, oTitulos )

Local aArea		:= GetArea()		//Salva area atual
Local aAliasSE1	:= SE1->(GetArea())	//Salva area SE1
Local aAliasFIF	:= FIF->(GetArea())	//Salva area FIF
Local aColsAux	:= {}				//Array auxiliar na montagem do Array Conciliados manualmente
	
//Posiciona Titulo baixado no SE1
dbSelectArea("SE1")
SE1->(dbSetOrder(1))
SE1->(dbSeek(xFilial("SE1")+aTitulos[nPos][7]+aTitulos[nPos][8]+aTitulos[nPos][9]+aTitulos[nPos][10]))
	
//Posiciona arquivo SITEF Conciliado
dbSelectArea("FIF")
FIF->(dbSetOrder(5))
FIF->(dbSeek(xFilial("FIF")+DtoS(aDados[nPosCol][10])+aDados[nPosCol][14]+aDados[nPosCol][15]))
	
//Atualizacao do Array Conciliados Manualmente
aAdd(aColsAux,"")					//Status
aAdd(aColsAux, aDados[nPosCol][2])	//Codigo do Estabelecimento Sitef
aAdd(aColsAux, aDados[nPosCol][3])	//Codigo da Loja Sitef
aAdd(aColsAux, aDados[nPosCol][4])	//Codigo do Cliente (Administradora)
aAdd(aColsAux, aTitulos[nPos][7])	//Prefixo do titulo Protheus
aAdd(aColsAux, aTitulos[nPos][8])	//Numero do titulo Protheus
aAdd(aColsAux, aTitulos[nPos][10])	//Tipo do titulo Protheus
aAdd(aColsAux, aTitulos[nPos][9])	//Numero da parcela Protheus
aAdd(aColsAux, aDados[nPosCol][9])	//Numero do Comprovante Sitef
aAdd(aColsAux, aDados[nPosCol][10])	//Data da Venda Sitef
aAdd(aColsAux, aDados[nPosCol][11])	//Data de Credito Sitef
aAdd(aColsAux, aDados[nPosCol][12])	//Valor do titulo Protheus
aAdd(aColsAux, aDados[nPosCol][13])	//Valor liquido Sitef
aAdd(aColsAux, aDados[nPosCol][14])	//Numero NSU Sitef
aAdd(aColsAux, aDados[nPosCol][15])	//Numero da parcela Sitef
aAdd(aColsAux, aDados[nPosCol][16])	//Documento TEF Protheus
aAdd(aColsAux, aDados[nPosCol][17])	//NSU Sitef Protheus
aAdd(aColsAux, aDados[nPosCol][18])	//Vencimento real do titulo
aAdd(aColsAux, aDados[nPosCol][19])	//Banco/Agencia/Conta
aAdd(aColsAux, aDados[nPosCol][20])	//Status
aAdd(aColsAux, aDados[nPosCol][21])	//Origem
	
aAdd(aConcMan,aColsAux)
	
//Atualizacao do Objeto na Aba Conciliados Manualmente
oConcMan:SetArray(aConcMan)
oConcMan:bLine := {||aEval(aConcMan[oConcMan:nAt],{|z,w| aConcMan[oConcMan:nAt,w]})}
oConcMan:Refresh()
	
//Atualizacao do Objeto na Aba Nao Conciliados (Rodape)
aDel(aTitulos,nPos)
aSize(aTitulos,Len(aTitulos)-1)
oTitulos:SetArray(aTitulos)
oTitulos:bLine := {||aEval(aTitulos[oTitulos:nAt],{|z,w| aTitulos[oTitulos:nAt,w]})}
oTitulos:Refresh()
	
//Restaura Areas
RestArea(aAliasSE1)
RestArea(aAliasFIF)
RestArea(aArea)
	
Return(.T.)

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910Browse
Tela com o browse dos lotes para selecionar quais lotes serao selecionados 
para o processo manual                       

@type Function
@author Unknown
@since 06/01/2011
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A910Browse( aBrowse )

Local nX := 0	//Variavel Contadora
Local aX := {}	//Array de Retorno
	
Default aBrowse := {}
	
For nX := 1 To Len( aBrowse )
	aAdd( aX, aBrowse[nX] )
Next

Return aX

//---------------------------------------------------------------------------
/*/{Protheus.doc} CreateTMP
Cria tabela temporaria para armazenar registro conciliados, não conciliadas 
evitando ascan em array                    

@type Function
@author Unknown
@since 07/08/2013
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function CreateTMP( aCampos, cAliasSitef, aChave )

Local aSaveArea	:= GetArea()

If Select(cAliasSitef) > 0
	A910CLOSEAREA(cAliasSitef)
EndIf

//Cria tabela temporária no banco de dados 
_oFINA910A := FwTemporaryTable():New(cAliasSitef)
_oFINA910A:SetFields(aCampos)
_oFINA910A:AddIndex("1", aChave)
_oFINA910A:Create()

RestArea( aSaveArea )

Return nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910CLOSEAREA
Fechamento da tabela temporaria                    

@type Function
@author Unknown
@since 07/08/2013
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A910CLOSEAREA( cAliasSitef )

If Select(cAliasSitef) > 0 
	(cAliasSitef)->(DbCloseArea())
Endif

//Deleta a tabela temporária no banco, caso já exista
If(_oFINA910A <> NIL)
	_oFINA910A:Delete()
	_oFINA910A := NIL
EndIf

Return Nil

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910VLDBCO
Validação do banco               

@type Function
@author Pedro Pereira Lima
@since 07/08/2013
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A910VLDBCO( cBanco, cAgencia, cConta )
                                                   
Local lRet		:= .T.
Local nSubBco	:= IIf(Len(cBanco)   - nTamBanco   <= 0, 1, (Len(cBanco)   - nTamBanco  ) + 1)
Local nSubAge	:= IIf(Len(cAgencia) - nTamAgencia <= 0, 1, (Len(cAgencia) - nTamAgencia) + 1)
Local nSubCC	:= IIf(Len(cConta)   - nTamCC      <= 0, 1, (Len(cConta)   - nTamCC     ) + 1)
Local nPos		:= 0

If __cFilSA6 == Nil
	__cFilSA6	:= xFilial( 'SA6' )
Endif

cBanco		:= padr(SubStr(cBanco,nSubBco,nTamBanco),nTamBanco)
cAgencia	:= padr(SubStr(cAgencia,nSubAge,nTamAgencia),nTamAgencia)
cConta		:= padr(SubStr(cConta,nSubCC,nTamCC),nTamCC)

nPos := Ascan( __aBancos, {|x| x[1] == __cFilSA6 .And. x[2] == cBanco .And. x[3] == cAgencia .And. x[5] == cConta } )
lRet := ( nPos > 0 ) 

If lRet
	If __aBancos[nPos,7] == '1'
		lRet := .F.
	ElseIf !Empty( __aBancos[nPos,8] ) .And. __aBancos[nPos,8] == '1'
		lRet := .F.
	Endif 
Endif

Return lRet

//---------------------------------------------------------------------------
/*/{Protheus.doc} GenRandThread
Controle de numeração das threads               

@type Function
@author Pedro Pereira Lima
@since 30/10/2013
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function GenRandThread()

Local nThreadId := nRandThread

While nRandThread == nThreadId .Or. nRandThread == 0
	nRandThread := Randomize(10000,29999)
EndDo

nThreadId := nRandThread

Return nThreadId

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910aIniVar
Inicia as variaveis staticas utilizadas no fonte               

@type Function
@author Unknown
@since 21/01/2014
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A910aIniVar()
 
If __nThreads == Nil .or. __l910Auto
	__nThreads	:= SuperGetMv( "MV_BLATHD" , .T. , 1 )	// Limite de 20 Threads permitidas
EndIf

If __nLoteThr == Nil .or. __l910Auto
	__nLoteThr	:= SuperGetMv( "MV_BLALOT" , .T. , 50 )	// Quantidade de registros por lote
Endif

__nThreads := If( (__nThreads > 20) , 20 , __nThreads )

If __lProcDocTEF == Nil
    __lProcDocTEF  := SuperGetMv( "MV_BLADOC" , .T. , .F. ) // Verifica se irá processar pelo DOCTEF ou pelo NSUTEF. Padrão é pelo NSUTEF
Endif

If nTamBanco == Nil
	nTamBanco		:= TAMSX3("A6_COD")[1]
Endif

If nTamAgencia == Nil 
	nTamAgencia	:= TamSX3("A6_AGENCIA")[1]
Endif

If nTamCC == Nil
	nTamCC		:= TAMSX3("A6_NUMCON")[1]
Endif

If nTamCheque == Nil
	nTamCheque		:= TAMSX3("EF_NUM")[1]
Endif

If nTamNatureza == Nil
	nTamNatureza	:= TAMSX3("ED_CODIGO")[1]
Endif

If lMEP == Nil 
	lMEP		:= AliasInDic("MEP")
Endif

If nTamParc == Nil
	nTamParc		:= TamSX3("FIF_PARCEL")[1]
Endif

If nTamParc2 == Nil
	nTamParc2		:= TamSX3("FIF_PARALF")[1]
Endif

If lTamParc == Nil
	lTamParc	:= TamSX3("E1_PARCELA")[1] == TamSX3("FIF_PARCEL")[1]
Endif

If lA6MSBLQL == Nil
	lA6MSBLQL := ( SA6->(FieldPos( 'A6_MSBLQL') ) > 0 )
Endif

If lFifRecSE1 == Nil
    lFifRecSE1 := ( FIF->(FieldPos( 'FIF_RECSE1' ) ) > 0 )
Endif

If nTamNSUTEF == Nil 
    nTamNSUTEF := TamSX3("FIF_NSUTEF")[1]
Endif

If nTamDOCTEF == Nil .And. __lDocTef 
    nTamDOCTEF := TamSX3("FIF_NUCOMP")[1]
Endif

ProcLogAtu(STR0138,STR0152)

// Efetua a carga dos bancos
LoadBanco()

ProcLogAtu(STR0138,STR0153)

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910EfetuaBX
Efetua a baixa do titulo por lote ou individual               

@type Function
@author Unknown
@since 29/04/2011
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A910EfetuaBX( aLotes, o910Dlg, aRegConc, lRet )

Local aTitulosBx	:= {}
Local lMsErroAuto
Local nCount		:= 0									//Contador utilizado para varrer o array da FIF
Local nConcAux		:= 0 
Local nIx 			:= 0 
Local aConcAux 		:= {}
Default lRet		:= .F.

If cConcilia == 2 //Baixa por lote

	If __nThreads > 1
		lRet := A910ThrLote( aLotes, aRegConc, o910Dlg)
	Else
		
		For nCount := 1 To Len( aLotes )
				
			aTitulosBX := aLotes[nCount][9]
			If !__l910Auto
				IncProc(STR0106 + ", " + STR0111 + aLotes[nCount][1] + STR0112 + AllTrim( Str( Len( aTitulosBX ) ) ) + ")") //"Aguarde..."#(Lote: "#" / Qtde Títulos: "
			EndIf

			If FBxLotAut("SE1", aTitulosBX, aLotes[nCount][5], aLotes[nCount][6], aLotes[nCount][7],,aLotes[nCount][1],, aLotes[nCount][8])
				lRet := .T.
				aConcAux := oConc:aArray
				For nIx := 1 To Len(aTitulosBX)
					nConcAux := aScan(aConcAux, {|x| x[22] = aTitulosBX[nIx] })
					If nConcAux > 0
						oConc:aArray[nConcAux][1]:cName := "BR_VERMELHO" 
					Endif
				Next nIx
			Else 
				 //"Inconsistencia encontradas no processo de Baixas por Lote. esta interface será encerrada para garantir a integridade dos dados na situação de baixa por lote."###"Operação Cancelada"
				Help(" ",1,"A910Incosit",,STR0056 ,1,0,,,,,,{STR0057})
				Exit
			EndIf
		Next nCount			
	EndIf
	
Else  
	//Baixa individual
	lMsErroAuto	:= .F.
	aTitulosBX := aLotes
	
	MSExecAuto({|x, y| FINA070(x, y)}, aTitulosBX, 3)
	
	//Verifica se ExecAuto deu erro
	lRet := !lMsErroAuto

	If !lRet
		If !__l910Auto
			MostraErro()
		EndIf
		DisarmTransaction()
	EndIf
EndIf

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910ThrLote
Efetua o controle das threads da conciliação               

@type Function
@author Unknown
@since 21/01/2014
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A910ThrLote( aLotes, aRegConc, o910Dlg)

Local oModelBxR
Local oSubFKA
Local oSubFK5
Local aTitulosBX	:= {}
Local lOk			:= .T.
Local lFa110Tot		:= ExistBlock( 'FA110TOT' )
Local nIx			:= 0
Local nJx			:= 0 
Local lBxCnab		:= GetMv('MV_BXCNAB') == 'S'
Local cLog			:= ''
Local cCamposE5		:= ''
Local cBco110		:= '' 
Local cAge110		:= ''
Local cCta110		:= ''
Local cLoteFin		:= ''
Local cCheque		:= ''
Local cNatureza     := Nil
Local lBaixaVenc    := lUseFIFDtCred	//se deve gravar a data de credito na E1_BAIXA
Local cNatLote		:= FINNATMOV( 'R' )
Local cMyUId		:= 'F910_THREAD_ID' //Definição do nome da seção para controle de variáveis "globais"
Local cKeyId		:= 'F910_KEY_'		//Definição da chave para controle de variáveis "globais"
Local aValor		:= {}				//Array que armazenará os valores "globais"
Local aRet			:= {}
Local aRetAux		:= {}
Local nX			:= 0
Local nY			:= 0
Local lSpbInUse 	:= SpbInUse()
Local aRecnosAux	:= {}
Local aLoteAux		:= {}
Local nConcAux		:= 0
Local aConcAux		:= {}
Local aGrvTxt		:= {}
Local lGrvTxt		:= .F.
Local cEndGrvTx     := ""
Local cThreadId		:= ""


Private oThredSE1	:= Nil	//Objeto controlador de MultThreads
Private nValorTef	:= 0

If !__l910Auto
	ProcRegua(Len(aLotes))
EndIf

For nIx := 1 TO Len( aLotes )

	lOk := A910VldLote( aLotes[nIx] )

	If !lOk
		Exit	
	EndIf
Next nIx

If Len(aLotes) == 1
	If Len(aLotes[1][9]) <= 50
		For nIx := 1 To Len( aLotes[1,9] )
			aAdd(aRecnosAux, aLotes[1,9,nIx]) 
		Next nIx
		Pergunte( "FIN110", .F. )
		aConcAux := oConc:aArray
		aLoteAux := {aRecnosAux,aLotes[1,2],aLotes[1,3],aLotes[1,4],cCheque,aLotes[1,1],cNatureza,aLotes[1,8],lBaixaVenc}
		lMsErroAuto := .F.
		FINA110( 3 , aLoteAux, .F., ,)
		lOk := !lMsErroAuto
		If lOk 
			For nIx := 1 To Len(aRecnosAux)
				nConcAux := aScan(aConcAux, {|x| x[22] = aRecnosAux[nIx] })
				If nConcAux > 0
					oConc:aArray[nConcAux][1]:cName := "BR_VERMELHO" 
				Endif
			Next nIx
		EndIf 
		Return lOk
	Endif
Endif

If lOk
	
	For nJx := 1 TO Len( aLotes )
		aRetThread := {} 
		aRetAux := {} 
		cThreadId := SubStr( 'FA110_' + AllTrim(Str(GenRandThread())),1,15)

		//Defino a seção, disponibilizando variáveis globais que podem ser enxergadas nas threads que serão abertas
		VarSetUID( cMyUId+cThreadId )

		// Objeto controlador de Threads
		oThredSE1 := FWIPCWait():New(cThreadId, 10000 )
		
		oThredSE1:SetThreads(__nThreads)
		
		oThredSE1:StopProcessOnError(.T.)
		
		oThredSE1:SetEnvironment(cEmpAnt,cFilAnt)
		
		oThredSE1:Start( 'A910ATHRBX' )
		
		aTitulosBX := AClone( aLotes[nJx] )
		
		If __lConoutR
			ConoutR( STR0106 + ', '+ STR0111 + aTitulosBX[1] + STR0112 + AllTrim( Str( Len( aTitulosBX[9] ) ) ) + ')' )
		EndIf 
		If !__l910Auto
			IncProc( STR0106 + ', ' + STR0111 + aTitulosBX[1] + STR0112 + AllTrim( Str( Len( aTitulosBX[9] ) ) ) + ')') //"Aguarde..."#(Lote: "#" / Qtde Títulos: "
        EndIf

		ProcLogAtu( STR0138, StrZero( ThreadId(),10) + ' ' + STR0111 + aTitulosBX[1] + STR0112 + AllTrim( Str( Len( aTitulosBX[9] ) ) ) + ')')

		lOk := A910APreBx( oThredSE1, aTitulosBX, aRegConc, cThreadId)
		
		If !lOk
			Exit
			
			oThredSE1:Stop() //Metodo aguarda o encerramento de todas as threads antes de retornar o controle.			
		Else

			oThredSE1:Stop() //Metodo aguarda o encerramento de todas as threads antes de retornar o controle.

			cErro := oThredSE1:GetError()

			aConcAux := oConc:aArray
			
			For nIx := 1 To Len(aRetThread)
				VarGetA(cMyUId+cThreadId, aRetThread[nIx][1], @aRet)
				If Len(aRet) > 0
					For nX := 1 To Len(aRet)
						nConcAux := aScan(aConcAux, {|x| x[22] = aRet[nX][1][2] })
						If aRet[nX][1][1]
							If nConcAux > 0
								oConc:aArray[nConcAux][1]:cName := "BR_VERMELHO" 
							Endif
						Else
							If nConcAux > 0
								oConc:aArray[nConcAux][1]:cName := "BR_AMARELO" 
							Endif
							lGrvTxt := .T.
							aAdd(aGrvTxt,{aRet[nX][1][2]})
						Endif
					Next nX
				Else
					lGrvTxt := .T.
					For nY := 1 To Len(aRetThread[nIx][2])
						aAdd(aGrvTxt,{aRetThread[nIx][2][nY]})
					Next nY
				Endif
				aAdd(aRetAux,aRet)
			Next nIx
			
			If Len(aRetAux) > 0
				For nIx := 1 To Len(aRetAux) 
					If Len(aRetAux[nIx]) > 0 .And. (Len(aRetAux[nIx]) - 1 ) == Len(aRetThread[nIx][2])
						Loop
					Else
						If Len(aRetAux[nIx]) > 0
							For nX := 1 To Len(aRetThread[nIx][2])
								If nX <= Len(aRetAux[nIx])
									Loop
								Else
									lGrvTxt := .T.
									aAdd(aGrvTxt,{aRetThread[nIx][2][nX]})
								Endif
							Next nX
						Endif
					Endif
				Next nIx
			Endif
	
			//Obtenho o array que foi alimentado pelas threads
			VarGetA( cMyUId+cThreadId, cKeyId, @aValor )
			
			//Varro o array atrás dos valores totais gravados pelas threads que foram executadas
			For nX := 1 To Len(aRetAux) 
				If Len(aRetAux[nX]) > 0
					nValorTef += aRetAux[nX][Len(aRetAux[nX])][1][2]
				Endif
			Next nX
	
			//Gera registro totalizador no SE5, caso baixa seja
			//aglutinada (BX_CNAB=S)
			If nValorTef > 0 .And. lBxCnab
				cBco110		:= PadR( aTitulosBX[5], nTamBanco	)
				cAge110		:= PadR( aTitulosBX[6], nTamAgencia	)
				cCta110		:= PadR( aTitulosBX[7], nTamCC		)
				cLoteFin	:= aTitulosBX[1]
				dBaixa		:= aTitulosBX[8]
	
				SE1->( DbSetOrder(1) )
				SE1->( DbSeek( xFilial('SE1') + aTitulosBX[1] + aTitulosBX[2] + aTitulosBX[3] + aTitulosBX[4] + aTitulosBX[5] + aTitulosBX[7] ) )
				
				//Define os campos que não existem nas FKs e que serão gravados apenas na E5, para que a gravação da E5 continue igual
				//Estrutura para o E5_CAMPOS: "{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}|{{'SE5->CAMPO', Valor}, {'SE5->CAMPO', Valor}}"
				cCamposE5 := "{"
			
			   	oModelBxR := FWLoadModel( 'FINM030' )
				oModelBxR:SetOperation( MODEL_OPERATION_INSERT ) //Inclusão
				oModelBxR:Activate()
				oModelBxR:SetValue( 'MASTER', 'E5_GRV'	, .T.	) //Informa se vai gravar SE5 ou não 
				oModelBxR:SetValue( 'MASTER', 'NOVOPROC', .T.	) //Informa que a inclusão será feita com um novo número de processo
				
				//Dados do Processo
				oSubFKA := oModelBxR:GetModel( 'FKADETAIL' )
				oSubFKA:SetValue( 'FKA_IDORIG', FWUUIDV4()	)
				oSubFKA:SetValue( 'FKA_TABORI', 'FK5'		)
				
				//Informacoes do movimento
				oSubFK5 := oModelBxR:GetModel( 'FK5DETAIL' )
				oSubFK5:SetValue( 'FK5_VALOR'	, nValorTef										)
				oSubFK5:SetValue( 'FK5_TPDOC'	, 'VL'											)
				oSubFK5:SetValue( 'FK5_BANCO'	, cBco110										)
				oSubFK5:SetValue( 'FK5_AGENCI'	, cAge110										)
				oSubFK5:SetValue( 'FK5_CONTA'	, cCta110										)
				oSubFK5:SetValue( 'FK5_RECPAG'	, 'R'											)
				oSubFK5:SetValue( 'FK5_HISTOR'	, STR0164 + " / " + STR0165 + ": " + cLoteFin	) // "Baixa Automatica / Lote: "	
				oSubFK5:SetValue( 'FK5_DTDISP'	, dBaixa										)
				oSubFK5:SetValue( 'FK5_FILORI'	, FilBxLote()									)
				oSubFK5:SetValue( 'FK5_ORIGEM'	, Substr(FunName(),1,8)							)
				oSubFK5:SetValue( 'FK5_LOTE'	, cLoteFin										)
				oSubFK5:SetValue( 'FK5_NATURE'	, cNatLote										) 
				oSubFK5:SetValue( 'FK5_MOEDA'	, StrZero( SE1->E1_MOEDA, 2 )					)
				
				oSubFK5:SetValue( 'FK5_DATA', dBaixa )
				cCamposE5 += '{"E5_DTDIGIT",STOD("' + DtoS( dDataBase ) + '")}'
				cCamposE5 += ',{"E5_DTDISPO",STOD("' + DtoS( dBaixa ) + '")}'
				
				If lSpbInUse
					cCamposE5 += ',{"E5_MODSPB","1"}'
				Endif
				
				cCamposE5 += ',{"E5_LOTE","' + cLoteFin + '"}'
				cCamposE5 += '}'
				
				oModelBxR:SetValue( 'MASTER', 'E5_CAMPOS', cCamposE5 ) //Informa os campos da SE5 que serão gravados indepentes de FK5
			
				If oModelBxR:VldData()		
					oModelBxR:CommitData()
					SE5->( dbGoto( oModelBxR:GetValue( 'MASTER', 'E5_RECNO' ) ) )
				Else
					lOk := .F.
					cLog := cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_IDFIELDERR]) + ' - '
				    cLog += cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_ID]) + ' - '
				    cLog += cValToChar(oModelBxR:GetErrorMessage()[MODEL_MSGERR_MESSAGE])        	
				    
				    Help( ,,'M030VALID',,cLog, 1, 0 )	            
				EndIf
				
				oModelBxR:DeActivate()
				oModelBxR:Destroy()
				
				// PONTO DE ENTRADA FA110TOT
				// ExecBlock para gravar dados complementares ao registro totalizador
				If lFa110Tot
					Execblock( 'FA110TOT', .F., .F. )
				EndIf
			
				// Atualiza saldo bancario
				AtuSalBco( cBco110, cAge110, cCta110, SE5->E5_DATA, SE5->E5_VALOR, '+' )
			EndIf	

			aValor := {}

			//Zero o valor da variável, evitando que ocorra somatória incorreta dos totais
			nValorTef := 0
					
		EndIf

		//Deleto a seção após sua utilização
		VarClean( cMyUId+cThreadId )
		FreeObj( oThredSE1 )
	Next nJx 

	If lGrvTxt
		If __l910Auto
			cEndGrvTx := FA910GrvTx(aGrvTxt)	
		Else
			If Aviso(STR0183, STR0189, {STR0188,STR0187}, 3) = 1 //"Existem titulos que não foram conciliados. Deseja gerar arquivo LOG para conferencia?."
				cEndGrvTx := FA910GrvTx(aGrvTxt)	
				Aviso(STR0183, STR0184 + STR0185 + cEndGrvTx,{STR0104}, 3)  // "Atenção" # "Os titulos que não foram conciliados estão relacionados no arquivo, gravado em: "
			Endif
		EndIf
	Endif
	
	If !__l910Auto
		IncProc( STR0154 )
	EndIf

	oThredSE1 := Nil
EndIf

Return lOk

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910VldLote
Efetua a valiação do lote de processamento dos lotes               

@type Function
@author Unknown
@since 21/01/2014
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A910VldLote( aLotes )

Local lOk		:= .T.
Local cBanco	:= PADR(aLotes[5],nTamBanco  )
Local cAgencia	:= PADR(aLotes[6],nTamAgencia)
Local cConta	:= PADR(aLotes[7],nTamCC     )

//Verifico informacoes para processo
If Empty(cBanco) .or. Empty(cAgencia) .or. Empty(cConta) 
	Help(" ",1,"BXLTAUT1",,STR0049, 1, 0 )		//"Informações incorretas não permitem a baixa automática em lote. Verifique as informações passadas para a função FBXLOTAUT()"
	lOk		:= .F.
ElseIf !CarregaSa6(@cBanco,@cAgencia,@cConta,.T.,,.F.)
	lOk		:= .F.
ElseIf Empty(aLotes[9])
	Help(" ",1,"RECNO")
	lOk		:= .F.
Endif

Return lOk

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910APreBx
Inicia a preparação das baixas dos cartões               

@type Function
@author Unknown
@since 21/01/2014
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function A910APreBx( oThread As Object , aTitulosBX As Array, aRegConc As Array, cThreadId As Character) As Logical

Local aRecnosAux    As Array
Local cChave        As Character
Local cMyUId		As Character
Local cKeyId		As Character
Local cBanco        As Character
Local cAgencia      As Character
Local cConta        As Character
Local cCheque       As Character
Local cLoteFin      As Array
Local cNatureza     As Character
Local aRecnos       As Array
Local lOk           As Logical
Local lBaixaVenc    As Logical
Local nIx           As Numeric 
Local nCont         As Numeric
Local nContAux		As Numeric
Local nQtLote		As Numeric
Local nCtrlLote		As Numeric
Local aValor		As Array
Local aRetTHD		As Array
Local nQtdeRec		As Numeric
Local nTHDAux		As Numeric

Private dBaixa      As Date 

aRecnosAux    := {}
cChave        := "FA110BXAUT_THRD"+cThreadId
cMyUId		  := 'F910_THREAD_ID' //Definição do nome da seção para controle de variáveis "globais"
cKeyId	      := ''		//Definição da chave para controle de variáveis "globais"'
cBanco        := PADR(aTitulosBX[5],nTamBanco  )
cAgencia      := PADR(aTitulosBX[6],nTamAgencia)
cConta        := PADR(aTitulosBX[7],nTamCC     )
cCheque       := ''
cLoteFin      := aTitulosBX[1]
cNatureza     := Nil
aRecnos       := aTitulosBX[9]
lOk           := .T.
lBaixaVenc    := lUseFIFDtCred	//se deve gravar a data de credito na E1_BAIXA
nIx           := 0
nCont         := 0
nContAux		:= 0
nQtLote		:= 0
nCtrlLote		:= 0
aValor		:= {}
aRetTHD		:= {}
nQtdeRec		:= Int(Len(aRecnos) / __nLoteThr) + 1 
nTHDAux		:= __nThreads

dBaixa      := aTitulosBX[8]


//Priorizo quantidade de recno por lote 
If nQtdeRec <= nTHDAux
	nTHDAux := nQtdeRec
	nQtLote := Int(Len(aRecnos) / nTHDAux) + 1
Else
	//Priorizo o numero de Threads
	nQtLote := Int(Len(aRecnos) / __nThreads)
Endif

If !LockByName( cChave, .F. , .F. )
	Help( " " ,1, cChave ,,STR0155,1, 0 )
	lOk := .F. 
Else
	// Abertura de Threads
	If !__l910Auto
		ProcRegua( Len( aRecnos ) )
	EndIf

	For nIx := 1 To Len( aRecnos )
		If !__l910Auto
			IncProc()
		EndIf

		nCont++
		nContAux++
		aAdd( aRecnosAux, aRecnos[nIx] )
		
		If nCont == nQtLote .Or. nContAux == Len( aRecnos )
			
			nCtrlLote++
			cKeyId	:= 'F910_KEY_' + cLoteFin + StrZero(nCtrlLote,3)

			aAdd(aRetThread, {cKeyId, aRecnosAux})
			
			VarSetA( cMyUId+cThreadId, cKeyId, aRetTHD )
	
           // Chamada da função A910ATHRBX( aTitulos, aRegConc )
           oThread:Go( {aRecnosAux,cBanco,cAgencia,cConta,cCheque,cLoteFin,cNatureza,dBaixa,lBaixaVenc}, aRegConc, .T.,cKeyId,dDataBase,cMyUId+cThreadId)
           Sleep(500)
           aRecnosAux	:= {}
           aValor		:= {}
           nCont		:= 0
		EndIf
	Next nIx

	// Fechamento das Threads   
	UnLockByName( cChave, .F. , .F. )
EndIf

Return lOk

//---------------------------------------------------------------------------
/*/{Protheus.doc} A910ATHRBX
Rotina de controle das baixas. Inicializa uma trasação porpor thread. Caso 
caia, somente aquela thread é afetada.   

Incluido dData para que a Thread suba com a database da execução. 

@type Function
@author Unknown
@since 21/01/2014
@version 12   
/*/
//---------------------------------------------------------------------------
Function A910ATHRBX( aTitulos As Array, aRegConc As Array, lThread As Logical, cKeyId As Character, dData As Date, cMyUId As Character) As Logical

Local lOk As Logical

Default lThread	 := .T.
Default cKeyId   := ""
Default dData	 := Date()

lOk			:= .F.
dDatabase	:= dData
lMsErroAuto := .F.

Pergunte( "FIN110", .F. )

If __lConoutR
	ConoutR( StrZero(ThreadId(),10) + STR0156 )
Endif

FINA110(3,aTitulos,lThread,cKeyId,aRegConc,cMyUId)

//Verifica se ExecAuto deu erro
lOk := !lMsErroAuto

If !lOk .And. __lConoutR
   ConoutR( StrZero(ThreadId(),10) + STR0157 )
   /* Como aqui é um processo via Thread, não deveriamos ter processo de tela. 
	Outra solução é arrumar a passagem de parametro para gravar o arquivo do erro e posteriormente ler esse arquivo. 
   ConoutR( MostraErro() )*/
   DisarmTransaction()
Endif

If __lConoutR
	ConoutR( StrZero(ThreadId(),10) + STR0158 )
Endif

Return lOk

//---------------------------------------------------------------------------
/*/{Protheus.doc} LoadBanco
Carrega todos os bancos utiliados na conciliação para a memoria. Evitando a 
busca repetida de dados no banco de dados

@type Function
@author Unknown
@since 21/01/2014
@version 12   
/*/
//---------------------------------------------------------------------------
Static Function LoadBanco()
Local aArea			:= GetArea()
Local bCondWhile	:= {|| .T. }
Local cQuery
Local cAliasSA6		:= "SA6"
Local cFilSA6		:= xFilial( 'SA6' )

// garanto que a variavel está limpa para o carregamento
__aBancos := {}

If __lDefTop == Nil
	__lDefTop := FindFunction("IFDEFTOPCTB") .And. IfDefTopCTB() 
EndIf

If __lDefTop
	cAliasSA6 := GetNextAlias()
	
	cQuery := "SELECT A6_FILIAL, A6_COD, A6_AGENCIA, A6_DVAGE, A6_NUMCON, A6_DVCTA, A6_BLOCKED"
	
	If lA6MSBLQL
		cQuery += ", A6_MSBLQL"
	Endif
	
	cQuery += "  FROM " + RetSqlName("SA6") + " SA6"
	cQuery += " WHERE SA6.A6_FILIAL = '" + cFilSA6 + "'"
	cQuery += "   AND SA6.D_E_L_E_T_ = ' '"
	
	cQuery := ChangeQuery( cQuery )

	// verifica se temporario está aberto e tenta fechalo
	If Select( cAliasSA6 ) > 0
		DbSelectArea( cAliasSA6 )
		( cAliasSA6 )->( DbCloseArea() )
	Endif

	dbUseArea( .T. , "TOPCONN" , TcGenQry(,,cQuery) , cAliasSA6 )
Else
	bCondWhile := {|| A6_FILIAL == cFilSA6 }
	(cAliasSA6)->( DbSetOrder(1) )
Endif

If Select( cAliasSA6 ) > 0
	DbSelectArea( cAliasSA6 )
	(cAliasSA6)->(DbGoTop())

	nCont := 0
	While (cAliasSA6)->(!Eof()) .And. Eval( bCondWhile ) 
		// adiciono os bancos a serem utilizados na busca, otimização do carregamento dos dados
		Aadd( __aBancos,	{	(cAliasSA6)->A6_FILIAL;
							,	Padr(Alltrim((cAliasSA6)->A6_COD),len((cAliasSA6)->A6_COD));
						 	,	Padr(Alltrim((cAliasSA6)->A6_AGENCIA),len((cAliasSA6)->A6_AGENCIA));
							,	Padr(Alltrim((cAliasSA6)->A6_DVAGE),len((cAliasSA6)->A6_DVAGE));
							,	Padr(alltrim((cAliasSA6)->A6_NUMCON),len((cAliasSA6)->A6_NUMCON));
							,	Padr(alltrim((cAliasSA6)->A6_DVCTA),len((cAliasSA6)->A6_DVCTA));
							,	(cAliasSA6)->A6_BLOCKED;
							,	Iif( lA6MSBLQL, (cAliasSA6)->A6_MSBLQL, Nil );
							})
		(cAliasSA6)->( DbSkip() )
	EndDo
Endif

If __lDefTop
	// verifica se temporario está aberto e tenta fechalo
	If Select( cAliasSA6 ) > 0
		DbSelectArea( cAliasSA6 )
		( cAliasSA6 )->( DbCloseArea() )
	Endif
Endif

RestArea( aArea )

Return

//---------------------------------------------------------------------------
/*/{Protheus.doc} FA910GrvTx
Grava arquivo texto com os daddos da SE1 que não foram conciliadas 

@type Function
@author Francisco Oliveira
@since 05/08/2018
@version 12   
/*/
//---------------------------------------------------------------------------

Static Function FA910GrvTx(aGrvTxt As Array) As Character 

Local aAreaSE1	As Array

Local nI        As Numeric
Local nHdl		As Numeric
Local cEOL    	As Character 
Local cLin		As Character 
Local cExtens	As Character 
Local cMainPath	As Character 

aAreaSE1	:= SE1->(GetArea())

cEOL    	:= "CHR(13)+CHR(10)"
cLin		:= ""
cExtens		:= "Arquivo TXT | *.TXT"
cMainPath	:= "C:\N_Conc_01.TXT"


cFileOpen 	:= cGetFile(cExtens,STR0225,,cMainPath,.T.)
nHdl    	:= fCreate(cFileOpen)
If !__l910Auto
	Incproc(Len(aGrvTxt))
EndIf

cLin := "FILIAL; FILORIG; PREFIXO; NUMERO; PARCELA; TIPO; VENCIMENTO; EMISSAO; DT BAIXA;  SALDO"
cLin += &cEOL
cLin += &cEOL

If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
	If !__l910Auto
		Aviso(STR0183, STR0186,{STR0104}, 3 ) //"Atencao!" # "Ocorreu um erro na gravacao do arquivo. Favor verificar"
	EndIf
Endif
	
For nI := 1 To Len(aGrvTxt)

	SE1->(DbGoTo(aGrvTxt[nI][1]))

	cLin	:= ""
	
	cLin := SE1->E1_FILIAL  		+ ";"
	cLin += SE1->E1_FILORIG 		+ ";"
	cLin += SE1->E1_PREFIXO 		+ ";" 
	cLin += SE1->E1_NUM     		+ ";" 
	cLin += SE1->E1_PARCELA 		+ ";" 
	cLin += SE1->E1_TIPO 			+ ";" 
	cLin += DTOC(SE1->E1_VENCTO)	+ ";" 
	cLin += DTOC(SE1->E1_EMISSAO)	+ ";" 
	cLin += DTOC(SE1->E1_BAIXA)		+ ";" 
	cLin += cValToChar(SE1->E1_SALDO)
	
	cLin += &cEOL
	
	If fWrite(nHdl,cLin,Len(cLin)) != Len(cLin)
		If !__l910Auto
			Aviso(STR0183, STR0186,{STR0104}, 3 ) //"Atencao!" # "Ocorreu um erro na gravacao do arquivo. Favor verificar"
		EndIf
		Exit
	Endif
	
Next nI

fClose(nHdl)

RestArea(aAreaSE1)

Return cFileOpen

//-------------------------------------------------------------------------------------
/*/{Protheus.doc} FA910ALEG
Rotina que monta a legenda dentro da tela de concilação
@type Function
@author Fernando Navarro 
@since 07/05/2019
@version 12
/*/
//-------------------------------------------------------------------------------------
Function FA910ALEG()

BrwLegenda("Conciliacao TEF","Legenda",{{"BR_VERDE"		,"Selecionado para Conciliar" },; //#"Não Processado"
										{"BR_VERMELHO"	,"Conciliado com Sucesso" },; //#"Conciliado Normal"
										{"BR_AMARELO"	,"Problemas na Conciliação" },; //#"Divergente"
										{"BR_BRANCO"	,"Não selecionado" },; //#"Descartado"
										{"BR_PRETO"		,"Conta não cadastrada"  }}) //#"Antecipado"			


Return 

