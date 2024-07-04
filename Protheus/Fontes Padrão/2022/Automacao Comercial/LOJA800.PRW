#INCLUDE "LOJA800.CH"       
#INCLUDE "PROTHEUS.CH"

#DEFINE VALMERC    1	// Valor total do mercadoria
#DEFINE VALDESC 	2	// Valor total do desconto
#DEFINE FRETE   	3   // Valor total do Frete
#DEFINE VALDESP 	4  	// Valor total da despesa
#DEFINE TOTF1		5	// Total de Despesas Folder 1
#DEFINE TOTPED		6	// Total do Pedido
#DEFINE SEGURO		7	// Valor total do seguro
#DEFINE TOTF3		8	// Total utilizado no Folder 3
#DEFINE IMPOSTOS 	9	// Array contendo Os Valores de Impostos Exibidos no ListBox

Static cSenha		:= "******"		   										//Variavel apagada pelo Framework 
Static lR5			:= GetRpoRelease("R5") 									// Indica se o release e 11.5    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA800   บAutor  ณArmando P. Waiteman บ Data ณ  03/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rotina para tratamento de vendas lay-away (Porto Rico e EUA)ฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤย--ฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณProgramad ณ Data  	ณ BOPS ณ  Motivo da Alteracao 					  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤล--ฤฤฤฤฤฤฤฤลฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณFernando  ณ13/12/06  ณ9.12  ณBops 115301 Alterado a array aRotina  paraณฑฑ
ฑฑณ          ณ          |      ณ cria็ใo do menu funcional            	  ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function Loja800()
			 
Local nY 
Static cContrato    := "" 													//Codigo de contrato do Manejo de Apartados
			 
// Variaveis logicas para definicao de opcao
Private lInclui	:= .F.
Private lAltera := .F.
Private lVisual	:= .F.
Private lDeleta	:= .F.
Private lPagto	:= .F.

// Campos da Enchoice (Inclusao/Alteracao)
Private cNumLay 	:= Space(TamSX3("LO_NUMLAY")[1])
Private dEmissao	:= Criavar("LO_EMISSAO",.T.)
Private dEntreg 	:= Criavar("LO_DTENT",.T.)
Private cCliente	:= Criavar("LO_CLIENTE",.T.)
Private cLoja   	:= Criavar("LO_LOJA",.T.)
Private cCond   	:= Criavar("LO_COND",.T.)
Private nMoeda  	:= Criavar("LO_MOEDA",.T.)
Private nTaxaMoeda	:= Criavar("LO_TXMOEDA",.T.)
Private nTotal 		:= Criavar("LO_TOTAL",.T.)
Private nPagtoIni	:= Criavar("LO_VALPAG",.T.)
Private nValorOrig	:= Criavar("LO_VALPAG",.T.)  

Private nVlPagto	:= 0
Private nVlMulta    := 0

// Variaveis para complemento de dados no momento da inclusao de novo item
Private nValPago    := 0
Private nNumPagto

// Variaveis para posicionamento no aCols
Private nPosProd    := 0
Private nPosLocal   := 0
Private nPosQtd     := 0
Private nPosVlr     := 0
Private nPosTotal   := 0
Private nPosVlDes   := 0
Private nPosDesc    := 0
Private nPosItem    := 0
Private nPosLote    := 0
Private nPosNumLote := 0
Private nPosLocaliz := 0
Private nPosSerie   := 0

// Variaveis usadas pela mbrowse
Private cCadastro := STR0001 + STR0094  //"Atualizacao de Lay-Away"
Private aHeader  := {}
Private aAlter  := {}
Private nUsado  := 0
Private aRotina := MenuDef()
Private aCposEnc := {}
Private aCores  := { {"LO_STATUS=='1' .AND. LO_DTENT >= dDataBase",'ENABLE' },;		//Lay-Away em Andamento
				     {"LO_STATUS=='2'",'DISABLE'							 },;		//Law-Away Encerrado
				     {"LO_STATUS=='1' .AND. LO_DTENT < dDatabase",'BR_AMARELO'},;	    //Lay-Away Vencido
				     {"LO_STATUS=='4'",'BR_CINZA'							 }}        //Lay-Away Excluido/Cancelado



// Variavel usadas para calculo de impostos
Private aRefImpos:= {}

// Array usado para guardar as amarracoes antes de grava-las
Private aAmarras := {}


// Array com todos os titulos amarrados ao Lay-Away (Disponivel para o ponto de entrada LJ800TIT)
Private aTitulos := {}
						
Private aCartoes    := {}  //Armazena as administradoras financeiras de CC|CD
Private cFormaPg    := Padr(SuperGetMV("MV_SIMB1"),3)
Private cCartao     := ""
Private oComboCC
Private oSayCC

If cPaisLoc$"MEX|COL" .AND. lR5
	cContrato   := Criavar("LO_CODCON",.T.) 			//Codigo de contrato do Manejo de Apartados 
EndIf

// Lista de campos que nao deve ser incluidos no aheader por ja estarem na enchoice
If cPaisLoc$"MEX|COL" .AND. lR5
	aCposEnc := {"LO_NUMLAY","LO_EMISSAO","LO_CLIENTE","LO_LOJA","LO_COND",;
						"LO_FRETE","LO_DESPESA","LO_MOEDA","LO_DTENT","LO_CODCON"} 
Else 
	aCposEnc := {"LO_NUMLAY","LO_EMISSAO","LO_CLIENTE","LO_LOJA","LO_COND",;
						"LO_FRETE","LO_DESPESA","LO_MOEDA","LO_DTENT"}
EndIf

// Montagem do aHeader                                  ณ
dbSelectArea("SX3")
dbSetOrder(1)
DbSeek("SLO")
While ( !Eof() .AND. (SX3->X3_ARQUIVO == "SLO") )
	If ((X3USO(SX3->X3_USADO))                              .AND.;
		 (aScan(aCposEnc,{|x|Trim(SX3->X3_CAMPO) == X }) <= 0) .AND.;
	     (cNivel >= SX3->X3_NIVEL))
		Aadd(aHeader,{ TRIM(X3Titulo()),;
			SX3->X3_CAMPO,;
			SX3->X3_PICTURE,;
			SX3->X3_TAMANHO,;
			SX3->X3_DECIMAL,;
			SX3->X3_VALID,;
			SX3->X3_USADO,;
			SX3->X3_TIPO,;
			SX3->X3_ARQUIVO,;
			SX3->X3_CONTEXT } )
		nUsado++
		//Monta array com os campos que poderao ser editados na GetDados...
		If Trim(SX3->X3_CAMPO) <> "LO_ITEM"
			AAdd(aAlter,SX3->X3_CAMPO)
		EndIF
	EndIf
	nX	:= At("MAFISREF(",Upper(SX3->X3_VALID))
	nY  := 0
	If ( nX > 0 )
		nX    += 10
		nY    := At(",",SubStr(SX3->X3_VALID,nX))-2
		aadd(aRefImpos,{"SLO",SX3->X3_CAMPO,SubStr(SX3->X3_VALID,nX,nY)})
	EndIf
	dbSelectArea("SX3")                                   	
	dbSkip()
End

If a800Valida()
	mBrowse( 6, 1,22,75,"SLO",,,,,,aCores)
EndIf

Return


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    |MenuDef	ณ Autor ณ Fernando Amorim       ณ Data ณ13/12/06  ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Funcao de defini็ใo do aRotina                             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณRetorno   ณ aRotina   retorna a array com lista de aRotina             ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ SIGALOJA                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Static Function MenuDef() 

Local aRotina:= { 	  { STR0002,"AxPesqui"  		, 0 , 1 , , .F.},;		 //"Pesquisar"
		              { STR0003,"a800LayAway" 	, 0 , 3 , , .T.},;		 //"Incluir"
		              { STR0004,"a800LayAway" 	, 0 , 4 , , .T.},;		 //"Alterar"
                      { STR0005,"a800Paga"		, 0 , 5 , , .T.},;  	 //"Consultar/Pagar"
		              { STR0006,"a800LayAway"	, 0 , 6 , , .T.},;		 //"Cancelar"
                      { STR0007,"a800Title"		, 0 , 7 , , .T.} }		 //"Legenda"
							
							
Return(ARotina)



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800IncluiบAutor  ณArmando P. Waiteman บ Data ณ  03/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInclusao de lay-away                                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP6                                                        บฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ   DATA   ณ Programador   ณManutencao Efetuada                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ02/02/2007ณ Conrado Q.    ณBops 115971: Montagem do aCols e aHeader    ณฑฑ
ฑฑณ          ณ               ณatrav้s da rotina FillGetDados.             ณฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function A800LayAway(cAlias,	nReg,	nOpcx)

Local nOpca		:= 0
Local nX		:= Nil
Local nY		:= Nil
Local aCombo   	:= {"C-CIF","F-FOB"}
Local aObjects	:= {}
Local aInfo 	:= {}
Local aPosOb	:= {}
Local aPages    := {"HEADER"}
Local cNomeCli  := ""                    //Recebe Nome do Cliente
Local aObj[16]
Local aSizeAut	:= MsAdvSize(,.F.,400)
Local aTitles   := {STR0008,;  //"Totais"
					STR0009,;  //"Inf. Cliente"
					STR0010,;  //"Frete/Despesas"
					STR0011}  //"Impostos"

Local aButtons	:= {{'PRECO' ,{||  If(nMoeda <> 1 .AND. !lDeleta,a800TxMoeda(),AllwaysTrue())},STR0012},; //"Taxa das Moedas"
					 {'BUDGET',{||  If(lAltera,Lj800Vld(),If(!lDeleta .AND. oGetDados:TudoOk(),a800Pagtos(),AllwaysTrue()))},STR0013 }}  //"Plano de Pagto"
Local nSaveSx8 	:= GetSx8Len()
Local cSeek		:= ""			// Seek para montagem do aCols
Local cWhile	:= ""			// While para montagem do aCols

Local aParcela  :={}            //Array que contem a quantidade de parcelas que o cliente ja possui 

// Variaveis usadas para refresh de impostos
Private oDlg			:= Nil
Private cTpFrete 		:= "C-CIF"
Private aInfForn	    := {"","",CTOD(""),CTOD(""),"","",""}
Private aValores	    := {0,0,0,0,0,0,0,0,{{'','',0,0,0}}}
Private	bFolderRefresh	:= {|| (A800Refresh(@aValores)),(A800FRefresh(aObj))}
Private bGDRefresh		:= {|| (oGetDados:oBrowse:Refresh()) }
Private	bZeraDesc		:= {|| (nDesc1:=0),(nDesc2:=0),(nDesc3:=0)}
Private bRefresh		:= {|| (Eval(bFolderRefresh))}
Private bListRefresh	:= {|| (MaFisToCols(aHeader,aCols,,"MT120")),(Eval(bRefresh),Eval(bGDRefresh)) }
Private aPosGet			:= {}
Private oNomeCli		:= Nil
Private aCols			:= {}
Private aItensLay       := {}

//Apesar de declaradas na funcao LOJA800 aqui devem ser inicializadas as variavei para cada inclusao
cNumLay 	:= Criavar("LO_NUMLAY",.T.)
dEmissao	:= Criavar("LO_EMISSAO",.T.)
dEntreg 	:= Criavar("LO_DTENT",.T.)
cCliente	:= Criavar("LO_CLIENTE",.T.)
cLoja   	:= Criavar("LO_LOJA",.T.)
cCond   	:= Criavar("LO_COND",.T.)
nMoeda  	:= Criavar("LO_MOEDA",.T.)
nTaxaMoeda	:= Criavar("LO_TXMOEDA",.T.)
nTotal 		:= Criavar("LO_TOTAL",.T.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณCodigo de contrato do Manejo de Apartados    ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If cPaisLoc$"MEX|COL" .AND. lR5
	 cContrato   := Criavar("LO_CODCON",.T.) 
EndIf
aAmarras	:= {}

// Variavel usada para definicao do pagto inicial
nPagtoIni	:= Criavar("LO_VALPAG",.T.)
nValorOrig	:= Criavar("LO_VALPAG",.T.)

cFormaPg    := Padr(SuperGetMV("MV_SIMB1"),3)
cCartao     := ""

// Inicializa as variaveis usadas para montagem de tela
aObjects := {}
AAdd( aObjects, { 0,    41, .T., .F. } )
AAdd( aObjects, { 100, 100, .T., .T. } )
AAdd( aObjects, { 0,    75, .T., .F. } )
aInfo := { aSizeAut[ 1 ], aSizeAut[ 2 ], aSizeAut[ 3 ], aSizeAut[ 4 ], 3, 3 }
aPosObj := MsObjSize( aInfo, aObjects )

If cPaisLoc$"MEX|COL" .AND. lR5
	aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,;
				{{01,05,10,13,18,23,26,29,31,34,01,05,10,12,14,15,16},;
				{40,04,100,300},;	
				{5,70,160,205,295},;
				{6,34,200,215},;
				{6,34,80,113,160,175},;
				{6,34,245,268},;
				{10,50,150,190},;
				{130,190},;
				{293}})
Else 
	aPosGet := MsObjGetPos(aSizeAut[3]-aSizeAut[1],305,;
			{{01,05,10,13,18,23,26,29,31,34,01,05,10,12,14},;
			{40,04,100,300},;	
			{5,70,160,205,295},;
			{6,34,200,215},;
			{6,34,80,113,160,175},;
			{6,34,245,268},;
			{10,50,150,190},;
			{130,190},;
			{293}})
EndIf			

// Inicializa os arrays de impostos
If !MaFisFound("NF")
	MaFisIni(cCliente,cLoja,"C","N",Nil,aRefImpos,,.F.,"SB1","LJ800")
EndIf

// Define a opcao em uso
lInclui	:= (aRotina[nOpcx][4] == 3)
lAltera	:= (aRotina[nOpcx][4] == 4)
lDeleta	:= (aRotina[nOpcx][4] == 6)
lVisual	:= (aRotina[nOpcx][4] == 2)

// Monta o aCols
If lInclui
    nValPago:= 0     
    aHeader	:= {}
    
	If Len(aHeader) == 0 .AND. Len(aCols) == 0
		FillGetDados(	aRotina[nOpcx][4]	,"SLO"		,1				,/*cSeek*/		,;
						/*{||cWhile}*/		,{|| .T. }	,aCposEnc		,/*aYesFields*/	,; 
						/*lOnlyYes*/		,/*cQuery*/	,/*bMontCols*/	,.T.			)
	Endif
	
	aCols[1][GdFieldPos("LO_ITEM")] := "01"    

Else
	cNumLay 	:= SLO->LO_NUMLAY
	dEmissao	:= SLO->LO_EMISSAO
	dEntreg 	:= SLO->LO_DTENT
	cCliente	:= SLO->LO_CLIENTE
	cLoja   	:= SLO->LO_LOJA
	cCond   	:= SLO->LO_COND
	nMoeda  	:= SLO->LO_MOEDA
	nTaxaMoeda  := SLO->LO_TXMOEDA
	nValPago	:= SLO->LO_VALPAG
	nNumPagto	:= SLO->LO_NUMPARC	
	If cPaisLoc$"MEX|COL" .AND. lR5
		cContrato   :=SLO->LO_CODCON
	EndIf
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณNใo permitir que Lay-Away encerrado ou anulado acesse             ณ
	//ณop็ใo de modifica็ใo, cancelamento ou de pagamentos.              ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู	
	dbSelectArea("SLO")
	dbSetOrder(1)
	dbSeek(xFilial("SLO")+cNumLay,.T.)   
	
	If !(VldOpc800(.F.))
		Return
	Endif	

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณMonta aHeader e aCols.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	cSeek	:= xFilial("SLO")+cCliente+cLoja+cNumLay
	cWhile	:= "SLO->LO_FILIAL+SLO->LO_CLIENTE+SLO->LO_LOJA+SLO->LO_NUMLAY"
	aHeader	:= {}
	
	If Len(aHeader) == 0 .AND. Len(aCols) == 0
		FillGetDados(	aRotina[nOpcx][4]	,"SLO"			,2						,cSeek				,;
		  				{|| &cWhile }		,{|| .T. }		,aCposEnc				,/*aYesFields*/		,; 
						/*lOnlyYes*/		,/*cQuery*/		,/*bMontCols*/			,/*lEmpty*/			,;
						/*aHeaderAux*/		,/*aColsAux*/	,{|| a800bAfterCols() }	,/*bBeforeCols*/	)
	Endif

	// Depois de montado o aCols, volta a posicionar o primeiro item do lay-away
	dbSeek(xFilial("SLO")+cNumLay,.T.)
	
	//Executa o Refresh nos valores de impostos. 
	A800Refresh(@aValores)
EndIf			
	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Faz a montagem da tela                                       ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE MSDIALOG oDlg FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] TITLE cCadastro OF oMainWnd PIXEL
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRelease 11.5ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤู	
If lR5	
	@ 0.4,aPosGet[1][1]  SAY STR0094 		 //"Lay-Away"#"Manejo de Apartados"
	@ 0.4,aPosGet[1][2]  MSGET oNumLay VAR cNumLay Picture PesqPict("SLO","LO_NUMLAY")When lInclui Valid a800VldNum() OF oDlg
	@ 0.4,aPosGet[1][3]  SAY STR0015                           //"Emissao"
	@ 0.4,aPosGet[1][4]  MSGET oEmissao VAR dEmissao Picture PesqPict("SLO","LO_EMISSAO") When lInclui Valid a800Vld(5) .AND. CheckSX3("LO_EMISSAO",dEmissao) OF oDlg 
	@ 0.4,aPosGet[1][5]  SAY STR0013 //"Plano de Pagto"
	@ 0.4,aPosGet[1][6]  MSGET oCond VAR cCond Picture PesqPict("SLO","LO_COND")  F3 CpoRetF3("LO_COND") Valid CheckSX3("LO_COND",cCond) OF oDlg
	@ 0.4,aPosGet[1][7]  SAY STR0016 //"Moeda"
	@ 0.4,aPosGet[1][8]  MSGET oMoeda VAR nMoeda Picture Pesqpict("SLO","LO_MOEDA") Valid (A800VldMoeda(nMoeda) .AND. CheckSX3("LO_MOEDA",nMoeda)) OF oDlg
	@ 0.4,aPosGet[1][09] SAY STR0017 //"Entrega"
	@ 0.4,aPosGet[1][10] MSGET oEntreg VAR dEntreg Picture PesqPict("SLO","LO_DTENT") Valid a800Vld(6) .AND. CheckSX3("SLO",dEntreg) OF oDlg 
	@ 1.4,aPosGet[1][11] SAY STR0018 //"Cliente"
	@ 1.4,aPosGet[1][12] MSGET oCliente VAR cCliente Picture PesqPict("SLO","LO_CLIENTE") F3 CpoRetF3("LO_CLIENTE") When lInclui Valid a800VldCli() .AND. CheckSX3("LO_CLIENTE",cCliente)   OF oDlg
	@ 1.4,aPosGet[1][13] SAY STR0019 //"Loja"
	@ 1.4,aPosGet[1][14] MSGET oLoja VAR cLoja OF oDlg When lInclui Valid !Empty(cLoja) .AND. a800VldCli()  Picture PesqPict("SLO","LO_LOJA")
   	If cPaisLoc$"MEX|COL" .AND. lR5 .AND. FindFunction("a800VldCon")
   		@ 1.4,aPosGet[1][6]  SAY STR0087 //"Contrato de Manejo de Apartados" 
   		@ 1.4,aPosGet[1][09] MSGET oCod VAR cContrato SIZE 50,10  Picture PesqPict("SLO","LO_CODCON") F3 CpoRetF3("LO_CODCON") When lInclui Valid a800VldCon() .AND. CheckSX3("LO_CODCON",cContrato) OF oDlg 
	EndIf
	// Caso nao seja inclusao forca a aparicao do nome do cliente
Else
	@ 1.2,aPosGet[1][1]  SAY STR0094 		 //"Lay-Away"#"Manejo de Apartados"
	@ 1.2,aPosGet[1][2]  MSGET oNumLay VAR cNumLay Picture PesqPict("SLO","LO_NUMLAY")When lInclui Valid a800VldNum() OF oDlg
	@ 1.2,aPosGet[1][3]  SAY STR0015                           //"Emissao"
	@ 1.2,aPosGet[1][4]  MSGET oEmissao VAR dEmissao Picture PesqPict("SLO","LO_EMISSAO") When lInclui Valid a800Vld(5) .AND. CheckSX3("LO_EMISSAO",dEmissao) OF oDlg 
	@ 1.2,aPosGet[1][5]  SAY STR0013 //"Plano de Pagto"
	@ 1.2,aPosGet[1][6]  MSGET oCond VAR cCond Picture PesqPict("SLO","LO_COND") F3 CpoRetF3("LO_COND") Valid CheckSX3("LO_COND",cCond) OF oDlg
	@ 1.2,aPosGet[1][7]  SAY STR0016 //"Moeda"
	@ 1.2,aPosGet[1][8]  MSGET oMoeda VAR nMoeda Picture Pesqpict("SLO","LO_MOEDA") Valid (A800VldMoeda(nMoeda) .AND. CheckSX3("LO_MOEDA",nMoeda)) OF oDlg
	@ 1.2,aPosGet[1][09] SAY STR0017 //"Entrega"
	@ 1.2,aPosGet[1][10] MSGET oEntreg VAR dEntreg Picture PesqPict("SLO","LO_DTENT") Valid a800Vld(6) .AND. CheckSX3("SLO",dEntreg) OF oDlg 
	@ 2.2,aPosGet[1][11] SAY STR0018 //"Cliente"
	@ 2.2,aPosGet[1][12] MSGET oCliente VAR cCliente Picture PesqPict("SLO","LO_CLIENTE") F3 CpoRetF3("LO_CLIENTE") When lInclui Valid a800VldCli() .AND. CheckSX3("LO_CLIENTE",cCliente)   OF oDlg
	@ 2.2,aPosGet[1][13] SAY STR0019 //"Loja"
	@ 2.2,aPosGet[1][14] MSGET oLoja VAR cLoja OF oDlg When lInclui Valid !Empty(cLoja) .AND. a800VldCli()  Picture PesqPict("SLO","LO_LOJA") 
	// Caso nao seja inclusao forca a aparicao do nome do cliente
Endif

If !lInclui
	a800VldCli()
EndIf

  
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRelease 11.5ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤู	
If lR5 .AND. FindFunction( "a800Modi")
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFaz a motagem da GetDados           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oGetDados := MSGetDados():New((aPosGet[2][1]-40),aPosGet[2][2],(aPosGet[2][3]+80),aPosGet[2][4],nOpcX,'A800LinOk','A800TudoK','+LO_ITEM',.T.,aAlter,,,300,'a800Modi()',,,'a800Del',oDlg)
	oGetDados:oBrowse:bGotFocus	:= {||A800CabOk(@oCond,@oCliente,@oLoja,aRefImpos)}
	 
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFaz a motagem da GetDados           ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	oGetDados := MSGetDados():New(aPosGet[2][1],aPosGet[2][2],aPosGet[2][3],aPosGet[2][4],nOpcX,'A800LinOk','A800TudoK','+LO_ITEM',.T.,aAlter,,,300,'Eval({||(lInclui .OR. SuperGetMv("MV_LWALT"))})',,,'a800Del',oDlg)
	oGetDados:oBrowse:bGotFocus	:= {||A800CabOk(@oCond,@oCliente,@oLoja,aRefImpos) }
Endif

 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFaz a motagem das pastas de impostosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRelease 11.5ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤู	
If lR5	
	oFolder := TFolder():New(aPosObj[3,1]-10,aPosObj[3,2],aTitles,aPages,oDlg,,,, .T., .F.,aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1],)
Else
	oFolder := TFolder():New(aPosObj[3,1],aPosObj[3,2],aTitles,aPages,oDlg,,,, .T., .F.,aPosObj[3,4]-aPosObj[3,2],aPosObj[3,3]-aPosObj[3,1],)
EndIf
//acerto no folder para nao perder o foco
For nX := 1 to Len(oFolder:aDialogs)
	DEFINE SBUTTON FROM 5000,5000 TYPE 5 ACTION Allwaystrue() ENABLE OF oFolder:aDialogs[nX]
Next nX


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFolder dos totais da rotina                                   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oFolder:aDialogs[1]:oFont := oDlg:oFont
@ 006,aPosGet[3,1] SAY STR0020 OF oFolder:aDialogs[1] PIXEL SIZE 055,009  //"Valor da Mercadoria"
@ 005,aPosGet[3,2] MSGET aObj[1] VAR aValores[VALMERC] PICTURE PesqPict('SLO','LO_TOTAL',14,nMoeda) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
@ 020,aPosGet[3,1] SAY STR0021 OF oFolder:aDialogs[1] PIXEL SIZE 050,009  //"Desconto"
@ 019,aPosGet[3,2] MSGET aObj[2] VAR aValores[VALDESC]  PICTURE PesqPict('SLO','LO_VALDESC',14,nMoeda) OF oFolder:aDialogs[1] PIXEL WHEN .F.  SIZE 080,009
@ 006,aPosGet[3,3] SAY STR0022 OF oFolder:aDialogs[1] PIXEL SIZE 050,009  //"Frete"
@ 005,aPosGet[3,4] MSGET aObj[3] VAR aValores[FRETE]  PICTURE PesqPict('SLO','LO_FRETE',14,nMoeda) OF oFolder:aDialogs[1] PIXEL WHEN .F.  SIZE 080,009
@ 020,aPosGet[3,3] SAY STR0023 OF oFolder:aDialogs[1] PIXEL SIZE 050,009   //"Despesas"
@ 019,aPosGet[3,4] MSGET aObj[4] VAR aValores[VALDESP]  PICTURE PesqPict('SLO','LO_DESPESA',14,nMoeda) OF oFolder:aDialogs[1] PIXEL WHEN .F.  SIZE 080,009
@ 051,aPosGet[3,3] SAY STR0024 + STR0094 OF oFolder:aDialogs[1] PIXEL SIZE 088,009  //"Total do Lay-Away"
@ 049,aPosGet[3,4] MSGET aObj[5] VAR aValores[TOTPED]  PICTURE PesqPict('SLO','LO_TOTAL',14,nMoeda) OF oFolder:aDialogs[1] PIXEL WHEN .F. SIZE 080,009
@ 043,003 TO 46 ,aPosGet[3,5] LABEL '' OF oFolder:aDialogs[1] PIXEL


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFolder com as informacoes do cliente                          ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oFolder:aDialogs[2]:oFont := oDlg:oFont
@ 006,aPosGet[4,1] SAY STR0025 OF oFolder:aDialogs[2] PIXEL SIZE 037,009  //"Nome"
@ 005,aPosGet[4,2] MSGET aObj[6] VAR aInfForn[1] PICTURE PesqPict('SA1','A1_NOME');
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 159,009
@ 006,aPosGet[4,3] SAY STR0026 OF oFolder:aDialogs[2] PIXEL SIZE 023,009  //"Tel."
@ 005,aPosGet[4,4] MSGET aObj[7] VAR aInfForn[2] PICTURE PesqPict('SA1','A1_TEL');
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 074,009
@ 043,aPosGet[5,1] SAY STR0027 OF oFolder:aDialogs[2] PIXEL SIZE 032,009  //"1a Compra"
@ 042,aPosGet[5,2] MSGET aObj[8] VAR aInfForn[3] PICTURE PesqPict('SA1','A1_PRICOM') ;
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 040,009
@ 043,aPosGet[5,3] SAY STR0028 OF oFolder:aDialogs[2] PIXEL SIZE 036,009  //"Ult. Compra"
@ 042,aPosGet[5,4] MSGET aObj[9] VAR aInfForn[4] PICTURE PesqPict('SA1','A1_ULTCOM');
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 040,009
@ 43 ,aPosGet[5,5] SAY RTrim(RetTitle("A1_CGC")) Of oFolder:aDialogs[2] PIXEL SIZE 21 ,9 // "Inscricao Fiscal"
@ 42 ,aPosGet[5,6] MSGET aObj[10] VAR aInfForn[7] Picture PesqPict('SA1','A1_CGC');
   	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 76 ,9
@ 024,aPosGet[6,1] SAY STR0029 OF oFolder:aDialogs[2] PIXEL SIZE 049,009 //"Endereco"
@ 023,aPosGet[6,2] MSGET aObj[11] VAR aInfForn[5]  PICTURE PesqPict('SA1','A1_END');
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 205,009
@ 024,aPosGet[6,3] SAY RTrim(RetTitle("A1_EST")) OF oFolder:aDialogs[2] PIXEL SIZE 032,009 // "Unid. Federativa"
@ 023,aPosGet[6,4] MSGET aObj[12] VAR aInfForn[6]  PICTURE PesqPict('SA1','A1_EST');
	WHEN .F. OF oFolder:aDialogs[2] PIXEL SIZE 021,009

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFolder das despesas acessorias                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oFolder:aDialogs[3]:oFont := oDlg:oFont
@ 009,aPosGet[7,1] SAY STR0030 OF oFolder:aDialogs[3] PIXEL SIZE 035,009  //"Tp. Frete"
@ 008,aPosGet[7,2] MSCOMBOBOX aObj[13] VAR cTpFrete ITEMS aCombo ON CHANGE A800VldCombo(cTpFrete,@aValores) .AND. A800VFold("NF_FRETE",aValores[FRETE]) WHEN (lInclui .OR. lAltera) SIZE 045,050 OF oFolder:aDialogs[3] PIXEL
@ 009,aPosGet[7,3] SAY STR0031 OF oFolder:aDialogs[3] PIXEL SIZE 055,009  //"Valor do Frete"
@ 008,aPosGet[7,4] MSGET aObj[14] VAR aValores[FRETE]  PICTURE PesqPict('SLO','LO_FRETE',14,nMoeda) OF oFolder:aDialogs[3] PIXEL WHEN (lInclui .OR. lAltera) .AND. cTpFrete=="C-CIF" VALID A800VFold("NF_FRETE",aValores[FRETE]) SIZE 080,009
@ 026,aPosGet[7,3] SAY STR0023 OF oFolder:aDialogs[3] PIXEL SIZE 042,009   //"Despesas"
@ 025,aPosGet[7,4] MSGET aObj[15] VAR aValores[VALDESP] PICTURE PesqPict('SLO','LO_DESPESA',14,nMoeda) OF oFolder:aDialogs[3] PIXEL WHEN (lInclui .OR. lAltera) VALID A800VFold("NF_DESPESA",aValores[VALDESP]) SIZE 080,009
@ 038,011 TO 40 ,aPosGet[3,5] LABEL '' OF oFolder:aDialogs[3] PIXEL
@ 048,aPosGet[8,1] SAY STR0032 OF oFolder:aDialogs[3] PIXEL SIZE 080,009  //"Total ( Frete+Despesas)"
@ 047,aPosGet[8,2] MSGET aValores[TOTF3]  PICTURE PesqPict('SLO','LO_DESPESA',14,nMoeda) OF oFolder:aDialogs[3] PIXEL WHEN .F. SIZE 080,009


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณFolder do resumo de impostos                                  ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
oFolder:aDialogs[4]:oFont := oDlg:oFont
aObj[16] := MaFisRodape(1,oFolder:aDialogs[4],,{5,3,aPosGet[09,1],53},bListRefresh,.f.)


ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||If(oGetDados:TudoOk(),(nOpca:=1,oDlg:End()),nOpca:=0)},{||oDlg:End()},,aButtons)
 
If lInclui .AND. (cPaisLoc$"MEX|COL" .AND. lR5) .AND. FindFunction( "a800Parc")
	aParcela := a800Parc(cCliente,cLoja)
	If !aParcela[1][3]
		If FindFunction( "a800Cli")
			cNomeCli := a800Cli(cCliente,cLoja)
		EndIf	 
		Aviso(STR0088,STR0089 + Alltrim(cCliente) + "-" + Alltrim(cNomeCli) + Space(01)  +  STR0090 + cContrato ,{STR0091},2)  //"Aten็ใo","O Cliente " + cCliente +  "atingiu o limite de Manejos de apartados de acordo com o contrato: " + cContrato ,{"OK"}
		nOpca := 2            
	EndIf	
EndIf

If nOpca == 1
     Begin Transaction
     	If lInclui
	     	a800Grava(.T.,Nil,.T.)
            If __lSX8
            	While (GetSX8Len() > nSaveSx8)
					ConfirmSX8()
				End
            EndIf	     	
	    ElseIf lAltera
	    	a800Altera()
	    EndIf	    
     End Transaction
     MsUnLockAll()
     If ExistBlock("LJ800GRV")
	    Execblock("LJ800GRV",.F.,.F.)
     EndIf     
Else
   If __lSX8
		While (GetSX8Len() > nSaveSx8)   	
			RollbackSX8()
		End
   EndIf     
EndIf             
nValPago  := 0     
cFormaPg  := Padr(SuperGetMV("MV_SIMB1"),3)
cCartao   := ""
aItensLay := {}
MaFisEnd()
FreeUsedCode()

RETURN



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบProgram   ณa800ShowClบAuthor ณArmando P. Waiteman บ Date ณ  03/07/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMostra o nome do cliente na Tela                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUse       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Static Function a800VldCli()

Local cNomeCli
Local lRet
Local cChave  


cChave  := cCliente

If !Empty(cLoja)
	cChave  += cLoja
EndIf

dbSelectArea("SA1")
dbSetOrder(1)
If dbSeek(xFilial("SA1")+cChave,.T.)
	cNomeCli:=A1_NOME
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณRelease 11.5ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤู	
	If lR5	
		@ 1.4,aPosGet[1][15] MSGET oNomeCli VAR cNomeCli OF oDlg WHEN .F. SIZE 120,10	
	Else
		@ 2.2,aPosGet[1][15] MSGET oNomeCli VAR cNomeCli OF oDlg WHEN .F. SIZE 120,10
	Endif
	oDlg:Refresh()
	SysRefresh()
	lRet := .T.
Else
	Help(" ",1,"REGNOIS")
	lRet := .F.
EndIf
	
If lRet .AND. aInfForn <> Nil
	aInfForn[1]	:= SA1->A1_NOME						// Nome
	aInfForn[2]	:= SA1->A1_TEL 						// Telefone
	aInfForn[3]	:= SA1->A1_PRICOM	    			//Primeira Compra
	aInfForn[4] := SA1->A1_ULTCOM      				//Ultima Compra
	aInfForn[5]	:= SA1->A1_END+" - "+SA1->A1_MUN	//Endereco
	aInfForn[6]	:= SA1->A1_EST         				//Estado
	aInfForn[7]	:= SA1->A1_CGC         				//cnpj
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณA800Produtoณ Autor ณArmando P. Waiteman   ณ Rev. ณ06.12.1999ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณValidacao do produto digitado                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณDicionario de Dados - Campo:LO_PRODUTO                      ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function A800Produto(cProduto)
Local aArea		:= GetArea()
Local lRet 		:= .T.
Local x         := 0
Local nPosTES   := aScan(aHeader, {|x| Alltrim(x[2]) == "LO_TES"})

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Funcao utilizada para verificar a ultima versao dos fontes      ณ
//ณ SIGACUS.PRW, SIGACUSA.PRX e SIGACUSB.PRX, aplicados no rpo do   |
//| cliente, assim verificando a necessidade de uma atualizacao     |
//| nestes fontes. NAO REMOVER !!!							        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
IF !(FindFunction("SIGACUS_V") .AND. SIGACUS_V() >= 20050512)
    Final("Atualizar SIGACUS.PRW !!!")
Endif
IF !(FindFunction("SIGACUSA_V") .AND. SIGACUSA_V() >= 20050512)
    Final("Atualizar SIGACUSA.PRX !!!")
Endif
IF !(FindFunction("SIGACUSB_V") .AND. SIGACUSB_V() >= 20050512)
    Final("Atualizar SIGACUSB.PRX !!!")
Endif

If ExistBlock("LJ800PROD")
   cProduto  := ExecBlock("LJ800PROD",.F.,.F.,{cProduto})
EndIf
dbSelectArea("SB1")
dbSetOrder(1)
If dbSeek(xFilial()+cProduto)
	For x:=1 to Len(aHeader)
		Do Case
			Case Trim(aHeader[x][2]) == "LO_UM"      	// Unidade de medida
				If  Empty(aCols[n][x])				
					aCols[n][x] := SB1->B1_UM
				Else
					aCols[n][x] := aCols[n][x]				
				EndIf
			Case Trim(aHeader[x][2]) == "LO_VUNIT"      	// Valor Unitario
				If  Empty(aCols[n][x])				
					aCols[n][x] := SB1->B1_PRV1
				Else
					aCols[n][x] := aCols[n][x]				
				EndIf	
			Case Trim(aHeader[x][2]) == "LO_LOCAL"   	// Local
				If Empty(aCols[n][x])
					aCols[n][x] := RetFldProd(SB1->B1_COD,"B1_LOCPAD")
				EndIf
			Case Trim(aHeader[x][2]) == "LO_SEGUM"   	// Segunda Unidade
				aCols[n][x] := SB1->B1_SEGUM
				A100SegUm()
			Case Trim(aHeader[x][2]) == "LO_TES"   	// TES
				aCols[n][x] := RetFldProd(SB1->B1_COD,"B1_TS")
		EndCase
	Next x
	If Ascan(aItensLay,{|x| x[1] == cProduto .AND. x[2] == aCols[n][nPosItem] }) == 0
	   MaFisAdd( aCols[n][nPosProd],;		// Produto
			     aCols[n][nPosTES],;		// Tes
			     aCols[n][nPosQtd],;		// Quantidade
			     aCols[n][nPosVlr],;		// Preco unitario
			     aCols[n][nPosVlDes],;   	// Valor do desconto
			     "",; 						// Numero da NF original
			     "",; 						// Serie da NF original
			     0,;						// Recno da NF original
			     0,; 						// Valor do frete do item
			     0,; 						// Valor da despesa do item
			     0,; 						// Valor do seguro do item
			     0,; 						// Valor do frete autonomo
			     aCols[n][nPosTotal],;		// Valor da mercadoria
			     0 )						// Valor da embalagem				
	   Aadd(aItensLay,{cProduto,aCols[n][nPosItem]})		     
    EndIf			     
Else
	Help("  ",1,"REGNOIS")
	lRet := .F.
EndIf

RestArea(aArea)
Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณA800VldComboณAutorณArmando P. Waiteman    ณ Data ณ06.01.2000ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณValidacao do Combo utilizado para o tipo de Frete.          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpC1 : Conteudo do Combo, ExpC2 : Valor do Frete           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณLOJA800                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function A800VldCombo(cTpFrete,	aValores)

If Substr(cTpFrete,1,1) == "F"
	aValores[FRETE] := 0
EndIf

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณA800VFold ณ Autor ณ Edson Maricate        ณ Data ณ 10.12.99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณExucuta o calculo de valores para campos Totalizadores.     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Referencia ( vide MATXFIS)                         ณฑฑ
ฑฑณ          ณ ExpC2 = Valor da Referencia                                ณฑฑ
ฑฑณ          ณ ExpL3 = .T./.F.- Executa o Refresh do folder               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Campos Totalizadores do MATA120                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function A800VFold(cReferencia,	xValor,	lRefre)
Local aArea	:= GetArea()

If lRefre==Nil
	lRefre := .T.
EndIf

If MaFisFound("NF")
	MaFisAlt(cReferencia,xValor)
	MaFisToCols(aHeader,aCols,,"LJ800")
	If lRefre
		Eval(bRefresh)
		Eval(bGDRefresh)
	EndIf
EndIf

RestArea(aArea)
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800Valor บAutor  ณArmando P. Waiteman บ Data ณ  03/08/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua recalculo de valores apartir da digitacao do descontoบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800Valor()

Local cCampo     :=ReadVar()
Local nValor     :=&(ReadVar())
Local lRet       := .T.
Local cProduto	 := ""
Local cLocal  	 := ""
Local nI         := 0

If nPosVlr * nPosTotal * nPosQtd == 0
	Aviso(STR0033) //"Um ou mais campos obrigatorios estao fora de uso. Verifique LO_VUNIT, LO_TOTAL, LO_QUANT"
	Return .F.
EndIf


Do Case
	Case cCampo == "M->LO_VALDESC" .OR. cCampo == "M->LO_DESC"
		If nPosVlDes * nPosDesc <> 0
			If cCampo == "M->LO_VALDESC"
			    If nValor >= aCols[n][nPosTotal] .OR. nValor < 0
			    	lRet := .F.
			    EndIf
			ElseIf cCampo == "M->LO_DESC"
				If nValor < 0
					lRet := .F.
				EndIf
			EndIf
		EndIf
	Case cCampo == "M->LO_VUNIT"
		If nValor < 0
			lRet:=.F.
		EndIf
	Case cCampo == "M->LO_TOTAL"
		If aCols[n][nPosVlr]*aCols[n][nPosQtd] <> nValor
			lRet:=.F.
		EndIf
	Case cCampo == "M->LO_QUANT" .OR. cCampo == "M->LO_LOCAL"
		If cCampo == "M->LO_LOCAL"
			nValor   := aCols[n][nPosQtd]
		Endif           
		
		If cCampo == "M->LO_LOCAL"		
			cLocal   := M->LO_LOCAL
		Else                                                                      
			cLocal   := aCols[n][nPosLocal] 
		EndIf                              
		cProduto := aCols[n][nPosProd]
		If (!(SB2->(DbSeek(xFilial("SB2")+cProduto+cLocal))) .or. (SaldoSb2()<nValor))
			Help("",1,"SALDOINSUL")
			lRet :=.F.
		EndIf
		If nValor < 0 
			lRet:=.F.
		EndIf

		//Soma a quantidade para o produto, em todas as linhas do aCols...
		If lRet
			For nI := 1 To Len(aCols)
				If !(aCols[nI][Len(aHeader)+1]) .AND. (nI <> n) .AND.;
				    (aCols[nI][nPosProd] == cProduto) .AND.;
				    (aCols[nI][nPosLocal] == cLocal)
				    
				    nValor += aCols[nI][nPosQtd]
				EndIf
			Next nI
            //Verifica se o produto possui saldo suficiente...
			If (SaldoSb2()<nValor)
				Help("",1,"SALDOINSUL")
				lRet:=.F.
			EndIf						
		EndIf
EndCase


SysRefresh()

Return lRet


/*
sÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800LinOk บAutor  ณArmando P. Waiteman บ Data ณ  03/08/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao para a vaidacao da linha da getdados                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800LinOk()
	
Local nPosPrd,nPosItem,nPosQt,nPosPrc,nPosTes,nPosLocal,nPosTotal
Local lRet := .T.
Local nx


For nx	:= 1 to Len(aHeader)
	Do Case
	Case AllTrim(aHeader[nx][2])=="LO_ITEM"
		nPosItem:= nx
	Case Alltrim(aHeader[nx][2])=="LO_PRODUTO"
		nPosPrd	:= nx
	Case AllTrim(aHeader[nx][2])=="LO_QUANT"
		nPosQt	:= nx
	Case Alltrim(aHeader[nx][2])=="LO_VUNIT"
		nPosPrc	:= nx
	Case AllTrim(aHeader[nx][2])=="LO_TES"
		nPosTes:= nx
	Case Alltrim(aHeader[nx][2])=="LO_LOCAL"
		nPosLocal:= nx
	Case AllTrim(aHeader[nx][2])=="LO_TOTAL"
		nPosTotal:= nx
	EndCase
Next

If (aCols[n][Len(aCols[n])])  // Verifica se esta deletado
	Return .T.
Else
	If lRet.AND.(Empty(aCols[n][nPosPrd]).OR. Empty(aCols[n][nPosTotal]);
 	.OR. Empty(aCols[n][nPosQt]) .OR. Empty(aCols[n][nPosPrc]) ;
	.OR. Empty(aCols[n][nPosTes]) .OR. Empty(aCols[n][nPosLocal]))
		Help(" ",1,"OBRIGAT")
		lRet := .F.
	EndIf
	If lRet .AND. Val(aCols[n][nPosTes]) <= 500
		lRet:=.F.
	EndIf
EndIf		

If !aCols[n][Len(aCols[n])] .AND. lRet .AND. ExistBlock("LJ800LOK")
	lRet := ExecBlock("LJ800LOK",.F.,.F.)
EndIf


Eval(bRefresh)

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800TudoK บAutor  ณMicrosiga           บ Data ณ  03/08/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao responsavel pela validacao de inclusao do Lay-Away  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800TudOk()

Local lRet 		:= .T.
Local nPerc		:= 0
Local nValor	:= 0
Local nVlPago	:= 0
Local nDecs     := 2
Local nValorMin := 0
Local aAreaMEO  := MEO->(GetArea()) 

// Verifica dados do cabecalho
lRet := a800CabOk()

If lRet .AND. ExistBlock("LJ800TOK")
	lRet  := Execblock("LJ800TOK",.F.,.F.)
EndIf

If cPaisLoc$"MEX|COL" .AND. lR5
	DbSelectArea("MEO")
	DbSetOrder(1)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se tem contrato associado, e valor minimo para gerar lay-awayณ
//ณe percentual de pagamento minimo.                                     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(cContrato) 
		If DbSeek( xFilial("MEO") + cContrato)
	   		nValorMin := MEO->MEO_VALMIN
	   		nPerc     := MEO->MEO_PAGINI
	   		If nValorMin == 0 
	   			nValorMin := 1 
	   		ElseIf nPerc == 0 
	   			nPerc	:= &(SuperGetMV("MV_LWVLINI"))
	   		EndIf
	   		MEO->(RestArea(aAreaMEO))
	   	EndIf			
	Else
		nValorMin := &(SuperGetMV("MV_LWVLMIN"))
		nPerc	:= &(SuperGetMV("MV_LWVLINI"))
	EndIf
Else
	nValorMin := &(SuperGetMV("MV_LWVLMIN"))
	nPerc	:= &(SuperGetMV("MV_LWVLINI"))
EndIf

// Verifica se o valor do lay-away esta abaixo do minimo ou se o valor e menor que o ja pago
If lRet .AND. (lInclui .OR. lAltera) .AND. aValores[TOTPED] < nValorMin
	HELP("",1,"VLMENOR")
	lRet := .F.
ElseIF lRet .AND. lAltera .AND. aValores[TOTPED] < SLO->LO_VALPAG
	HELP("",1,"PAGMAIOR")
	lRet := .F.
EndIf

// Verifica a necessidade de inclusao de novo pagto para aumento do valor na alteracao
If lRet .AND. lAltera
	dbSelectArea("SLO")
	dbSetOrder(1)
	dbSeek(xFilial("SLO")+cNumLay,.T.)

	nDecs   := MsDecimais(Max(SLO->LO_MOEDA,1))	
	nValor	:= a800Total(.F.)
	nVlPago	:= SLO->LO_VALPAG
    nValor  := Round(((nValor*nPerc)/100) - nVlPago - nVlPagto,nDecs)
	If  nValor > 0
		lRet := MsgYesNo(STR0065+ TRANSFORM(nValor,PesqPict("SLO","LO_VALPAG")) + STR0066 + STR0094,STR0067) //"Devera ser efetuado novo pagamento no valor de "###" devido ao acrescimo do valor do lay-away"###"Novo pagamento"
	EndIf
EndIf		

If lRet .AND. lDeleta    
    lRet := FWAuthSuper(__cUserId)                          
    If lRet
	   lRet := a800Deleta("SLO",Recno(),5)
	Else
		HELP("",1,"NOALOWED")   
	EndIf   
EndIf
Return lRet


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณA800Refreshณ Autor ณArmando P. Waiteman   ณ Data ณ 10.12.99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Executa o Refresh do Folder.                               ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Objeto a ser verificado.                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ loja800                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function A800Refresh(aValores)

Local aArea	:= GetArea()

aValores[VALMERC]	:= MaFisRet(,"NF_VALMERC")
aValores[VALDESC]	:= MaFisRet(,"NF_DESCONTO")
aValores[FRETE]		:= MaFisRet(,"NF_FRETE")
aValores[TOTPED]	:= MaFisRet(,"NF_TOTAL")
aValores[SEGURO]	:= MaFisRet(,"NF_SEGURO")
aValores[VALDESP]	:= MaFisRet(,"NF_DESPESA")
aValores[TOTF1]		:= aValores[VALDESP]+aValores[SEGURO]
aValores[TOTF3] 	:= aValores[FRETE]+aValores[SEGURO]+aValores[VALDESP]
aValores[IMPOSTOS]	:= aClone(MaFisRet(,"NF_IMPOSTOS"))


RestArea(aArea)

Return .T.


/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณA800FRefreณ Autor ณArmando P. Waiteman    ณ Data ณ 10.12.99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Executa o refresh nos objetos do array.                    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Array contendo os Objetos                          ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ loja800                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function A800FRefresh(aObj)
Local nx

For nx := 1 to Len(aObj)
	aObj[nx]:Refresh()
Next

Return .T.

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณA800CabOk ณ Autor ณArmando P. Waiteman    ณ Data ณ 10.12.99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Executa  as validacoes dos Gets.                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Objeto a ser verificado.                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ loja800                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function A800CabOk(oCond,	oCliente,	oLoja,	aRelImp)
Local lRet 	:= .T.

If (Empty(cNumLay) .OR. Empty(dEmissao) .OR. Empty(cCond) .OR. Empty(nMoeda);
	    .OR. Empty(dEntreg) .OR. Empty(cCliente) .OR. Empty(cLoja))
	    	Help("",1,"OBRIGAT")
			lRet := .F.
EndIf

Return lRet

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณA800Triggerณ Autor ณ Eveli Morasco        ณ Data ณ07.01.2000ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณSimula a validacao da GetDados para campos alterados pelo   ณฑฑ
ฑฑณ          ณgatilho                                                     ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณExpC1 = Campo alterado pelo gatilho                         ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณLOJA800                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function A800Trigger(cCampo)
Local nX
Local lRet		:= .T.
Local aArea 	:= GetArea()
Local nPosCpo	:= aScan(aHeader,{|x| AllTrim(x[2]) == AllTrim(cCampo) })

If nPosCpo > 0
	For nx	:= 1 to Len(aHeader)
		M->&(AllTrim(aHeader[nx][2])) := aCols[n][nx]
	Next
	If &(aHeader[nPosCpo][6])
		Eval(bRefresh)
	Else
		lRet := .F.
	EndIf
Else
	lRet := .F.
EndIf

RestArea(aArea)

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800Grava บAutor  ณArmando P. Waiteman บ Data ณ  03/14/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava dados do lay-away                                     บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA800                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800Grava(lNewItem,	aCampos,	lReserva)

Local nLin			:= 0
Local nLinha		:= 0
Local nCol  
Local aDados		:={} 
    
// Inicializa o array de trabalho de acordo dom a chamada da funcao
If ValType(aCampos) == "A"
	aDados:= aClone(aCampos)
Else
	aDados:= aClone(aCols)
EndIf

If (!lReserva) .OR. a800Reserva(!lNewItem,aDados)
	For nLin := 1 to Len(aDados)
		
		If aDados[nLin][Len(aDados[nLin])]
			Loop
		EndIf

	    RecLock("SLO",lNewItem)
		Replace SLO->LO_FILIAL  WITH xFilial("SLO")
		Replace SLO->LO_NUMLAY  WITH cNumLay
		Replace SLO->LO_EMISSAO WITH dEmissao
		Replace SLO->LO_DTENT   WITH dEntreg
		Replace SLO->LO_CLIENTE WITH cCliente
		Replace SLO->LO_LOJA    WITH cLoja
		Replace SLO->LO_COND    WITH cCond
		Replace SLO->LO_MOEDA   WITH nMoeda
		If cPaisLoc$"MEX|COL" .AND. lR5
			Replace SLO->LO_CODCON WITH cContrato 
	   	EndIf
		
		
		For nCol := 1 To Len(aHeader)
			If aHeader[nCol][10] # "V"
				Fieldput(FieldPos(aHeader[nCol][2]),aDados[nLin][nCol])
			EndIf
		Next
	
	    If nMoeda <> 1
	    	If !Empty(nTaxaMoeda) 
	    		Replace SLO->LO_TXMOEDA WITH nTaxaMoeda
	    	ElseIf SM2->(dbSeek(xFilial("SM2")+DTOC(dEmissao)))
	    		Replace SLO->LO_TXMOEDA WITH &("SM2->M2_MOEDA"+STR(nMoeda))
	    		nTaxaMoeda := SLO->LO_TXMOEDA
	    	Else
	    		Replace SLO->LO_MOEDA with 1
	    	EndIf
	    EndIf
	    		
	    Replace SLO->LO_TOTAL    WITH Round((SLO->LO_VUNIT*SLO->LO_QUANT)-SLO->LO_VALDESC,TamSX3("LO_TOTAL")[2])
		Replace SLO->LO_STATUS   WITH  "1"
	    
		// Descubro qual a linha correspondente no aCols para que o MAFISREF nao atualiza com erros.
		nLinha := aScan(aCols,{|x| x[nPosItem] == aDados[nLin][nPosItem]})		
		MaFisWrite(2,"SLO",nLinha)
	
	    MsUnLock()
	Next
	If !lAltera
		a800Titulo(1,0)	
    Endif
    A800Amarra()
EndIf

Return
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800ReservบAutor  ณArmando P. Waiteman บ Data ณ  03/14/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Cria registro de reserva no arquivo SC0. Usa rotina automa บฑฑ
ฑฑบ          ณtica.(Caso nao consiga reservar todos os item solicita      บฑฑ
ฑฑบ          ณsolicita intervencao do usuario                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800Reserva(lAltera,	aCampos)

Local aAreaSLP		:= {}
Local nLin			:= 0
Local lRetorno    	:= .T.
Local aReserva    	:= {}
Local aOperacao   	:= Array(5)
Local aLote       	:= {"","","",""}
Local cReserva    	:= ""
Local cProduto    	:= ""
Local aItens		:= {}
Local nOperacao		:= 0 
Local nPosaCols		:= 0

If lAltera
	aItens := aClone(aCampos)
	nOperacao := 2
Else
             
	If ValType(aCampos) == "A"	
		aItens := aClone(aCampos)
	Else                                                                     
		aItens := aClone(aCols)
	EndIf                      
	nOperacao := 1
EndIf


// Tenta efetuar todas as reservas para depois iniciar a gravacao
For nLin := 1 to Len(aItens)
	If !(aItens[nLin][Len(aItens[nLin])])
		cProduto := aItens[nLin][nPosProd]
		cLocal   := aItens[nLin][nPosLocal]
		nQuant   := aItens[nLin][nPosQtd]                      
		cItem    := aItens[nLin][nPosItem]
		aOperacao := {nOperacao,"LW",cNumLay,STR0094+cNumLay+"-"+cItem,xFilial("SLO")} //"LAYAWAY: "
		aLote    := IIF(nPosNumLote>0,{aItens[nLin,nPosNumLote],aItens[nLin,nPosLoteCtl],aItens[nLin,nPosLocaliz],aItens[nLin,nPosSerie]},{"","","",""})

		// Caso seja uma alteracao devo encontrar o numero da reserva para a funcao a430Reserva
		If lAltera
			dbSelectArea("SLP")
			aAreaSLP := GetArea()
			dbSetOrder(5)
			dbSeek(xFilial("SLP")+cNumLay+"1"+cItem)
			cReserva := SLP->LP_RESERVA
			RestArea(aAreaSLP)
		EndIf
		
		IF a430Reserva(aOperacao,cReserva,cProduto,cLocal,nQuant,aLote)
			// Caso tenha feito a reserva adiciona no array para controle
			AADD(aReserva,{aOperacao,SC0->C0_NUM,cProduto,cLocal,nQuant,aLote})
            IIf(!lAltera,AADD(aAmarras,{"1",cNumLay,cItem,cCliente,cLoja,SC0->C0_PRODUTO,SC0->C0_LOCAL,SC0->C0_NUM}),)
       	Else
			// Caso falhe algum item, solicita intervencao do usuario para a gravacao ou nao
			If !(MsgYesNo(STR0035 + cProduto +STR0036+CHR(10)+CHR(13); //"O produto "###" nao sera gravado pois nao foi possivel efetuar reserva."
						+STR0037)) //"Deseja continuar?"
				// Seleciona o cancelamento saio do looping e passo a fazer estorno de reserva
				lRetorno := .F.
				Exit
			Else
				If lInclui
					// Se for inclusao e desejar continuar eu deleto este item do aCols para que nao seja feita a sua gravacao
					If ValType(aCampos) == "A"
						// Caso esteja executando a inclusao via aCampos descubro qual a linha equivalente no aCols
						nPosaCols := aScan(aCols,{|x| x[nPosItem] == aItens[nLin][nPosItem]})
					Else
						nPosaCols := nLin
					EndIf
						
					aCols[nPosaCols][Len(aCols[nPosaCols])] := .T.
				Else
					// Caso seja alteracao eu simplesmente retorno falso para que a a800grava nใo efetive a gravacao das alteracoes
					lRetorno := .F.
				EndIf
			EndIf
		EndIf
	EndIf		
Next

If !lRetorno .AND. !lAltera
	For nLin := 1 To Len(aReserva)
		aOperacao[1] := 3
		aOperacao[2] := aReserva[nLin][1][2]
		aOperacao[3] := aReserva[nLin][1][3]
		aOperacao[4] := aReserva[nLin][1][4]
		aOperacao[5] := aReserva[nLin][1][5]
		
		a430Reserva(aOperacao,aReserva[nLin][2],aReserva[nLin][3],aReserva[nLin][4],aReserva[nLin][5],aReserva[nLin][6])
	    aAmarras:= {}
	Next
EndIf

Return lRetorno

/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณA800Legendณ Autor ณArmando P. Waiteman    ณ Data ณ 01.02.99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria uma janela contendo a legenda da mBrowse              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ LOJA800                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function A800Title()

Private aCores  := {{"LO_STATUS=='1'",'ENABLE' },;		//Lay-Away em Andamento
				     {"LO_STATUS=='2'",'DISABLE'},;		//Law-Away Encerrado
				     {"LO_STATUS=='3'",'BR_AMARELO'},;	    //Lay-Away Vencido
				     {"LO_STATUS=='4'",'BR_CINZA'}}        //Lay-Away Excluido/Cancelado

BrwLegenda(cCadastro,STR0007,{	{"ENABLE",STR0094 + STR0038}    ,; //"Legenda"###"Lay-Away em Andamento"
		{"DISABLE",STR0094 + STR0039}   ,; //"Lay-Away Encerrado"
		{"BR_AMARELO",STR0094 + STR0040},; //"Lay-Away Vencido"
		{"BR_CINZA",STR0094 + STR0041}} ) //"Lay-Away Excluido/Cancelado"
                                                                                                	
Return .T.


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA800   บAutor  ณArmando P.Waiteman  บ Data ณ  03/17/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz validacoes iniciais da rotina                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800Valida()

Local lRetorno      :=.T.


// Descobre as posicoes relevantes do aCols
nPosProd  := aScan(aHeader, {|x| Alltrim(x[2]) == 'LO_PRODUTO'})
nPosLocal := aScan(aHeader, {|x| Alltrim(x[2]) == 'LO_LOCAL'  })
nPosVlr   := aScan(aHeader, {|x| Alltrim(x[2]) == 'LO_VUNIT'  })
nPosTotal := aScan(aHeader, {|x| Alltrim(x[2]) == 'LO_TOTAL'  })
nPosVlDes := aScan(aHeader, {|x| Alltrim(x[2]) == 'LO_VALDESC'})
nPosDesc  := aScan(aHeader, {|x| Alltrim(x[2]) == 'LO_DESC'   })
nPosQtd   := aScan(aHeader, {|x| Alltrim(x[2]) == 'LO_QUANT'  })
nPosItem  := aScan(aHeader, {|x| Alltrim(x[2]) == 'LO_ITEM'   })

nPosNumLote := aScan(aHeader, {|x| Alltrim(x[2]) == "LO_NUMLOTE"})
nPosLoteCtl := aScan(aHeader, {|x| Alltrim(x[2]) == "LO_LOTECTL"})
nPosLocaliz := aScan(aHeader, {|x| Alltrim(x[2]) == "LO_LOCALIZ"})
nPosSerie   := aScan(aHeader, {|x| Alltrim(x[2]) == "LO_SERIE"  })



// Valida a existencia dos campos obrigatorios
If nPosProd * nPosLocal * nPosQtd * nPosVlr * nPosTotal * nPosItem == 0
	MsgAlert(STR0042+CHR(10)+CHR(13)+; //"Um ou mais campos obrigatorios nao estao em uso."
			 "       LO_PRODUTO        "+"LO_LOCAL"+CHR(10)+CHR(13)+;
			 "       LO_QUANT          "+"LO_VUNIT"+CHR(10)+CHR(13)+;
			 "       LO_TOTAL          "+"LO_ITEM")
	lRetorno := .F.
EndIf

// Caso o usuario deseje usar lote, deve ter todos os campos em uso.
If nPosNumLote + nPosLoteCtl + nPosLocaliz + nPosSerie <> 0
	If nPosNumLote * nPosLoteCtl * nPosLocaliz * nPosSerie == 0
		MsgAlert(STR0043+CHR(10)+CHR(13)+; //"Para uso do Lote todos os campos devem estar em uso."
				 "           LO_NUMLOTE    "+"LO_LOTECTL"+CHR(10)+CHR(13)+;
				 "           LO_LOCALIZ    "+"LO_SERIE"+CHR(10)+CHR(13))
		lRetorno := .F.
	EndIf
EndIF

If cPaisLoc$"EUA|POR"

	// Valida a parametrizacao para o Lay-Away      
	If !(SED->(dbSeek(xFilial("SED")+ &(SuperGetMV("MV_LWNATE1")))))
		MsgAlert(STR0044) //"A natureza definida no parametro MV_LWNATE1 nao existe. Favor verificar"
		lRetorno := .F.
	EndIf

	If !(SE4->(dbSeek(xFilial("SE4")+SuperGetMV("MV_LWCOND"))))
		MsgAlert(STR0045) //"A condicao de pagto definida no paramentro MV_LWCOND nao existe. Favor verificar"
		lRetorno:=.F.	
	EndIf
	
EndIf

Return lRetorno


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800amarraบAutor  ณArmando P. Waiteman บ Data ณ  03/17/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a gravacao das amarras no SLP                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA800                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function a800Amarra()


Local nLin 		:= 0
Local aArea		:= {}

aArea := GetArea()

For nLin := 1 to Len(aAmarras)
	Reclock("SLP",.T.)
	If aAmarras[nLin][1] == "1"
		Replace LP_FILIAL   With xFilial("SLP")
		Replace LP_TPAMAR  	With aAmarras[nLin][1]
		Replace LP_NUMLAY  	With aAmarras[nLin][2]
		Replace LP_ITEM    	With aAmarras[nLin][3]
		Replace LP_CLIENTE 	With aAmarras[nLin][4]
		Replace LP_LOJA    	With aAmarras[nLin][5]
		Replace LP_PRODUTO 	With aAmarras[nLin][6]
		Replace LP_LOCAL   	With aAmarras[nLin][7]
		Replace LP_RESERVA	With aAmarras[nLin][8]
	ElseIf aAmarras[nLin][1] == "2"
		Replace LP_FILIAL	With xFilial("SLP")
		Replace LP_TPAMAR	With aAmarras[nLin][1]
		Replace LP_NUMLAY	With aAmarras[nLin][2]
        Replace LP_CLIENTE	With aAmarras[nLin][3]
        Replace LP_LOJA		With aAmarras[nLin][4]
        Replace LP_PREFIXO	With aAmarras[nLin][5]
        Replace LP_NUME1	With aAmarras[nLin][6]
        Replace LP_PARCELA	With aAmarras[nLin][7]
        Replace LP_TIPOE1	With aAmarras[nLin][8]
	ElseIf aAmarras[nLin][1] == "3"
		Replace LP_FILIAL	With xFilial("SLP")
		Replace LP_TPAMAR	With aAmarras[nLin][1]
		Replace LP_NUMLAY	With aAmarras[nLin][2]
        Replace LP_CLIENTE	With aAmarras[nLin][3]
        Replace LP_LOJA		With aAmarras[nLin][4]
        Replace LP_NUML1	With aAmarras[nLin][5]
        Replace LP_ITEML1	With aAmarras[nLin][6]
        Replace LP_PRODUTO	With aAmarras[nLin][7]
        Replace LP_LOCAL	With aAmarras[nLin][8]
        Replace LP_ITEM		With aAmarras[nLin][9]
	EndIf 
	MsUnlock()
Next
// Limpa o array para que nใo se repita essa grava็ใo
aAmarras := {}

RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800TituloบAutor  ณArmando P. Waiteman บ Data ณ  03/17/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGera titulo de recebimento antecipado no financeiro         บฑฑ
ฑฑบ          ณpara futura compensacao.                                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800Titulo(nOperacao,	nValor,	aNumLay)
      
// nOperacao ira definir que tipo de titulo deverei incluir onde:
// 1 = Titulo de pagto inicial
// 2 = Inclusao de pagtos do Lay-Away
// 3 = Inclusao de titulo referente a cancelamento do layaway(faz a compensacao automatica) 
// 4 = Inclusao de novo pagto inicial devido a aumento do valor do layaway.(Alteracao)
// 5 = Compensacao dos titulos devido a entrega dos produtos ou cancelamento da venda

Local aVetor 		:= {}
Local aArea			:= {}
Local nVlCruz		:= 0
Local nValTit       := 0
Local nParcSLO		:= 0
Local cParcela      := ""
Local cTipo			:= ""
Local cHist			:= ""
Local dVencto		:= ""
Local dEmiss		:= ""
Local cPref  		:= If(nOperacao==5,SE1->E1_PREFIXO,&(SuperGetMV("MV_LWPREF1")))
Local cNatureza 	:= If(nOperacao==5,SE1->E1_NATUREZA,&(SuperGetMV("MV_LWNATE1")))
Local nPercIni      := 0                               											 //Recebe valor percentual do pagamento minimo
Local cNumTit		:= If(nOperacao==5,"",cNumLay+Space(TamSx3("E1_NUM")[1]-Len(cNumLay)))
Local cUltParcela   := ""
Local nMoedTit		:= 0
Local nDecimais     := TamSX3("E1_VALOR")[2]
Local aAreaSLP      := {}
Local nTamE5Parc    := TamSX3("E5_PARCELA")[1]													//Tamanho do campo
Local aAreaMEO      := MEO->(GetArea())   

Private cBCOAUTO	:= ""
Private cAGEAUTO	:= ""
Private cCTAAUTO	:= ""
Private nVlrComp    := 0 
Private lMsErroAuto := .F.                            											//Retorna se o ExecAuto gerou erro.

DEFAULT aNumLay     := {}

aArea := GetArea()

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se tem contrato associado, recebe percentual de pagamento inicialณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

If cPaisLoc$"MEX|COL" .AND. lR5
	If nOperacao<>5
		If !Empty(SLO->LO_CODCON) 
			DbSelectArea("MEO")
			DbSetOrder(1)
			If DbSeek(xFilial("MEO")+SLO->LO_CODCON)
				nPercIni := MEO->MEO_PAGINI
				If nPercIni == 0 
					nPercIni := &(SuperGetMV("MV_LWVLINI"))
				EndIf
				MEO->(RestArea(aAreaMEO))
			EndIf	
		Else 
		    nPercIni := &(SuperGetMV("MV_LWVLINI"))
		EndIf	
	EndIf
Else
   If nOperacao<>5
   		nPercIni := &(SuperGetMV("MV_LWVLINI"))					
   EndIf		
EndIf

Do Case
	Case nOperacao == 1 .OR. nOperacao == 4
		cTipo 	:= "RA "
		dVencto := dEntreg
		dEmiss	:= dEmissao
		cHist	:= cFormaPg+"-"+IIf(Trim(cFormaPg)$"CC|CD",Substr(cCartao,1,3)+"-","")+STR0046 + STR0094 //"Recebimento por Lay-Away"
		cParcela:= "0"
		nParcSLO := 0
		nMoedTit:= nMoeda
		CBCOAUTO:= xNumCaixa()
		CCTAAUTO:= ".         "
		CAGEAUTO:= ".    "
		If nPagtoIni == 0
			// Calcula o valor total do lay-away
			nValor := A800Total(.T.)
			// Tendo o valor total do Lay-Away, posso aplicar o percentual de pagto inicial
			nValTit := Round((nValor * nPercIni) / 100,nDecimais)
			
			If nOperacao == 4
				// Caso seja uma alteracao do lay-away subtrai o valor ja pago
			    nValTit := nValTit - nValPago
			    dEmiss	:= dDatabase    
			    nParcSLO := SLO->LO_NUMPARC + 1
			EndIf			    	
 		Else
			nValTit := nPagtoIni
		EndIf

		If nMoedTit <> 1
			nVlCruz := xMoeda(nValtit,nMoedTit,1,nTaxaMoeda)
		EndIf
	Case nOperacao == 2
		cTipo 	:= "RA "
		dVencto := DataValida(dDataBase)
		dEmiss	:= dDataBase
		cHist	:= cFormaPg+"-"+IIf(Trim(cFormaPg)$"CC|CD",Substr(cCartao,1,3)+"-","")+STR0046 + STR0094 //"Recebimento por Lay-Away"
		nMoedTit:= nMoeda
		cParcela:= Transform(SLO->LO_NUMPARC+1,"@!")
		nParcSLO:= 1
		nValTit	:= nValor
		CBCOAUTO:= xNumCaixa()
		CCTAAUTO:= ".         "
		CAGEAUTO:= ".    "
	Case nOperacao == 3
		cTipo 	:= "NF "
		dVencto := dDataBase
		dEmiss	:= dDataBase
		cHist	:= STR0047 + STR0095 + cNumLay //"Canc.LayAway n."
		cParcela:= "1"
		nParcSLO:= 1
		nMoedTit:=SLO->LO_MOEDA
		nValTit := nValor
		CBCOAUTO:= xNumCaixa()
		CCTAAUTO:= ".         "
		CAGEAUTO:= ".    "
	Case nOperacao == 5
		// Faz a compensacao dos titulos a receber quando da venda balcao
        
		// Variaveis para o FINA330
		MV_PAR01 := 1			//Considera Loja  Sim/Nao          	  
		MV_PAR02 := 1         	//Considera Cliente     Original/Outros
		If FunName() == "LOJA701"
		   MV_PAR03 := M->LQ_CLIENTE	// Do Cliente                            
		   MV_PAR04 := M->LQ_CLIENTE	// Ate Cliente   		
		Else
		   MV_PAR03 := oCliente:cText	// Do Cliente                            
		   MV_PAR04 := oCliente:cText	// Ate Cliente   
		EndIf   
		MV_PAR05 := 1 			// Compensa Titulos Transferidos S/[N]  
		MV_PAR06 := 2 			// Calcula Comissao sobre valores de NCC 
		MV_PAR07 := 2			// Mostra Lancto Contabil       
		MV_PAR08 := 2			// Considera abatimentos para compensar
	    MV_PAR10 := 1 			//Considera Filiais abaixo              		
	    MV_PAR11 := '  '
	    MV_PAR12 := 'ZZ'  
	    	    
		nTamTit := TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]
		nTamTip := TamSX3("E1_TIPO")[1]
		nTamLoj := TamSX3("E1_LOJA")[1]
		cLote   := ""
		nVlrComp    := nValor
		
		// Chama a funcao de compensacao
		dbSelectArea("SE1")
		Fa330Comp("SLO",,,,"","LOJA800",aNumLay)
		
		nValTit := 0 // Zera o valor de nValtit para que nao seja executada nenhuma outra operacao
EndCase			


If Round(nValTit,nDecimais) > 0
    aAreaSLP      := SLP->(GetArea())
	DBSelectArea("SLP")
	DBSetOrder(1)   
	DbSeek(xFilial()+cNumLay+"2")                                                   
	If Found()   //Busca a ultima parcela
	   While !Eof() .AND. cNumLay == SLP->LP_NUMLAY .AND. SLP->LP_TPAMAR == "2"	         
	   	  cUltParcela  := SLP->LP_PARCELA
	      DbSkip()
	   End   
	   cParcela     := Soma1(cUltParcela)      

	   DBSelectArea("SE5")  //Verifica no SE5 se o registro jah naum estah gravado
	   DBSetOrder(7)                                                      
	   While DbSeek(xFilial("SE5") + cPref + Padr(AllTrim(cNumLay),TamSX3("E5_NUMERO")[1]) + PadR(cParcela,nTamE5Parc)+cTipo)
	      cParcela  := Soma1(cParcela)      
	   End	   
	EndIf
	RestArea(aAreaSLP)
	
	// Monta o array com as informacoes para a gravacao do titulo
	aVetor  := {	{"E1_PREFIXO"	,cPref						,Nil},;
					{"E1_NUM"	  	,cNumTit 					,Nil},;
					{"E1_PARCELA" 	,cParcela					,Nil},;
					{"E1_TIPO"	 	,cTipo						,Nil},;
					{"CBCOAUTO"	 	,CBCOAUTO					,Nil},;
					{"CAGEAUTO"	 	,CAGEAUTO					,Nil},;
					{"CCTAAUTO"	 	,CCTAAUTO					,Nil},;
					{"E1_NATUREZ" 	,cNatureza					,Nil},;
		          	{"E1_CLIENTE" 	,cCliente					,Nil},;
	             	{"E1_LOJA"	  	,cLoja						,Nil},;
		          	{"E1_EMISSAO" 	,dEmiss 					,Nil},;
			       	{"E1_VENCTO"  	,dVencto 					,Nil},;
			       	{"E1_VENCREA" 	,DataValida(dVencto)		,Nil},;
			       	{"E1_HIST" 		,cHist						,Nil},;
			       	{"E1_MOEDA" 	,nMoeda						,Nil},;
					{"E1_ORIGEM"	,"LOJA800"					,Nil},;
					{"E1_FLUXO"		,"S"						,Nil},;
				   	{"E1_VALOR"	  	,nValTit					,Nil }}
	// Se a moeda for diferente de um adiciona o valor em moeda 1 para ter a taxa da inclusao do titulo
	If nMoeda <> 1
		nVlCruz	:= nValTit / nTaxaMoeda
		aAdd(aVetor,{"E1_VLCRUZ"	,nVlCruz					,Nil })
	EndIf

	MsAguarde({||	MSExecAuto({|x,y| Fina040(x,y)},aVetor,3)},STR0092,STR0093) //#"Aguarde..."#"Gerando Titulo"#

	// Se for uma exclusao. Faz a compensacao do contas a receber
	If nOperacao == 3
		// Inicializa as variaveis para o FINA330
		MV_PAR01 := 1			//Considera Loja  Sim/Nao          	  
        MV_PAR02 := 1         	//Considera Cliente     Original/Outros
		MV_PAR03 := cCliente  	// Do Cliente                            
		MV_PAR04 := cCliente	// Ate Cliente   
		MV_PAR05 := 1 			// Compensa Titulos Transferidos S/[N]  
		MV_PAR06 := 2 			// Calcula Comissao sobre valores de NCC 
		MV_PAR07 := 2			// Mostra Lancto Contabil       
		MV_PAR08 := 2			// Considera abatimentos para compensar
	    MV_PAR10 := 2 			//Considera Filiais abaixo              		
	    MV_PAR11 := '  '
	    MV_PAR12 := 'ZZ'
	    MV_PAR13 := 2 			// Calcula Comissao sobre valores de RA
	    	
		nTamTit := TamSX3("E1_PREFIXO")[1]+TamSX3("E1_NUM")[1]+TamSX3("E1_PARCELA")[1]
		nTamTip := TamSX3("E1_TIPO")[1]
		nTamLoj := TamSX3("E1_LOJA")[1]
		cLote   := ""
		
		Fa330Comp("SLO",,,,"","LOJA800")
	EndIf
EndIf
	
If lMsErroAuto .AND. nValTit > 0
	Alert(STR0048) //"Nao foi possivel efetuar a inclusao de titulo de pagto. Por favor faca a inclusao manual"
	MostraErro()
Else
	If nValTit > 0 .AND. nOperacao <> 3
		aAdd(aAmarras,{"2",cNumLay,cCliente,cLoja,cPref,cNumTit,cParcela,cTipo})
		a800ValPag(cNumLay,nParcSLO,nValTit)
	ElseIf nOperacao == 4 .AND. nValTit < 0 
		a800AddPag(cNumLay)
	EndIf
Endif

If ExistBlock("LJ800TIT")
	Execblock("LJ800TIT",.F.,.F.)
EndIf

RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800VldNumบAutor  ณArmando P. Waiteman บ Data ณ  03/18/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida o numero de lay-away digitado                        บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800VldNum()

Local lRet      := .T.
Local aArea		:= {}
Local aAreaSLO	:= {}

FreeUsedCode()
aArea := GetArea()
dbSelectArea("SLO")
aAreaSLO := GetArea()
dbSetOrder(1)
If dbSeek(xFilial("SLO")+cNumLay,.T.) .OR. !MayIUseCode("SLO"+xFilial("SLO")+cNumLay)
	lRet := .F.
	Help("",1,"EXISTLAY")
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800TxMoed Autor  ณArmando P. Waiteman บ Data ณ  03/18/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a leitura da Taxa da moeda diferenciada                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800TxMoeda()

Local oDlg

Define MSDIALOG oDlg From 50,250 TO 200,480 TITLE STR0050 PIXEL  //"Taxa de Moeda"
@ 005,005  To 062,110 OF oDlg PIXEL
@ 012,010 SAY  STR0051  Of oDlg PIXEL //"Taxa :"
@ 012,060 MSGET oTaxa Var nTaxaMoeda PICTURE PesqPict("SM2","M2_TXMOED2") Of oDlg PIXEL

DEFINE  SButton FROM 044,50 TYPE 1 Action (oDlg:End() ) ENABLE OF oDlg  PIXEL
DEFINE  SButton FROM 044,80 TYPE 2 Action (nTaxaMoeda := 0 , oDlg:END()) ENABLE OF oDlg PIXEL

Activate MSDialog oDlg

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800PagtosบAutor  ณArmando P. Waiteman บ Data ณ  03/18/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta a tela de apresentacao de plano de pagtos             บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function a800Pagtos()

Local oDlg 
Local oLbx
Local oPagIni
Local oEntreg
Local cCondicao 	:= cCond
Local cPagtos       := ""
Local cFormaAnt     := cFormaPg
Local aCab    		:= {}
Local aColunas		:= {}
Local nTamData  	:= Max(TamSX3("E1_VENCREA")[1],32)
Local nTamValor 	:= Max(TamSX3("E1_VALOR")[1],(90-nTamData))
Local aSizes		:= {nTamData,nTamValor}
Local bLine			:= { || {aColunas[oLBx:nAT][1],Transform(aColunas[oLBx:nAT][2],Tm(aColunas[oLbx:nAT][2],16,MSDecimais(1)))}}
Local bRefreshList 	:= {||(aColunas := a800Cond(lPagto),oLbx:SetArray(aColunas),oLbx:bLine:=bLine,oLbx:Refresh())}
Local nOpc			:= 0
Local nPgOri		:= 0
Local nPgIniOri		:= 0
Local nDecs   		:= 2       
Local nValParc      := 0
Local lPrim         := Trim(cFormaPg)==SuperGetMV("MV_SIMB1")  //Determina se e a primeira vez que acessa esta tela
Local nPagIni       := 0                                       // Valor de pagamento Inicial
Local aAreaMEO      := MEO->(GetArea())   


Private dDtEnt    	:= dEntreg

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se tem contrato associado, recebe valor de pagamento inicialณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cPaisLoc$"MEX|COL" .AND. lR5
	If !Empty(SLO->LO_CODCON) 
		DbSelectArea("MEO")
		DbSetOrder(1)
		If DbSeek(xFilial("MEO")+SLO->LO_CODCON)
			nPagIni := MEO->MEO_PAGINI
			If nPagIni == 0 
				nPagIni := &(SuperGetMV("MV_LWVLINI"))		
			EndIf
			MEO->(RestArea(aAreaMEO))
		EndIf	
	Else
		nPagIni := &(SuperGetMV("MV_LWVLINI"))	
	EndIf
Else
	nPagIni := &(SuperGetMV("MV_LWVLINI"))							
EndIf
          
DEFINE FONT oFnt1  NAME "Ms Sans Serif" 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณSugere o valor a ser pago quando for alteracaoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SLO->(dbSetOrder(1))
SLO->(dbSeek(xFilial("SLO")+cNumLay))

If lAltera
	nSaldo    		:= a800Total(.F.) - a800TotPg()
	If Empty(nVlPagto) .OR. nVlPagto < 0
		nVlPagto 	:= ((a800Total(.F.)*nPagIni)/100)-a800TotPg()
		If nVlPagto < 0
			nVlPagto := 0
		EndIf
	EndIf       	
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGuarda o conteudo inicial das variaveis de pagamento inicial e atualณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
nPgIniOri := nPagtoIni
nPgOri	  := nVlPagto

aCab := {STR0052,STR0053} //"Data"###"Valor"

aColunas := a800Cond(!lInclui)

If lPrim
   A800LerCC("CC")    //Preencher o array de Administradoras Financeiras
EndIf

DEFINE MSDIALOG oDlg FROM 82,23 TO 325,465 TITLE STR0013 OF oMainWnd PIXEL //"Plano de Pagto"
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRelease 11.5ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤู	
If lR5 

	@ 0.3,01 SAY STR0013 OF oDlg //"Plano de Pagto"
	@ 0.8,01 MSGET oCond VAR cCond Picture PesqPict("SLO","LO_COND") F3 CpoRetF3("LO_COND") When (lInclui .OR. lAltera) Valid CheckSX3("LO_COND",cCond) .AND. Eval(bRefreshList) OF oDlg
	@ 1.8,01 SAY STR0017 OF oDlg //"Entrega"
	@ 2.3,01 MSGET oEntreg VAR dDtEnt Picture PesqPict("SLO","LO_DTENT") When (lInclui .OR. lPagto) Valid CheckSX3("SLO",dDtEnt) .AND. Eval(bRefreshList) OF oDlg 
	@ 3.3,01 SAY STR0054 OF oDlg //"Pagto Inicial"
	@ 3.8,01 MSGET oPagIni VAR nPagtoIni Picture PesqPict("SLO","LO_VALPAG") When (lInclui) Valid a800Vld(1) .AND. Eval(bRefreshList) OF oDlg SIZE 70,08
	@ 4.8,01 SAY STR0078 OF oDlg FONT oFnt1 COLOR CLR_HBLUE  //"Forma pagto."   	  
	@ 5.3,01 MSGET cFormaPg PICTURE "@!" VALID A800VldForma() .AND. A800Forma() F3 "24" WHEN (lInclui .OR. lPagto) SIZE 30,08 OF oDlg 
	       
	@ 4.8,5 SAY oSayCC VAR STR0080  //Administradora:
	@ 5.3,5 MSCOMBOBOX oComboCC VAR cCartao ITEMS aCartoes WHEN (IIf(Len(aCartoes) > 1,.T.,.F.)); 
	      SIZE 80,40 OF oDlg 
	
	If lPrim .OR. !(Trim(cFormaPg)$"CC|CD")
	   A800Forma()  //Esconde os objetos de cartao de credito/debito
	EndIf   
	
	If lPagto .OR. lAltera
		@ 6.3,01 Say STR0068 OF oDlg //"Valor do Pagamento"
		@ 6.8,01 MSGET oPagto VAR nVlPagto Picture PesqPict("SLO","LO_VALPAG") Valid a800Vld(4) .AND. Eval(bRefreshList) SIZE 70,08 OF oDlg
	EndIf
	// Cria lista com as parcelas
	oLbx := TWBrowse():New( 0.8, 15,98,90,,aCab,aSizes,oDlg,,,,,,,,,,,, .F.,, .F.,, .F.,,, )
Else
	@ 1,01 SAY STR0013 OF oDlg //"Plano de Pagto"
	@ 1.5,01 MSGET oCond VAR cCond Picture PesqPict("SLO","LO_COND") F3 CpoRetF3("LO_COND") When (lInclui .OR. lAltera) Valid CheckSX3("LO_COND",cCond) .AND. Eval(bRefreshList) OF oDlg
	@ 2.5,01 SAY STR0017 OF oDlg //"Entrega"
	@ 3,01 MSGET oEntreg VAR dDtEnt Picture PesqPict("SLO","LO_DTENT") When (lInclui .OR. lPagto) Valid CheckSX3("SLO",dDtEnt) .AND. Eval(bRefreshList) OF oDlg 
	@ 4,01 SAY STR0054 OF oDlg //"Pagto Inicial"
	@ 4.5,01 MSGET oPagIni VAR nPagtoIni Picture PesqPict("SLO","LO_VALPAG") When (lInclui) Valid a800Vld(1) .AND. Eval(bRefreshList) OF oDlg SIZE 70,08
	@ 5.5,01 SAY STR0078 OF oDlg FONT oFnt1 COLOR CLR_HBLUE  //"Forma pagto."   	  
	@ 6,01 MSGET cFormaPg PICTURE "@!" VALID A800VldForma() .AND. A800Forma() F3 "24" WHEN (lInclui .OR. lPagto) SIZE 30,08 OF oDlg 
	       
	@ 5.5,5 SAY oSayCC VAR STR0080  //Administradora:
	@ 6,5 MSCOMBOBOX oComboCC VAR cCartao ITEMS aCartoes WHEN (IIf(Len(aCartoes) > 1,.T.,.F.)); 
	      SIZE 80,40 OF oDlg 
	
	If lPrim .OR. !(Trim(cFormaPg)$"CC|CD")
	   A800Forma()  //Esconde os objetos de cartao de credito/debito
	EndIf   
	
	If lPagto .OR. lAltera
		@ 7,01 Say STR0068 OF oDlg //"Valor do Pagamento"
		@ 7.5,01 MSGET oPagto VAR nVlPagto Picture PesqPict("SLO","LO_VALPAG") Valid a800Vld(4) .AND. Eval(bRefreshList) SIZE 70,08 OF oDlg
	EndIf
	// Cria lista com as parcelas
	oLbx := TWBrowse():New( 1.5, 15,100,90,,aCab,aSizes,oDlg,,,,,,,,,,,, .F.,, .F.,, .F.,,, )
EndIf

oLBx:SetArray(aColunas)
oLbx:bLine := bLine

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||(IIf(A800VldForma(),(nOpc := 1,oDlg:End()),Nil))},{||cFormaPg := cFormaAnt,nOpc:=0,oDlg:End()})


If nOpc == 1
	If lPagto
		a800Titulo(2,nVlPagto)
		a800Amarra()
		nValParc  :=  nVlPagto 
		nVlPagto := 0
		cCond := cCondicao
	    nDecs       := MsDecimais(Max(SLO->LO_MOEDA,1))		
		nSaldo		:= Round(a800Total(.T.) - SLO->LO_VALPAG,nDecs)
		nVlPago		:= SLO->LO_VALPAG
	ElseIf lAltera
		nPagtoIni := nVlPagto
	Else
		dEntreg:=dDtEnt
		nValParc  :=  nPagtoIni
	EndIf
Else
	nVlPagto  := nPgOri
	nPagtoIni := nPgIniOri
	cCond     := cCondicao   
EndIf

cPagtos := cFormaPg+"-"

If Trim(cFormaPg)$"CC|CD"
	cPagtos += cCartao
EndIf
If ExistBlock("LJ800PGTO")
	Execblock("LJ800PGTO",.F.,.F.,{nValParc,cPagtos})
EndIf

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800Cond  บAutor  ณArmando P. Waiteman บ Data ณ  03/19/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a explosao do valor em parcelas de acordo com o plano deบฑฑ
ฑฑบ          ณpagtos                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800Cond(lGravado)

Local aArea		:= {}
Local aPagtos   := {}
Local cCondicao 	:= IIf(lGravado .AND. !lPagto,SLO->LO_COND, cCond)
Local dDataIni		:= dDataBase
Local nPercIni      := 0                                           //Recebe percentual de pagamento Inicial
Local nValor    	:= 0
Local cReneg        := 0
Local nAcres        := 0
Local nDesc         := 0
Local cForma        := ""
Local aReneg        := {}
Local aAreaMEO      := MEO->(GetArea())   

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se tem contrato associado, e recebe valor do percentual de pagamento inicialณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cPaisLoc$"MEX|COL" .AND. lR5
	If !Empty(SLO->LO_COND) 
		DbSelectArea("MEO")
		DbSetOrder(1)
		If DbSeek(xFilial("MEO")+SLO->LO_CODCON)
			nPercIni := MEO->MEO_PAGINI 
			If nPercIni == 0 
				nPercIni := &(SuperGetMV("MV_LWVLINI"))		
			EndIf
			MEO->(RestArea(aAreaMEO))
		EndIf	
	Else
		nPercIni := &(SuperGetMV("MV_LWVLINI"))	
	EndIf
Else
	nPercIni := &(SuperGetMV("MV_LWVLINI"))							
EndIf

// Caso o valor tenha sido alterado desde a ultima montagem recalcula o valor a ser pago
If !lPagto .AND. nValorOrig <> aValores[VALMERC]
	nPagtoIni:=0
	nValorOrig := aValores[VALMERC]
EndIf

// Calcula o valor a ser parcelado e inicializa o valor do pagto inicial
nTotal		:= a800Total(lPagto)
nPagtoIni	:= IIf(lGravado,SLO->LO_VALPAG,IIf(nPagtoIni==0 .AND. lInclui,(nTotal * nPercIni)/100,nPagtoIni))
nValor    	:= nTotal - nPagtoIni

If lPagto
	nValor := nValor - nVlPagto
EndIf

aArea := GetArea()

// Cria array com as parcelas
If !lPagto
	aPagtos := Condicao(nValor,cCondicao,,dDataIni)
Else
	aPagtos	:= PlanPgt(nValor,(dDataIni+30),dDtEnt)
EndIf

 Return aPagtos

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800Total บAutor  ณMicrosiga           บ Data ณ  03/19/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTotaliza o valor do lay-away                                บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function a800Total(lGravado)

Local nValor	:= 0
Local nX
Local aArea 	:= {}
Local aAreaSLO 	:= {}
Local aTesInf 	:= {}

aArea:= GetArea()

If lGravado
	// Roda o arquivo SLO para totalizar o valor do Lay-Away
	dbSelectArea("SLO")
	aAreaSLO:=GetArea()      
	dbSetOrder(1)
	dbSeek(xFilial("SLO")+cNumLay)
	While !Eof() .AND. LO_FILIAL+LO_NUMLAY == xFilial("SLO")+cNumLay
		nValor:= nValor + LO_TOTAL + LO_FRETE + LO_DESPESA - LO_VALDESC
		// Soma os impostos do item
		aTesInf  := TesImpInf(SLO->LO_TES)
		For nX := 1 to Len(aTesInf)
		   If aTesInf[nX][3] == "1"  //Verifica se o imposto incide no valor do layaway
		      nValor := nValor + &("SLO->LO_"+Substr(aTesInf[nX][2],4,7))
		   EndIf
		Next nX		
		dbSkip()
	End
	RestArea(aAreaSLO)
Else
	// Utiliza o total existente no rodape
	nValor := MaFisRet(,"NF_TOTAL")
EndIf


RestArea(aArea)
Return nValor


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800VLd   บAutor  ณArmando P. Waiteman บ Data ณ  03/20/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a liberacao ou nao de acordo com senha de usuario       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function a800Vld(nSituacao)

Local lRet 		:= .T.
Local nDecimais := TamSX3("E1_VALOR")[2]
Local nValMin   := 0                      //Indica Valor minimo para gerar Lay-Away(Manejo de Apartados)
Local aAreaMEO  := MEO->(GetArea())   

If cPaisLoc$"MEX|COL" .AND. lR5
	If !Empty(SLO->LO_CODCON) //Verifica se tem contrato associoado
		DbSelectArea("MEO")
		DbSetOrder(1)
		If DbSeek(xFilial("MEO")+SLO->LO_CODCON)
			nValMin := MEO->MEO_PAGINI
			If nValMin == 0 //Verifica se campo foi preenchido no contrato
				nValMin := &(SuperGetMV("MV_LWVLINI"))
			EndIf
			MEO->(RestArea(aAreaMEO))
		EndIf	
	Else
		nValMin := &(SuperGetMV("MV_LWVLINI"))	
	EndIf
Else
	nValMin := &(SuperGetMV("MV_LWVLINI"))							
EndIf

Do Case
	Case nSituacao == 1
		If nPagtoIni > nTotal
			HELP("",1,"PAGMAIOR")
			lRet := .F.
		EndIf
		
		If nPagtoIni < 0 
			lRet := .F.
		Endif
		
		If lRet .AND. nPagtoIni < (nTotal * nValMin/100) 
			lRet := a800Senha()
		EndIF
	Case nSituacao == 2
		If nVlMulta < 0
			lRet := .F.
		Else	
			If nVlMulta < nVlMltOri
				lRet := a800Senha()
			EndIf
		Endif	
		If lRet
			nPercMulta := Round((nVlMulta/nBase)*100, TamSx3("LO_DESC")[2])
		EndIf
	Case nSituacao == 3
	    If nPercMulta < 0 
	    	lRet := .F.
	    Else	
			If Round((nBase * nPercMulta)/100,TamSx3("LO_TOTAL")[2]) < nVlMltOri
				lRet := a800Senha()
			EndIf
		Endif	
		If lRet
			nVlMulta := Round((nBase * nPercMulta)/100,TamSx3("LO_TOTAL")[2])
		EndIf
	Case nSituacao == 4
		If nVlPagto > nSaldo
			HELP("",1,"PAGMAIOR")
			lRet := .F.
		EndIf
		
		If nVlPagto < 0 
			lRet := .F.
		Endif
		
		If lRet .AND. nPagtoIni < Round((nTotal * nValMin/100),nDecimais)
			lRet := FWAuthSuper(__cUserId)
		EndIF
	//Data de emissao
	Case nSituacao == 5
		If Empty(dEmissao) .OR. (!Empty(dEntreg) .AND. dEmissao > dEntreg)
			lRet := .F.
		EndIf
	//Data de entrega
	Case nSituacao == 6
		If Empty(dEntreg) .OR. dEntreg < dDataBase .OR. dEntreg < dEmissao
			lRet := .F.
		EndIf
EndCase	

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800VldSenบAutor  ณArmando P. Waiteman บ Data ณ  03/20/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida a senha digitada para alteracoes no lay-away         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800VldSenha(cUser,cSenha)

Local lRet	:= .T.

// Verifica se o usuario digitado, tem permissao de alteracao de lay-away
If !(AllTrim(cUser)$AllTrim(SuperGetMv("MV_LWUSERS")))
	HELP("",1,"NOALOWED")
	lRet:=.F.
EndIf

// Pesquisa no arquivo de senhas o usuario e valida a senha digitada
If lRet
	PswOrder(2)
	PswSeek(cUser,.T.)
	If !PswName(cSenha)
		HELP("",1,"INVSENHA")
		lRet := .F.
	EndIf
EndIf

Return lRet


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800ValPagบAutor  ณArmando P. Waiteman บ Data ณ  03/20/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณAtualiza o valor total ja pago e o numero de parcelas       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800ValPag(cNumLay,	nParcela,	nValor)

Local aArea	   := {}
Local aAreaSLO := {}

aArea:=GetArea()

DbSelectArea("SLO")
aAreaSLO:= GetArea()
DbSetOrder(1)
dbSeek(xFilial("SLO")+cNumLay,.T.)
While !EOF() .AND. xFilial("SLO")+cNumLay == LO_FILIAL + LO_NUMLAY
	RecLock("SLO",.F.)
	If LO_VALPAG > 0
	   Replace LO_VALPAG With LO_VALPAG+nValor
	Else
	   Replace LO_VALPAG With nValPago+nValor
	EndIf   
	Replace LO_NUMPARC With LO_NUMPARC + nParcela
  	MsUnLock()
  	dbSkip()
End

RestArea(aAreaSLO)
RestArea(aArea)

Return

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณa800Del   ณ Autor ณ Armando P. Waiteman   ณ Data ณ 26.11.99 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Critica a delecao da linha                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณParametrosณ ExpC1 = Objeto a ser verificado.                           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ LOJA800                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
/*/
Function A800Del()
Local lRet      := .T.
Local nPosProd  := aScan(aHeader,{|x| Trim(x[2])=="LO_PRODUTO"})
Local lAlt      := .F.                                                    //verifica se pode deletar linha, conforme contrato

If Empty(aCols[n][nPosProd])
	lRet := .F.
EndIf

If FindFunction( "a800Modi")
	lAlt := a800Modi()
EndIf	

If lAltera .AND. !lAlt
	lRet := .F.
EndIf

If lRet
	aAreaSLO := SLO->(GetArea())
	aArea	 := GetArea()
	dbSelectArea("SLO")
	dbSetOrder(1)
	If dbSeek(xFilial("SLO")+cNumLay+aCols[n][nPosItem])
	If SLO->LO_QUJE <> 0 
		lRet := .F.
		HELP("",1,"ENTREG")
	ElseIf SLO->LO_STATUS <> "1"
		lRet := .F.
		HELP("",1,"NOEXCLLAY")
		EndIf
	EndIf
	RestArea(aAreaSLO)
	RestArea(aArea)
EndIf

If lRet
	MaFisDel(n,aCols[n][Len(aCols[n])])
	Eval(bRefresh)
EndIf

Return lRet

	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800AlteraบAutor  ณArmando P. Waiteman บ Data ณ  03/21/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a gravacao das alteracoes do layaway                 บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800Altera()

Local aArea 	:= {}
Local aAreaSLO	:= {}
Local aLinha	:= {}
Local aDel		:= {}
Local nLin		:= 0
Local nX		:= 0
nVlPagto		:= 0

aArea:=GetArea()

dbSelectArea("SLO")
aAreaSLO := GetArea()
dbSetOrder(1)

// Trata as alteracoes
For nLin := 1 To Len(aCols)
	// Verifica se esta deletado e em caso negativo faz a gravacao
	If !(aCols[nLin][Len(aCols[nLin])])
	
		// Clona a linha para tratamento especial nas rotinas de gravacao
		aLinha := {}
		AADD(aLinha,aCols[nLin]) 

		If dbSeek(xFilial("SLO")+cNumLay+aCols[nLin][nPosItem])
			If aCols[nLin][nPosProd] <> SLO->LO_PRODUTO
				For nX:=1 to Len(aHeader)
					AADD(aDel,&(aHeader[nX][2]))
				Next
				a800Deleta("SLO",nLin,3)
				a800Grava(.T.,aLinha,.T.)
			ElseIf aCols[nLin][nPosQtd] <> SLO->LO_QUANT
				// Caso tenha alterado a quantidade faz a gravacao verificando a reserva
				a800Grava(.F.,aLinha,.T.)
			Else
				// Caso nao tenha alterado a quantidade faz a gravacao sem alterar reserva
				a800Grava(.F.,aLinha,.F.)
			EndIf
		Else
			// Trata-se de um item novo. Deve ser feita a gravacao do mesmo como uma inclusao
			a800Grava(.T.,aLinha,.T.)
		EndIf
	ElseIf dbSeek(xFilial("SLO")+cNumLay+aCols[nLin][nPosItem])
		// Trata dos itens que foram excluidos
		a800Deleta(.T.,nLin,3)
	EndIF
Next

// Verifica a necessidade de criacao de novo titulo de pagto inicial devido ao acrescimo
// no valor do layaway
a800Titulo(4,0)
A800Amarra()

RestArea(aAreaSLO)
RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800DeletaบAutor  ณMicrosiga           บ Data ณ  03/21/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Deleta o item do lay-away                                  บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800Deleta(lAltera,	nItem,	nOpcx)

Local oDlg
Local aArea		:= {}
Local aAreaSLP	:= {}
Local aAreaSLO	:= {}
Local aAreaMEO  := MEO->(GetArea())   
Local aBase		:= {}
Local aOperacao := Array(5)
Local aLote		:= {"","","",""}
Local lRet		:= .T.
Local lPerMlt	:= .T.
Local dEntreg	:= ""
Local cMulta	:= ""
Local cValMul   := ""
Local cPref		:= ""
Local cNumTit   := ""
Local cCodClie  := ""
Local cLojClie  := ""
Local nOpc		:= 0
Local nTotal	:= 0
Local nPago 	:= 0
Local nMulta    := 0
Local dEmissao	:= 0
Local nResta	:= 0
Private cBase	   := ""
Private nBase	   := 0
Private nVlMltOri  := 0
Private nPercMulta := 0  


// Define a opcao em uso
lInclui	:= (aRotina[nOpcx][4] == 3)
lAltera	:= (aRotina[nOpcx][4] == 4)
lDeleta	:= (aRotina[nOpcx][4] == 6)
lVisual	:= (aRotina[nOpcx][4] == 2)


aArea 		:= GetArea()
aAreaSLP	:= SLP->(GetArea())
aAreaSLO	:= SLO->(GetArea())

// Posiciona o SLO
dbSelectArea("SLO")
dbSetOrder(1)
dbSeek(xFilial("SLO")+cNumLay,.T.)

// Ponto de entrada para possivel regravacao de campo referente a multa
If ExistBlock("LJ800MLT") // Deve retornar array onde: aBase[1]==Valor Base, aBase[2]==Nome para o calculo
	aBase := Execblock("LJ800MLT",.F.,.F.)
	nBase := aBase[1]
	cBase := aBase[2]
EndIf

If !lAltera
		If cPaisLoc$"MEX|COL".AND. lR5

			If !Empty(SLO->LO_CODCON) //Verifica se tem contrato associoado
				DbSelectArea("MEO")
				DbSetOrder(1)
				If DbSeek(xFilial("MEO")+SLO->LO_CODCON)
					nPercMulta 	:= MEO->MEO_PORMUL //Porcentagem da Multa
		        	nVlMulta 	:= MEO->MEO_VALMUL //Valor da Multa
		        EndIf	

		        If nPercMulta == 0 .AND. nVlMulta == 0  //Utiliza os valores do parametro

		        	// Descobre a string para calculo da multa
					cMulta := SuperGetMv("MV_LWVLMLT")

					// Descobre o tipo de calculo default para a multa (percentual ou valor)
					lPerMlt := (SubStr(cMulta,1,1)=="%") // Caso seja .T. e por %

					// Caso seja calculo por percentual descobre o valor base para aplicacao da aliquota
	    			nBase := IIF(Empty(nBase),&(SuperGetMV("MV_LWBSMLT")),nBase)

					// Define a descricao da base a ser mostrada na tela
	   				cBase := IIF(Empty(cBase),RetTitle(SuperGetMV("MV_LWBSMLT"),12),cBase)

					If lPerMlt
		   				// Descobre o percentual de multa
						nPercMulta := Val(SubStr(cMulta,2,Len(cMulta)-1))
		   				// Calcula a multa
		   				nVlMulta:= Round((nBase * nPercMulta)/ 100,TamSX3("LO_TOTAL")[2])
		   				// Guarda o valor em outra variavel para a validacao
		   				nVlMltOri := nVlMulta 
	   				Else
						nVlMulta:= &(cMulta)
						// Guarda o valor em uma variavel auxiliar para a validacao
						nVlMltOri := nVlMulta
					EndIf 
		        
		        ElseIf nPercMulta <> 0 .AND. nVlMulta == 0 //Utiliza % da multa
		        	
		        	// Caso seja calculo por percentual descobre o valor base para aplicacao da aliquota
	    			nBase := SLO->LO_VALPAG
					// Define a descricao da base a ser mostrada na tela
	   				cBase := IIF(Empty(cBase),RetTitle(SuperGetMV("MV_LWBSMLT"),12),cBase)    
		        	
		   			// Calcula a multa
		   			nVlMulta:= Round((nBase * nPercMulta)/ 100,TamSX3("LO_TOTAL")[2])
		   			// Guarda o valor em outra variavel para a validacao
		   			nVlMltOri := nVlMulta
		   			 			
		        ElseIf nPercMulta == 0 .AND. nVlMulta <> 0 //Utiliza Valor p/ Multa
		        	
					// Define a descricao da base a ser mostrada na tela
	   				cBase := IIF(Empty(cBase),RetTitle(SuperGetMV("MV_LWBSMLT"),12),cBase)  
		        	
					// Guarda o valor em uma variavel auxiliar para a validacao
					nVlMltOri := nVlMulta
					
		        EndIf 
		    
		    MEO->(RestArea(aAreaMEO))
		        
			Else
			
				// Descobre a string para calculo da multa
				cMulta := SuperGetMv("MV_LWVLMLT")

				// Descobre o tipo de calculo default para a multa (percentual ou valor)
				lPerMlt := (SubStr(cMulta,1,1)=="%") // Caso seja .T. e por %
			
				// Caso seja calculo por percentual descobre o valor base para aplicacao da aliquota
	    		nBase := IIF(Empty(nBase),&(SuperGetMV("MV_LWBSMLT")),nBase)
				// Define a descricao da base a ser mostrada na tela
	   			cBase := IIF(Empty(cBase),RetTitle(SuperGetMV("MV_LWBSMLT"),12),cBase)    
	   		
	   			If lPerMlt
		   			// Descobre o percentual de multa
					nPercMulta := Val(SubStr(cMulta,2,Len(cMulta)-1))
		   			// Calcula a multa
		   			nVlMulta:= Round((nBase * nPercMulta)/ 100,TamSX3("LO_TOTAL")[2])
		   			// Guarda o valor em outra variavel para a validacao
		   			nVlMltOri := nVlMulta 
	   			Else
					nVlMulta:= &(cMulta)
					// Guarda o valor em uma variavel auxiliar para a validacao
					nVlMltOri := nVlMulta
				EndIf      
			
			EndIf
				
		Else
			
			// Descobre a string para calculo da multa
			cMulta := SuperGetMv("MV_LWVLMLT")

			// Descobre o tipo de calculo default para a multa (percentual ou valor)
			lPerMlt := (SubStr(cMulta,1,1)=="%") // Caso seja .T. e por %
			
			// Caso seja calculo por percentual descobre o valor base para aplicacao da aliquota
	    	nBase := IIF(Empty(nBase),&(SuperGetMV("MV_LWBSMLT")),nBase)
			// Define a descricao da base a ser mostrada na tela
	   		cBase := IIF(Empty(cBase),RetTitle(SuperGetMV("MV_LWBSMLT"),12),cBase)    
	   		
	   		If lPerMlt
		   		// Descobre o percentual de multa
				nPercMulta := Val(SubStr(cMulta,2,Len(cMulta)-1))
		   		// Calcula a multa
		   		nVlMulta:= Round((nBase * nPercMulta)/ 100,TamSX3("LO_TOTAL")[2])
		   		// Guarda o valor em outra variavel para a validacao
		   		nVlMltOri := nVlMulta 
	   		Else
				nVlMulta:= &(cMulta)
				// Guarda o valor em uma variavel auxiliar para a validacao
				nVlMltOri := nVlMulta
			EndIf		
		    
	    EndIf
	    
	// Inicializa variaveis com informacoes a serem apresentadas na tela de confirmacao de multa
	nTotal 		:= a800Total(.F.)
	dEmissao 	:= SLO->LO_EMISSAO
	nPago       := SLO->LO_VALPAG
	dEntreg		:= SLO->LO_DTENT
	nResta		:= (nTotal - nPago)
	
	Define MSDIALOG oDlg From 100,100 to 380,480 TITLE STR0055 + STR0094 OF oMainWnd PIXEL //"Cancelamento de Lay-Away"
	@ 0.8,02 Say STR0024 + STR0094 OF oDLG  //"Total do Lay-Away"
	@ 0.8,15 Say STR0015 OF oDlg //"Emissao"
	@ 1.3,02 MSGET oValTot VAR nTotal When .F. Picture PesqPict("SLO","LO_TOTAL") SIZE 055,009 OF oDlg 
	@ 1.3,15 MSGET oEmissao VAR dEmissao When .F. Picture PesqPict("SLO","LO_EMISSAO") OF oDlg
	@ 2.3,02 Say STR0056 OF oDLG  //"Total Pago"
	@ 2.3,15 Say STR0017 //"Entrega"
	@ 2.8,02 MSGET oValPag VAR nPago When .F. Picture PesqPict("SLO","LO_VALPAG") SIZE 055,009 OF oDlg
	@ 2.8,15 MSGET dEntreg VAR dEntreg When .F.  Picture PesqPict("SLO","LO_DTENT") OF oDlg
	@ 04, 02 Say STR0057 OF oDlg //"Saldo"
	@ 04, 15 Say STR0058 OF oDlg //"Base para Multa"
	@ 4.5,15 MSGET oBase VAR nBase When .F. PicTure PesqPict("SLO","LO_VALPAG") SIZE 055,009 OF oDlg
	@ 4.5,02 MSGET oResto VAR nResta When .F. Picture PesqPict("SLO","LO_VALPAG") SIZE 055,009 OF oDlg
	@ 5.8,02 Say STR0059 + AllTrim(cBase) OF oDlg //"Valor usado como base de multa: "
	@ 6.8,02 Say STR0060 OF oDLG  //"Informe o valor/percentual de multa a ser aplicado"
	@ 7.7,02 Say STR0061 OF oDlg //"Valor: "
	@ 7.7,04 MSGET oValor VAR nVlMulta Valid (a800Vld(2)) .AND. oDlg:Refresh() Picture PesqPict("SLO","LO_VALPAG") SIZE 055,009 OF oDlg
	@ 7.7,14 Say STR0062 Of oDlg //"Percentual:"
	@ 7.7,18 MSGET oPerc  VAR nPercMulta Valid (a800Vld(3)) .AND. oDlg:Refresh() Picture "@E 999,99" SIZE 040,009 OF oDlg 
	@ 0.3,01 To 06, 23 LABEL '' OF oDlg
    @ 06, 01 To 8.2,23 LABEL '' OF oDlg
    DEFINE  SButton FROM 120,125 TYPE 1 Action (nOpc:=1,oDlg:End() ) ENABLE OF oDlg  
	DEFINE  SButton FROM 120,155 TYPE 2 Action (nOpc:=0,oDlg:END() ) ENABLE OF oDlg 
    ACTIVATE MSDIALOG oDLG
    

    If nOpc == 1
		// Verifica se ha algum item que impossibilite a gravacao	    
		While lRet .AND. xFilial("SLO")+cNumLay == SLO->LO_FILIAL+SLO->LO_NUMLAY
			If SLO->LO_QUJE > 0
				lRet := .F.		
				HELP("",1,"ENTREG")
			ElseIf SLO->LO_STATUS <> "1"
				lRet := .F.
				HELP("",1,"NOEXCLLAY")
			EndIf
			
			SLO->(dbSkip())
		End
		
		// Inicia a exclusao dos registros
		If lRet
		    // Chave de pesquisa do SLP
			cChaveSLP := xFilial("SLP")+cNumLay
		
			// Exclui reserva
			dbSelectArea("SLP")
			dbSetOrder(1)
			dbSeek(cChaveSLP+"1")
			While !Eof() .AND. cChaveSLP+"1" == SLP->LP_FILIAL+SLP->LP_NUMLAY+SLP->LP_TPAMAR
				aOperacao 	:= {3,"PD",LP_NUMLAY,STR0094+LP_NUMLAY+"-"+LP_ITEM,xFilial("SLO")}	 //"LAYAWAY: "
				cReserva	:=	LP_RESERVA
				cProduto	:=	LP_PRODUTO
				cLocal		:=	LP_LOCAL
				nQuant		:=	0 // Nao preciso passar a quantidade pois a a430Reserva pega do SC0
				a430Reserv(aOperacao,cReserva,cProduto,cLocal,nQuant,aLote,"PD",LP_NUMLAY,cUserName,xFilial("SLO"))
				SLP->(dbSkip())
			End       
			
			// Faz a inclusao de um titulo tipo NF para cobrar o valor da multa
			a800Titulo(3,nVlMulta)			
			
			// Limpa as amarracoes
			dbSelectArea("SLP")
			dbSetOrder(1)
			dbSeek(cChaveSLP,.T.)
			While !Eof() .AND. cChaveSLP == SLP->LP_FILIAL+SLP->LP_NUMLAY
				//Realiza a Baixa dos recebimentos do Lay-Away. Gerando
				//um movimento de saida no arquivo SE5.
				If (SLP->LP_TPAMAR == "2") .AND. (SLP->LP_TIPOE1 == "RA ")
					cPref    := SLP->LP_PREFIXO
					cNumTit  := SLP->LP_NUME1
					cCodClie := SLP->LP_CLIENTE
					cLojClie := SLP->LP_LOJA					
					a800BxAut(cPref,cNumTit,cNumLay,cCodClie,cLojClie)
				EndIf

				RecLock("SLP",.F.,.T.)
				dbDelete()
				MsUnLock()
				dbSkip()
			End       
		
		
			// Grava status de cancelado no SLO
			dbSelectArea("SLO")
			dbSeek(xFilial("SLO")+cNumLay,.T.)
			While !EOF() .AND. xFilial("SLO")+cNumLay == SLO->LO_FILIAL+SLO->LO_NUMLAY
				RecLock("SLO",.F.)
				Replace SLO->LO_STATUS with "4"
				MsUnLock()
				dbSkip()
			End
		Endif
	EndIf
Else

	// Exclui reserva do item
	cChaveSLP := xFilial("SLP")+cNumLay+"1"+aCols[nItem][nPosItem]
	
	dbSelectArea("SLP")
	dbSetOrder(5)
	dbSeek(cChaveSLP)
	While !Eof() .AND. cChaveSLP == SLP->LP_FILIAL+SLP->LP_NUMLAY+"1"+SLP->LP_ITEM
		aOperacao 	:= {3,"PD",LP_NUMLAY,STR0094+LP_NUMLAY+"-"+LP_ITEM,xFilial("SLO")}	 //"LAYAWAY: "
		cReserva	:=	LP_RESERVA
		cProduto	:=	LP_PRODUTO
		cLocal		:=	LP_LOCAL
		nQuant		:=	0 // Nao preciso passar a quantidade pois a a430Reserva pega do SC0
		a430Reserv(aOperacao,cReserva,cProduto,cLocal,nQuant,aLote,"PD",LP_NUMLAY,cUserName,xFilial("SLO"))
		
		// Depois de excluํda a reserva, faz a delecao do registro no SLP
		RecLock("SLP",.F.,.T.)
		dbDelete()
		MsUnLock()
		
		SLP->(dbSkip())
	End
	
	// Faz a exclusao do Item no SLO
	dbSelectArea("SLO")
	dbSetOrder(1)
	dbSeek(xFilial("SLO")+cNumLay+aCols[nItem][nPosItem])
	RecLock("SLO",.F.,.T.)
	dbDelete()
	MsUnlock()
EndIf			

RestArea(aAreaSLO)
RestArea(aAreaSLP)
RestArea(aArea)

Return (nOpc==1)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800Senha บAutor  ณArmando P. Waiteman บ Data ณ  03/20/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a liberacao ou nao de acordo com senha de usuario       บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function a800Senha()

Local oDlg1
Local lRet 		:= .F.
Local cUser		:= Space(15)
Local cSenha	:= Space(20)

DEFINE MSDIALOG oDlg1 FROM 200,250 TO 300,450 TITLE STR0063 OF oMainWnd PIXEL //"Senha"
@ 0.5,01 SAY STR0064 SIZE 78,17 OF oDlg1 //"Usuario"
@ 1.2,01 MSGET oUser VAR cUser OF oDlg1 SIZE 55,08
@ 2.0,01 SAY STR0063 OF oDlg1 //"Senha"
@ 2.7,01 MSGET oPass VAR cSenha PASSWORD OF oDlg1  SIZE 55,08
DEFINE SBUTTON FROM 15,65 TYPE 1 ACTION {||(If(a800VldSenha(cUser,cSenha),(lRet:=.T.,oDlg1:End()),lRet:=.F.))} ENABLE OF oDlg1
DEFINE SBUTTON FROM 30,65 TYPE 2 ACTION {||(lRet:=.F.,oDlg1:End())} ENABLE OF oDlg1
ACTIVATE MSDIALOG oDlg1

Return lRet



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800Paga  บAutor  ณArmando P. Waiteman บ Data ณ  03/26/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRotina para a inclusao de pagamentos e consulta da posicao  บฑฑ
ฑฑบ          ณfinanceira do layaway                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800Paga(cAlias,	nReg,	nOpcx)

Local oDlg
Local oFnt
Local oLbx
Local aColunas:= {}
Local aCab		:= {}
Local aSizes	:= {}
Local aButtons	:= {}
Local bLine			:= {||{aColunas[oLBx:nAT][1],Transform(aColunas[oLBx:nAT][2],PesqPict("SE1","E1_NUM")),aColunas[oLbx:nAt][3],aColunas[oLbx:nAt][4],aColunas[oLbx:nAt][5],Transform(aColunas[oLbx:nAt][6],PesqPict("SE1","E1_VALOR"))}}
Local bRefreshList 	:= {||(aColunas := a800MontPg(),oLbx:SetArray(aColunas),oLbx:bLine:=bLine,oLbx:Refresh())}
Local bVldDialog := {||(lPagto := .F.,.T.)}

Local aSizeAut 	:= MsAdvSize()							// Tamanho da tela. 
Local aObjects 	:={}									// Posicao da Tela
Local aInfo  	:={}									// Posicao da Tela
Local aPosObj 	:={}									// Posicao da Tela

Private nSaldo	:= 0
Private nVlPago	:= 0

nVlPagto := 0
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a opcao em usoณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
lInclui	:= (aRotina[nOpcx][4] == 3)
lAltera	:= (aRotina[nOpcx][4] == 4)
lDeleta	:= (aRotina[nOpcx][4] == 6)
lVisual	:= (aRotina[nOpcx][4] == 2)
lPagto := .T.
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Define a fonte para exibicao do nome do Clienteณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DEFINE FONT oFnt  NAME "Arial" SIZE 07,12 BOLD
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis ja declaradas so necessitam ser inicializadasณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
cNumLay := SLO->LO_NUMLAY
dEmissao:= SLO->LO_EMISSAO
dEntreg := SLO->LO_DTENT
cCliente:= SLO->LO_CLIENTE
cLoja	:= SLO->LO_LOJA
nMoeda	:= SLO->LO_MOEDA
nTotal	:= a800Total(.T.)
cCond	:= SLO->LO_COND
nVlPago	:= a800TotPg()
nSaldo	:= (nTotal-nVlPago)
If cPaisLoc$"MEX|COL" .AND. lR5
	cContrato := SLO->LO_CODCON
EndIf
               
If !(VldOpc800(.T.))
	Return
Endif	

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta o array com os botoes de funcao da EnchoiceBarณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aButtons := {{'EXCLUIR' ,{||  (a800ExcTit(oLbx:aArray[oLbx:nAt][1],oLbx:aArray[oLbx:nAt][2],oLbx:aArray[oLbx:nAt][3],oLbx:aArray[oLbx:nAt][4],oLbx:aArray[oLbx:nAt][6]),Eval(bRefreshList)),nVlPago:=SLO->LO_VALPAG,nSaldo:=a800Total(.T.)-nVlPago},STR0069},;  //"Exclui Pagamento"
			{'EDIT',{||  (a800Pagtos(),Eval(bRefreshList),cFormaPg:=Padr(SuperGetMV("MV_SIMB1"),3),cCartao:="")},STR0067 }}   //"Novo pagamento" 			 
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Acrescenta a barra de botoes a funcao de impressao para o relatorio somente se o mesmo existirณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If FindFunction("U_LJ800RLT")
	AADD(aButtons,{"S4WB005N",{|| ( U_LJ800RLT(cNumLay) ) },STR0070}) //"Imprime Recibo"
EndIf 


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Variaveis usadas pela funcao twBrowse (ListBox) ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aCab 	:= {RetTitle("E1_PREFIXO"),RetTitle("E1_NUM"),RetTitle("E1_PARCELA"),RetTitle("E1_TIPO"),RetTitle("E1_EMISSAO"),RetTitle("E1_VALOR")}

aAdd(aSizes,Max(Len(aCab[1]),TamSx3("E1_PREFIXO")[1])*4.1)
aAdd(aSizes,Max(Len(aCab[2]),TamSx3("E1_NUM")[1])    *4.1)
aAdd(aSizes,Max(Len(aCab[3]),TamSx3("E1_PARCELA")[1])*4.1)
aAdd(aSizes,Max(Len(aCab[4]),TamSx3("E1_TIPO")[1])   *4.1)
aAdd(aSizes,Max(Len(aCab[5]),TamSx3("E1_EMISSAO")[1])*4.1)
aAdd(aSizes,Max(Len(aCab[6]),TamSx3("E1_VALOR")[1])  *4.1)
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Posiciona arquivosณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
SLO->(dbSeek(xFilial("SLO")+cNumLay,.T.))
SA1->(dbSeek(xFilial("SA1")+cCliente+cLoja))
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Preenche o array com os pagtos efetuados ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aColunas := a800MontPg()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Se nao houver pagtos nao abre a consulta/Valido p/ Por		   ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
If cPaisLoc$"EUA|POR"
	If Len(aColunas) == 0 
		HELP("",1,"NOPAGTO")
		Return
	EndIf
EndIf


//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Preserva o ambienteณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aArea	 := GetArea()
aAreaSLO := SLO->(GetArea())
aAreaSA1 := SA1->(GetArea())
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Monta Dialog da consultaณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณRelease 11.5ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤู	
If lR5	   
	// Calcula as posicoes da tela
	aObjects := {}
	AADD(aObjects,{100,100,.T.,.T.})
	AADD(aObjects,{315,035,.T.,.T.})
	
	aInfo 	:= {aSizeAut[1],aSizeAut[2],aSizeAut[3],aSizeAut[4],3,3}
	aPosObj := MsObjSize(aInfo,aObjects,.T.)        
	
	DEFINE MSDIALOG oDLG FROM aSizeAut[7],0 TO aSizeAut[6],aSizeAut[5] OF oMainWnd PIXEL	
	
	@ 0.3 , 001 Say RetTitle("LO_CLIENTE") of oDlg
	@ 0.8 , 001 MSGET oCliente VAR cCliente When .F. Picture PesqPict("SLO","LO_CLIENTE") OF oDlg
	
	@ 0.3 , 006 Say RetTitle("LO_LOJA") of oDlg
	@ 0.8 , 006 MSGET oLoja VAR cLoja When .F. Picture PesqPict("SLO","LO_LOJA") OF oDlg
	
	@ 001 , 008 Say SA1->A1_NOME OF oDlg FONT oFnt COLOR CLR_HBLUE    
	
	@ 0.3 , 020 Say RetTitle("LO_NUMLAY") of oDlg	
	@ 0.8 , 020 MSGet oNumLay VAR cNumLay When .F. Picture PesqPict("SLO","LO_NUMLAY") OF oDlg
	
	@ 0.3 , 026 Say RetTitle("LO_EMISSAO") of oDlg    	
	@ 0.8 , 026 MSGET oEmissao VAR dEmissao When .F. Picture PesqPict("SLO","LO_EMISSAO") OF oDlg
	
	@ 0.3 , 034 Say RetTitle("LO_COND") of oDlg  	
	@ 0.8 , 034 MSGET oCond VAR cCond When .F. Picture PesqPict("SLO","LO_COND") OF oDlg
	
	@ 0.3 , 040 Say RetTitle("LO_DTENT") of oDlg 	
	@ 0.8 , 040 MSGET oEntreg VAR dEntreg When .F. Picture PesqPict("SLO","LO_DTENT") OF oDlg
	
	@ 0.3 , 054 Say STR0071 of oDlg //"Total"	
	@ 0.8 , 054 MSGET oTotal VAR nTotal Size 055,009 When .F. Picture PesqPict("SLO","LO_TOTAL") OF oDlg
	
	@ 0.3 , 061 Say STR0072 of oDlg //"Pago"
	@ 0.8 , 061 MSGET oPago VAR nVlPago Size 055,009 When .F. Picture PesqPict("SLO","LO_VALPAG") OF oDlg
	
	@ 0.3 , 068 Say STR0057 of oDlg //"Saldo"
	@ 0.8 , 068 MSGET oSaldo VAR nSaldo Size 055,009 When .F. Picture PesqPict("SLO","LO_VALPAG") OF oDlg   
	
	If cPaisLoc$"MEX|COL" .AND. lR5
		If !Empty(aColunas)
			@ 2.5 , 001 Say STR0073 of oDlg //"Pagamentos Efetuados"
	
	 		//Cria lista com os titulos pagos
			oLbx := TWBrowse():New( 003,001,600,080,,aCab,aSizes,oDlg,,,,,,,,,,,, .F.,, .F.,, .F.,,, )
			oLBx:SetArray(aColunas)
			oLbx:bLine := bLine 
        Else 
        	@ 2.5 , 001 Say STR0073 of oDlg //"Pagamentos Efetuados"
        	
        	oLbx := TWBrowse():New( 003,001,600,080,,aCab,aSizes,oDlg,,,,,,,,,,,, .F.,, .F.,, .F.,,, )
        	aAdd(aColunas,{NIL,NIL,NIL,NIL,NIL,NIL})
        	oLBx:SetArray(aColunas)
        	oLbx:bLine := bLine 
		EndIf
	Else
		@ 2.5 , 001 Say STR0073 of oDlg //"Pagamentos Efetuados"
	
	 	//Cria lista com os titulos pagos
		oLbx := TWBrowse():New( 003,001,600,080,,aCab,aSizes,oDlg,,,,,,,,,,,, .F.,, .F.,, .F.,,, )
		oLBx:SetArray(aColunas)
		oLbx:bLine := bLine 
	EndIf

Else
	DEFINE MSDIALOG oDLG FROM 10,20 TO  32, 83 OF oMainWnd
	@ 001 , 001 Say RetTitle("LO_CLIENTE") of oDlg
	@ 1.5 , 001 MSGET oCliente VAR cCliente When .F. Picture PesqPict("SLO","LO_CLIENTE") OF oDlg
	@ 001 , 006 Say RetTitle("LO_LOJA") of oDlg
	@ 1.5 , 006 MSGET oLoja VAR cLoja When .F. Picture PesqPict("SLO","LO_LOJA") OF oDlg
	@ 1.8 , 008 Say SA1->A1_NOME OF oDlg FONT oFnt COLOR CLR_HBLUE
	@ 2.5 , 001 Say RetTitle("LO_NUMLAY") of oDlg
	@ 003 , 001 MSGet oNumLay VAR cNumLay When .F. Picture PesqPict("SLO","LO_NUMLAY") OF oDlg
	@ 2.5 , 010 Say RetTitle("LO_EMISSAO") of oDlg
	@ 003 , 010 MSGET oEmissao VAR dEmissao When .F. Picture PesqPict("SLO","LO_EMISSAO") OF oDlg
	@ 2.5 , 019 Say RetTitle("LO_COND") of oDlg
	@ 003 , 019 MSGET oCond VAR cCond When .F. Picture PesqPict("SLO","LO_COND") OF oDlg
	@ 2.5 , 026 Say RetTitle("LO_DTENT") of oDlg
	@ 003 , 026 MSGET oEntreg VAR dEntreg When .F. Picture PesqPict("SLO","LO_DTENT") OF oDlg
	@ 4.3 , 002 Say STR0071 of oDlg //"Total"
	@ 4.8 , 002 MSGET oTotal VAR nTotal Size 055,009 When .F. Picture PesqPict("SLO","LO_TOTAL") OF oDlg
	@ 4.3 , 012 Say STR0072 of oDlg //"Pago"
	@ 4.8 , 012 MSGET oPago VAR nVlPago Size 055,009 When .F. Picture PesqPict("SLO","LO_VALPAG") OF oDlg
	@ 4.3 , 022 Say STR0057 of oDlg //"Saldo"
	@ 4.8 , 022 MSGET oSaldo VAR nSaldo Size 055,009 When .F. Picture PesqPict("SLO","LO_VALPAG") OF oDlg
	@ 006 , 001 Say STR0073 of oDlg //"Pagamentos Efetuados"
	@ 3.8 , 001 To 5.5, 030 Label '' of oDlg

	// Cria lista com os titulos pagos
	oLbx := TWBrowse():New( 6.2,001,231,070,,aCab,aSizes,oDlg,,,,,,,,,,,, .F.,, .F.,, .F.,,, )
	oLBx:SetArray(aColunas)
	oLbx:bLine := bLine
EndIf

ACTIVATE MSDIALOG oDlg Valid(Eval(bVldDialog)) ON INIT EnchoiceBar(oDlg,{||(lPagto := .F.,oDlg:End())},{||(lPagto:=.F.,oDlg:End())},,aButtons)


RestArea(aAreaSA1)
RestArea(aAreaSLO)
RestArea(aArea)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800MontPgบAutor  ณArmando P. Waiteman บ Data ณ  03/26/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFuncao que monta array para a exibicao de listbox com todos บฑฑ
ฑฑบ          ณos pagtos efetuados                                         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800MontPg()

Local aArea 	:= GetArea()
Local aAreaSLP 	:= SLP->(GetArea())
Local aAreaSE1	:= SE1->(GetArea())
Local cChaveSLP	:= (xFilial("SLP")+cNumLay+"2")
Local aDados	:= {}

// Posiciona o SLP
dbSelectArea("SLP")
dbSetOrder(1)
dbSeek(cChaveSLP)

// Prepara o ambiente do SE1
dbSelectArea("SE1")
dbSetOrder(1)

While !SLP->(Eof()) .AND. cChaveSLP == SLP->LP_FILIAL+SLP->LP_NUMLAY+SLP->LP_TPAMAR
	If dbSeek(xFilial("SE1")+SLP->LP_PREFIXO+PADR(SLP->LP_NUME1,TAMSX3("LP_NUME1")[1])+SLP->LP_PARCELA+SLP->LP_TIPOE1)
		AADD(aDados,{E1_PREFIXO,E1_NUM,E1_PARCELA,E1_TIPO,E1_EMISSAO,E1_VALOR})
	EndIf
	SLP->(dbSkip())
End

RestArea(aAreaSLP)
RestArea(aAreaSE1)
RestArea(aArea)

aTitulos := aClone(aDados)

Return aDados



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณPlanoPg   บAutor  ณArmando P. Waiteman บ Data ณ  03/27/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Funcao que monta lista de pagtos a serem efetuados de acor บฑฑ
ฑฑบ          ณ do com a data limite                                       บฑฑ
ฑฑบ          ณ nValor     := Valor a ser parcelado                        บฑฑ
ฑฑบ          ณ nDataIni   := Data de inicio dos pagtos                    บฑฑ
ฑฑบ          ณ nDataFim   := Data Limite para pagamento total             บฑฑ
ฑฑบ          ณ nIntervalo := Intervalo entre pagamentos                   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function PlanPgt(nValor,	dDtIni,	dDtFim,	nIntervalo)

Local nParcelas := 0
Local nX		:= 0
Local nVlParc	:= 0
Local aParcelas := {}
Local dDtVenc	:= dDtIni

// Acerta o valor de intevalo entre parcelas
If ValType(nValor) <> "N"
	nValor	   	:= 0
EndIf

If ValType(dDtIni) <> "D"
	dDtIni		:= dDataBase
Endif                    

If ValType(dDtFim) <> "D"
	dDtFim		:= dDataBase
EndIf                    

If ValType(nIntervalo) <> "N"
	nIntervalo 	:= 30
EndIf


nParcelas := Int((dDtFim - dDtIni)/30)
If nParcelas < 1
	nParcelas	:= 1
EndIf

nVlParc := Round(nValor / nParcelas,TamSx3("LO_VALPAG")[2])


// Caso hajam mais pagtos faz os proximos
For nX:=1 to nParcelas
	AADD(aParcelas,{dDtVenc,nVlParc})
	dDtVenc := dDtVenc+nIntervalo
Next

// A ultima parcela deve respeitar a diferenca por arredondamento
For nX:= 1 to (Len(aParcelas)-1)
	nValor := nValor - aParcelas[nX][2]
Next
aParcelas[Len(aParcelas)][2] := nValor

Return aParcelas	



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800ExcTitบAutor  ณArmando P. Waiteman บ Data ณ  03/27/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExclui titulo selecionado via consulta financeira do layawayบฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800ExcTit(cPrefixo,	cNumTit,	cParcela,	cTipo, ;
					nValor)


Local aVetor:={}
Local aArea := GetArea()                           
Local lMsErroAuto := .F.
Local nTamE1Parc    := TamSX3("E1_PARCELA")[1]	//Tamanho do campo


cParcela	:= PadR( cParcela , nTamE1Parc) 	// Ajusta de acordo com o tamanho do E1_PARCELA
// Posiciona o SLP                                   
dbSelectArea("SLP")
dbSetOrder(3)
dbSeek(xFilial("SLP")+cPrefixo+Alltrim(cNumTit)+cParcela)

// Valida para que nใo seja excluida a parcela de valor inicial
If cParcela == "0"
	HELP("",1,"NOEXCLPARC")
	Return
EndIf

// Caso encontre faz a exclusao
If !Eof()
	aVetor  := {	{"E1_PREFIXO" ,cPrefixo  ,Nil},;
	             	{"E1_NUM"	  ,cNumTit   ,Nil},;
	             	{"E1_PARCELA" ,cParcela  ,Nil},;
	             	{"E1_TIPO"	  ,cTipo     ,Nil}}
EndIf

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณForca o conteudo do campo e1_origem para que o registro possa ser excluido pela funcao MsExecAuto()ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
DBSelectArea("SE1")
DBSetOrder(1)
DBSeek(xFilial()+cPrefixo+cNumTit+cParcela+cTipo)

If Found()
   If dDatabase < SE1->E1_EMISSAO  //Nao permitir excluir um titulo com data de emissao maior que a database
      HELP("",1,"LAYEMIS")
      Return
   EndIf
EndIf
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณVerifica se o usuario tem permissao para acessar a rotina deณ
//ณexclusao de pagos...                                        ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู

lRet := FWAuthSuper(__cUserId)

If !lRet
	Return 
EndIF

RecLock("SE1",.F.)
Replace E1_ORIGEM With "FINA040" 
MsUnlock()

MSExecAuto({|x,y| Fina040(x,y)},aVetor,5) 


If lMsErroAuto
	HELP("",1,"NOINCTIT")
Else
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Deleta a amarracaoณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	Reclock("SLP",.F.,.T.)
	dbDelete()
	MsUnlock()
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณAjusta o valor pago e numero de parcelas no Lay-awayณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	a800ValPag(cNumLay,(-1),(nValor*(-1)))
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณPE criado para o usuario utilizar apos a exclusao do titulo...ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If ExistBlock("LJ800CTI")
		ExecBlock("LJ800CTI",.F.,.F.)
	EndIf
EndIf

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณDESCB1    บAutor  ณArmando P. Waiteman บ Data ณ  04/01/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPesquisa e retorna a descricao do produto de acordo com o   บฑฑ
ฑฑบ          ณcodigo passado                                              บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800DescB1(cProduto)

Local aArea := GetArea()

dbSelectArea("SB1")
dbSetOrder(1)
dbSeek(xFilial("SB1")+cProduto)

RestArea(aArea)

Return SB1->B1_DESC



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLj800BxLayบAutor  ณArmando P. Waitaman บ Data ณ  04/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a baixa do Lay-Away e cria amarracao do L1 no SLP    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800BxLay(cNumLay,	cItem,	nlinha)

Local aArea 	:= GetArea()
Private aAmarras:= {}

dbSelectArea("SLO")
dbSetOrder(1)
DbSeek(xFilial("SLO")+cNumLay+cItem)

// Atualiza o SLO
Reclock("SLO",.F.)
Replace LO_QUJE With LO_QUJE + SL2->L2_QUANT
If (LO_QUANT - LO_QUJE) <= 0
	Replace LO_STATUS With "2"
EndIf
MsUnlock()

// Cria a amarracao no SLP
AADD(aAmarras,{"3",LO_NUMLAY,LO_CLIENTE,LO_LOJA,SL2->L2_NUM,SL2->L2_ITEM,LO_PRODUTO,LO_LOCAL,LO_ITEM})
a800Amarra()

// Baixa a reserva proporcional a venda
// Acerta o SC0
dbSelectArea("SLP")
dbSetOrder(5)
dbSeek(xFilial("SLP")+cNumLay+"1"+cItem)

dbSelectArea("SC0")
dbSetOrder(1)
dbSeek(xFilial("SC0")+SLP->LP_RESERVA)
RecLock("SC0",.F.)
Replace C0_QUANT With (C0_QUANT - SL2->L2_QUANT)
MsUnlock()

//Acerta o SB2
GravaB2Emp("-",SL2->L2_QUANT,,.T.)

RestArea(aArea)

Return



/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800AbreLWบAutor  ณArmando P. Waiteman บ Data ณ  04/08/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFaz a reabertura do Lay-Away devido a exclusao de venda     บฑฑ
ฑฑบ          ณbalcao                                                      บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

Function a800AbreLw(cNumL2,cItemL2)

Local aArea := GetArea()
Local aOperacao   	:= Array(5)
Local aLote       	:= {"","","",""}
Local cNumlay		:= ""
Private aAmarras		:= {}

// Limpa a amarracao do SLP
dbSelectArea("SLP")
dbSetOrder(4)
If dbSeek(xFilial("SLP")+cNumL2+cItemL2)
	cNumLay := LP_NUMLAY
	cItemLay:= LP_ITEM
	RecLock("SLP",.F.,.T.)
	dbDelete()
EndIf

dbSelectArea("SLO")
dbSetOrder(1)
dbSeek(xFilial("SLO")+cNumlay+cItemLay)

// Ajusta o SLO
RecLock("SLO",.F.)
Replace LO_STATUS with If(LO_DTENT < dDataBase,"3","1")
Replace LO_QUJE   with LO_QUJE - SL2->L2_QUANT
MsUnlock()


// Refaz a reserva
aOperacao := {1,"LW",SLO->LO_NUMLAY,STR0094+SLO->LO_NUMLAY+"-"+SLO->LO_ITEM,xFilial("SLO")} //"LAYAWAY: "
a430Reserva(aOperacao,"",SLO->LO_PRODUTO,SLO->LO_LOCAL,SL2->L2_QUANT,aLote)
AADD(aAmarras,{"1",SLO->LO_NUMLAY,SLO->LO_ITEM,SLO->LO_CLIENTE,SLO->LO_LOJA,SC0->C0_PRODUTO,SC0->C0_LOCAL,SC0->C0_NUM})
a800Amarra()

RestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800BxAut บAutor  ณJulio Cesar         บ Data ณ  03/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRealiza a baixa do RA e o movimento bancario quando o       บฑฑ
ฑฑบ          ณLay-Away e cancelado.                                       บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
             
Static Function a800BxAut(cPref,		cNumTit,	cNumLay,	cCodClie,;
						  cLojClie)

Local aAreaAtu    := GetArea()
Local aAreaSE1    := SE1->(GetArea())

Private lMsErroAuto := .F. 
Private lMsHelpAuto := .T.
	
dbSelectArea("SE1")
dbSetOrder(1)
If dbSeek(xFilial("SE1")+cPref+cNumTit)
	While !Eof() .AND. E1_FILIAL+E1_PREFIXO+E1_NUM == xFilial("SE1")+cPref+Padr(AllTrim(cNumTit),TamSX3("E1_NUM")[1])
	    
	    If E1_CLIENTE+E1_LOJA <> cCodClie+cLojClie
	       DbSkip()
	       Loop
	    EndIf                                     
	    
		If (E1_SALDO > 0)
            a800BxAdiant()  //Gera SE5
            
			RecLock("SE1",.F.)
		    Replace E1_BAIXA	With dDatabase
            Replace E1_MOVIMEN  With dDatabase
            Replace E1_SALDO    With 0                        
            Replace E1_STATUS   With "B"
            MsUnlock()
		EndIf
		dbSkip()
	End
EndIf
RestArea(aAreaSE1)
RestArea(aAreaAtu)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800TotPg บAutor  ณJulio Cesar         บ Data ณ  20/06/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณTotaliza o valor ja pago pelo lay-away                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function a800TotPg()

Local nValor	:= 0
Local aArea 	:= GetArea()        
Local cChaveLP  := "" 
Local cChaveE5  := ""
Local aAreaSE5 	:= SE5->(GetArea())
Local aAreaSLP  := SLP->(GetArea())

dbSelectArea("SLP")
dbSetOrder(1)
If dbSeek(xFilial("SLP")+cNumLay+"2")
	SE5->(dbSetOrder(2))
	While !Eof() .AND. (xFilial("SLP")+cNumLay+"2" == SLP->LP_FILIAL+SLP->LP_NUMLAY+SLP->LP_TPAMAR)
        cChaveLP := xFilial("SE5")+"RA"+SLP->LP_PREFIXO+padr(SLP->LP_NUME1,tamsx3("E5_NUMERO")[1])+SLP->LP_PARCELA+"RA "
		If SE5->(dbSeek(cChaveLP))
			cChaveE5 := xFilial("SE5")+SE5->E5_TIPODOC+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO
			While SE5->(!Eof()) .AND. (cChaveE5 == cChaveLP)
				If SE5->E5_RECPAG == "R" 								 
					nValor += SE5->E5_VALOR
				EndIf
				SE5->(dbSkip())
				cChaveE5 := xFilial("SE5")+SE5->E5_TIPODOC+SE5->E5_PREFIXO+SE5->E5_NUMERO+SE5->E5_PARCELA+SE5->E5_TIPO
			End
		EndIf
		SLP->(dbSkip())			
	End
EndIf

RestArea(aAreaSE5)
RestArea(aAreaSLP) 
RestArea(aArea)

Return(nValor)  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLj800Vld  บAutor  ณWilliam Martinez Yong บ Data ณ  17/07/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Validacao para nao permitir acessar a funcao de planos de    บฑฑ
ฑฑบ          ณ pagamentos se for alteracao                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/           

Function Lj800Vld()

MsgStop(STR0077 + STR0094)  // "Nao e possivel acessar a funcao de plano de pagamento na modificacao do Lay-Away"          

Return .F.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800AddPagบAutor  ณWilliam Martinez Yong บ Data ณ  18/07/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ No processo de alteracao : se incluir um novo produto e dimi บฑฑ
ฑฑบ          ณ nuir o valor do titulo ja gravado essa funcao vai gravar o   บฑฑ  
ฑฑบ          ณ campo LO_VALPAG para o novo produto do Lay-Away              บฑฑ 
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                          บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/       

Function a800AddPag(cNumLay)

Local aArea := {}        
                  
aArea := GetArea()
DbSelectArea("SLO")
DbSetOrder(1)
dbSeek(xFilial("SLO")+cNumLay,.T.)
While !EOF() .AND. xFilial("SLO")+cNumLay == LO_FILIAL + LO_NUMLAY
	RecLock("SLO",.F.)          
	If LO_VALPAG == 0
		Replace SLO->LO_VALPAG with nValPago
	EndIf   
  	MsUnLock()
  	dbSkip()
End

RestArea(aArea)
     
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA800Forma บAutor  ณFernando Machima      บ Data ณ  14/08/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Habilita/Desabilita o combo das administradoras financeiras  บฑฑ
ฑฑบ          ณ dependendo da forma de pagamento                             บฑฑ  
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA800                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/       
Static Function A800Forma()

Local lRet   := .T.
Local lDifer := .F.
Local nI     := 1

If !(Empty(cFormaPg)) 
	If !(SX5->(DbSeek(xFilial()+"24"+cFormaPg))) //Verifica se a forma de pagto. esta cadastrada
		Help(" ",1,"REGNOIS")
		lRet:=.F.
	Else
		aCartoes  := {}
		If Trim(cFormaPg) $ "CC|CD" 
		   A800LerCC(cFormaPg)
		EndIf   
		If Len(aCartoes)==0
		   oComboCC:Hide()
		   oSayCC:Hide()
		Else        
		   While nI <= Len(aCartoes) .AND. !lDifer .AND. Len(oComboCC:aItems) > 0
		      If aCartoes[nI] <> oComboCC:aItems[nI]
		         lDifer  := .T.  //Forma de pagamento alterada
		      EndIf
		      nI++
		   End
		   If lDifer .OR. Len(oComboCC:aItems) == 0  //Atualizar os items do combo box
		      oComboCC:aItems := aCartoes		           
		   EndIf   
		   oComboCC:Show()
		   oSayCC:Show()              		   		   
		   oComboCC:Refresh()		   		                   		   
		EndIf
	EndIf	
Else
   oComboCC:Hide()
   oSayCC:Hide()	
EndIf	
	
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA800LerCC บAutor  ณFernando Machima      บ Data ณ  14/08/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Busca as administradoras financeiras para formas de pagamentoบฑฑ
ฑฑบ          ณ em cartao de credito/debito                                  บฑฑ  
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA800                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/       
Function A800LerCC(cFormaPg)

aCartoes  := {}
dbSelectArea("SAE")
dbSeek(xFilial("SAE"))

While !Eof() .AND. xFilial("SAE") == SAE->AE_FILIAL
   If Trim(SAE->AE_TIPO) == Trim(cFormaPg)
      Aadd(aCartoes , SAE->AE_COD + "-" + Capital(SubStr(SAE->AE_DESC,1,25)))
   EndIf
   dbSkip()
End
If Empty(aCartoes)
   Aadd(aCartoes, Capital(STR0079))  //Admin. no Cadastrada
EndIf

Return aCartoes

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA800VldForบAutor  ณFernando Machima      บ Data ณ  14/08/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Verifica se a forma de pagamento foi digitada                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA800                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/       
Static Function A800VldForma()

Local lRet  := .T.

lRet  := !Empty(cFormaPg) 
If !lRet
   HELP(" ",1,"OBRIGAT")
EndIf
           
Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณVldOpc800 บ Autor ณWilliam Martinez Yong บ Data ณ  13/09/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณ Nao permitir que Lay-Away encerrado ou anulado acesse opcao  บฑฑ
ฑฑบ          ณ de modificacao, cancelamento ou de pagamentos                บฑฑ  
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA800                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/       

Function VldOpc800(lPgto)  // lPgto = .T. indica que foi chamada da tela de pagamentos  

Local lRet := .T.

If SLO->LO_STATUS $ "2|4"
	If SLO->LO_STATUS == "2"   // Lay-Away encerrado
		If lPgto
			MsgStop(STR0085 + STR0096) // "Nao e possivel acessar a funcao de consulta/pagamentos para um Lay-Away encerrado" 
			lRet := .F.
		Else	
			If lAltera
				MsgStop(STR0081 + STR0096) // "Nao e possivel acessar a funcao de modificacao para um Lay-Away encerrado"
				lRet := .F.
			ElseIf lDeleta  	
				MsgStop(STR0082 + STR0096) // "Nao e possivel acessar a funcao de cancelamento para um Lay-Away encerrado"
				lRet := .F.
			Endif
		Endif			
	Else   // Lay-Away anulado
		If lPgto
			MsgStop(STR0086 + STR0097) // "Nao e possivel acessar a funcao de consulta/pagamentos para um Lay-Away anulado"
			lRet := .F.
		Else
			If lAltera     
				MsgStop(STR0083 + STR0097) // "Nao e possivel acessar a funcao de modificacao para um Lay-Away anulado"
				lRet := .F.
			ElseIf lDeleta	
				MsgStop(STR0084 + STR0097) // "Nao e possivel acessar a funcao de cancelamento para um Lay-Away anulado"
				lRet := .F.
			Endif
		Endif	
	Endif			
Endif

Return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800BxAdiaบ Autor ณFernando Machima      บ Data ณ  17/04/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณRealiza o movimento bancario quando o Lay-Away eh cancelado   บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA800                                                      บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/       
Static Function a800BxAdiant()
Local i
Local cSequencia := "00" 
Local aTipoDoc   := {}
Local aArea      := GetArea()
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Localiza a sequencia da baixa ( CP,BA,VL,V2,LJ )			 ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
aTipoDoc := {"CP","BA","VL","V2"}
SE5->(dbSetOrder(2))
FOR I := 1 to Len(aTipoDoc)
	SE5->(dbSeek(xFilial("SE5") + aTipoDoc[i] + SE1->E1_PREFIXO + SE1->E1_NUM + ;
	SE1->E1_PARCELA + SE1->E1_TIPO ))
	While !SE5->(Eof())								.AND. ;
		SE5->E5_FILIAL  == xFilial("SE5")		.AND. ;
		SE5->E5_TIPODOC == aTipoDoc[i]     .AND. ;	
		SE5->E5_PREFIXO == SE1->E1_PREFIXO .AND. ;
		SE5->E5_NUMERO  == SE1->E1_NUM		.AND. ;
		SE5->E5_PARCELA == SE1->E1_PARCELA .AND. ;
		SE5->E5_TIPO	  == SE1->E1_TIPO
			
		If cSequencia < SE5->E5_SEQ
			cSequencia := SE5->E5_SEQ
		Endif
		SE5->(dbSkip())
	End
Next I
cSequencia := Soma1(cSequencia,2)
SE5->(dbSetOrder(1))

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณGera movimentao banc ria a pagar - baixa do adiantamento		     ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Reclock( "SE5", .T. )
Replace SE5->E5_FILIAL  with xFilial("SE5")
Replace SE5->E5_NUMERO  with SE1->E1_NUM
Replace SE5->E5_PREFIXO with SE1->E1_PREFIXO
Replace SE5->E5_RECPAG  with "P"
Replace SE5->E5_TIPO	with SE1->E1_TIPO
Replace SE5->E5_PARCELA with SE1->E1_PARCELA
Replace SE5->E5_TIPODOC with "VL"
Replace SE5->E5_MOTBX	with "NOR"
Replace SE5->E5_BANCO	with xNumCaixa()
Replace SE5->E5_AGENCIA with SA6->A6_AGENCIA
Replace SE5->E5_CONTA	with SA6->A6_NUMCON
Replace SE5->E5_DATA	with dDatabase
Replace SE5->E5_VALOR	with SE1->E1_SALDO
Replace SE5->E5_NATUREZ with SE1->E1_NATUREZ
Replace SE5->E5_HISTOR  with SE1->E1_HIST
Replace SE5->E5_CLIFOR  with SE1->E1_CLIENTE
Replace SE5->E5_CLIENTE with SE1->E1_CLIENTE
Replace SE5->E5_LOJA	with SE1->E1_LOJA
Replace SE5->E5_BENEF	with SE1->E1_NOMCLI
Replace SE5->E5_DTDIGIT with dDataBase
Replace SE5->E5_SEQ 	with cSequencia
Replace SE5->E5_DTDISPO	with dDatabase
Replace SE5->E5_VLMOED2 with xMoeda(SE1->E1_SALDO,1,SE1->E1_MOEDA)
Replace SE5->E5_LA      with "N"
MsUnlock()

RestArea(aArea)

Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณA800VldMoeda บ Autor ณJulio Cesar           บ Data ณ  09/12/03   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณVerifica se a moeda informada existe no sistema.                 บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ LOJA800                                                         บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/       
Function A800VldMoeda(nMoedaCor)

Local lRet      := .T.

//A moeda informada eh maior do que a qtde de moedas existentes no sistema...
If nMoedaCor > MoedFin()             
	lRet := .F.
Else
	If Empty(SuperGetMV("MV_MOEDA"+AllTrim(Str(nMoedaCor))))
		lRet := .F.
	Else 
		lRet := .T.	
	EndIf
EndIf

Return(lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออหอออออออัออออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800CompAut  บ Autor ณFernando Machima      บ Data ณ  21/01/04   บฑฑ
ฑฑฬออออออออออุอออออออออออออสอออออออฯออออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDescricao ณFaz a compensacao automatica dos titulos gerados pelo Lay-Away   บฑฑ
ฑฑบ          ณna finalizacao do mesmo atraves da Venda Assistida               บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบParametro ณ ExpA1 = array com os numeros dos Lay-Aways finalizados          บฑฑ
ฑฑฬออออออออออุอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Venda Assistida                                                 บฑฑ
ฑฑศออออออออออฯอออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/       
Function a800CompAut(aNumLay)

Local nX
Local nVlrComp    := 0
Local nVlrTit     := 0
Local nSeq        := 0
Local nRecnoComp                        //Recno do titulo principal
Local nRecnoTit                         //Recno dos titulos RA gerados pelo Lay-Away
Local nDecs1      := MsDecimais(1)
Local nVlrMoeda   := 0                  // Taxa da moeda do dia
Local cPrefTit    := AllTrim(&(SuperGetMV("MV_LWPREF1")))
Local cClienteLay := SL1->L1_CLIENTE
Local cLojaLay    := SL1->L1_LOJA
Local c1DUP 	  := SuperGetMv("MV_1DUP") 	// Sequ๊ncia das parcelas "1" = 1..9;A..Z;a..z    e   "A" = A..Z
Local cAdiantamento 
Local lPadrao     := .F.
Local lRet        := .T.
Local aBaixas     := {}

Private cPrefixo 
Private	cNum	 
Private cParcela       
Private cCliente 
Private cLoja 	
Private cLote     := ""
Private nMoeda	  := 1
Private	dBaixa	  := dDataBase
Private aTxMoedas := {}

Aadd(aTxMoedas,{"",1,PesqPict("SM2","M2_MOEDA1"),1})
For nX := 2 To MoedFin()
   If !Empty(SuperGetMv("MV_MOEDA"+Str(nX,1)))
      nVlrMoeda := RecMoeda(dDataBase,nX)   
      Aadd(aTxMoedas,{SuperGetMv("MV_MOEDA"+Str(nX,1)),nVlrMoeda,PesqPict("SM2","M2_MOEDA"+Str(nX,1)),nVlrMoeda})
   Else
      Exit
   Endif
Next nX

//Busca o titulo gerado pela finalizacao do Lay-Away a ser compensado
DbSelectArea("SE1")
DbSetOrder(1)
If DbSeek(xFilial()+SL1->L1_SERIE+SL1->L1_DOC+LJParcela(1, c1DUP)+"CR ")
    cPrefixo  := SE1->E1_PREFIXO
    cNum      := SE1->E1_NUM    
    cParcela  := SE1->E1_PARCELA
    cCliente  := SE1->E1_CLIENTE    
    cLoja 	  := SE1->E1_LOJA    
    nMoeda	  := SE1->E1_MOEDA
	nVlrComp  := SE1->E1_SALDO	
	nRecnoComp:= Recno()
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Verifica se data do movimento no  menor que data limite de ณ
	//ณ movimentacao no financeiro    								 ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !DtMovFin()
		Return .F.
	Endif
	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Busca os titulos de RA gerados pelo Lay-Away para fazer a    ณ
	//ณ compensacao                                                  ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	For nX := 1 to Len(aNumLay)
		If DbSeek(xFilial()+cPrefTit+aNumLay[nX])
			While !Eof() .AND. xFilial()+cPrefTit+aNumLay[nX] == SE1->E1_FILIAL+;
				SE1->E1_PREFIXO+SE1->E1_NUM
				
				If AllTrim(SE1->E1_TIPO) <> "RA" .OR. SE1->E1_SALDO == 0
					DbSkip()
					Loop
				EndIf
				
				If SE1->E1_CLIENTE <> cClienteLay .OR. SE1->E1_LOJA <> cLojaLay
					DbSkip()
					Loop
				EndIf
				
				If SE1->E1_EMISSAO > dDatabase
					DbSkip()
					Loop
				EndIf

				// Variaveis para o FINA330
				MV_PAR01 := 1			//Considera Loja  Sim/Nao          	  
				MV_PAR02 := 1         	//Considera Cliente     Original/Outros
				If FunName() == "LOJA701"
				   MV_PAR03 := M->LQ_CLIENTE	// Do Cliente                            
				   MV_PAR04 := M->LQ_CLIENTE	// Ate Cliente   		
				Else
				   MV_PAR03 := oCliente:cText	// Do Cliente                            
				   MV_PAR04 := oCliente:cText	// Ate Cliente   
				EndIf   
				MV_PAR05 := 1 			// Compensa Titulos Transferidos S/[N]  
				MV_PAR06 := 2 			// Calcula Comissao sobre valores de NCC 
				MV_PAR07 := 2			// Mostra Lancto Contabil       
				MV_PAR08 := 2			// Considera abatimentos para compensar
			    MV_PAR10 := 1 			//Considera Filiais abaixo              		
			    MV_PAR11 := '  '
			    MV_PAR12 := 'ZZ'	    
				nVlrTit       := SE1->E1_SALDO
				cAdiantamento := E1_PREFIXO+E1_NUM+E1_PARCELA+E1_TIPO+E1_LOJA				
				nRecnoTit     := Recno()
				
				SE1->(DbGoto(nRecnoComp))
                Fa330Grv(lPadrao,nVlrTit,cAdiantamento,StrZero(nSeq,2),nRecnoTit,@aBaixas,"LOJA800",.F.,2)									
				
				//Atualiza os dados do titulo RA
				SE1->(DbGoto(nRecnoTit))				
				Reclock("SE1",.F.)
				Replace SE1->E1_SALDO   with 0
				Replace SE1->E1_MOVIMEN with dDatabase				
				SE1->E1_VALLIQ  += Round(xMoeda(SE1->E1_VALOR,SE1->E1_MOEDA,1,dDatabase,nDecs1+1,aTxMoedas[SE1->E1_MOEDA][2]),nDecs1)				
				Replace SE1->E1_BAIXA   with dBaixa
				Replace SE1->E1_STATUS  with "B"
				MsUnlock()				
				
				DbSkip()
			End
		EndIf
	Next nX	
Else
   lRet  := .F.	
EndIf

Return (lRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัอออออออออออออออออหอออออออัอออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณ a800bAfterCols  บAutor  ณ Conrado Q.  บ Data ณ  02/02/07   บฑฑ
ฑฑฬออออออออออุอออออออออออออออออสอออออออฯอออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Executado depois da adi็ใo de um registro a aCols.         บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP9                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a800bAfterCols()
	Local nY := Len(aCols)	// ฺltimo item da array
	Local nX := 0			// Contador
	
	//Inicia a Carga do item nas funcoes MATXFIS 
	MaFisIniLoad(nY)
	For nX := 1 To Len(aRefImpos)
		MaFisLoad(aRefImpos[nX][3],SLO->(FieldGet(FieldPos(aRefImpos[nX][2]))),nY)
	Next nX
	MaFisEndLoad(nY,2)
Return ( .T. )  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800Modi  บAutor  ณVendas CRM          บ Data ณ  03/31/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerificar manejo de apartados vinculado ao contrato,        บฑฑ
ฑฑบ          ณpermite modificar cadastro                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function a800Modi()

Local lMod    		:= .T.                      //Retorno (.T.) modifica e (.F.) Nao Modifica
Local cAltera 		:= ""                       // Indica se o cadastro podera ser modificado
Local aAreaMEO    	:= MEO->(GetArea())   

If !lInclui
	If cPaisLoc$"MEX|COL" .AND. lR5
		DbSelectArea("MEO")
		DbSetOrder(1)		
		//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
		//ณVerifica se tem contrato associado, e se permite modifica็ใo ณ
		//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
		If !Empty(cContrato)
			If DbSeek( xFilial("MEO") + cContrato)
				cAltera := MEO->MEO_MODDAD
	   			If cAltera == '1' 
	   				lMod := .T.
	   			Else                                   
	   				lMod := .F.
	   			EndIf
	   		EndIf	
	   		MEO->(RestArea(aAreaMEO))
   		Else 
   			lMod := SuperGetMv("MV_LWALT")				
   		EndIf
	Else 
		lMod := SuperGetMv("MV_LWALT")
	EndIf 
EndIf

Return(lMod)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณLOJA800   บAutor  ณVendas CRM          บ Data ณ  04/01/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica se permite entrega parcial do manejo de apartado  บฑฑ
ฑฑบ          ณ Parametro:                                                 บฑฑ
ฑฑบ          ณ Exp[1] : Numero do LAY                                     บฑฑ
ฑฑบ          ณ Exp[2] : Cod Contrato                                      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑบ          ณ Retorno:                                                   บฑฑ
ฑฑบ          ณ Exp[1] : Valor que permite a entrega                       บฑฑ
ฑฑบ          ณ Exp[2] : Permite ou nao entrega parcial                    บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function a800LwParc(cNumLay,CodCon)

Local aRet      := {}
Local aAreaMEO  := MEO->(GetArea())
Local lMvLwParc	:= SuperGetMV("MV_LWPARC",,.F.) 	                       //Define se permite a entrega parcial
Local cMvLwParc := 0                           								// Recebe valor para definir a entrega parcial
Local nPorEnt   := 0                            							//Porcentagem para entrega parcial
Local nVlEnt    := 0                        								//Valor de Entrada

If cPaisLoc$"MEX|COL" .AND. lR5

	DbSelectArea("MEO")
	DbSetOrder(1)
		
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณVerifica se tem contrato associado,e se permite entrega parcialณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	If !Empty(CodCon) 
		If DbSeek( xFilial("MEO") + CodCon)
			cMvLwParc := MEO->MEO_ENPARC
			nPorEnt   := MEO->MEO_MERCVA 
			If cMvLwParc == '1' 
	 			lMvLwParc := .T.
	 			nTotal    := a800Total(.T.)
	   			nVlEnt    := Round((nTotal * nPorEnt)/ 100,TamSX3("LO_TOTAL")[2])
	   		Else                                  
	   			lMvLwParc := .F.
	   		EndIf
	   	EndIf		
 	Else 
  		lMvLwParc	:= SuperGetMV("MV_LWPARC",,.F.)   							
  	EndIf	
  	
EndIf 

Aadd(aRet,{nVlEnt,lMvLwParc})

MEO->(RestArea(aAreaMEO))

Return(aRet)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800Parc  บAutor  ณVendas CRM          บ Data ณ  04/06/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Verifica quantos Manejos de Apartados o cliente pode fazer บฑฑ
ฑฑบ          ณ simultaneamente                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ SIGALOJA                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function a800Parc(cCliente,cLoja)

Local aRet 		:= {}
Local aLay 		:= {}                //Array para armazenar os Lay-aways que o cliente ja possui
Local aAreaSLO 	:= SLO->(GetArea())
Local aAreaMEO 	:= MEO->(GetArea())
Local cCont     := ""                //Armazena contrato de manejo de apartados
Local nParc     := 0                 //Armazena o numero de parcelas
Local aArea 	:= {}


DbSelectArea("SLO")
DbSetOrder(2)

If DbSeek(xFilial("SLO") + cCliente + cLoja)
	aArea := GetArea()	
	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณFiltra contratos que estใo ativos.ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	MEO->(DbSetOrder(1))
	While !SLO->(Eof())  .AND. SLO->LO_FILIAL+SLO->LO_CLIENTE+SLO->LO_LOJA == xFilial("SLO")+cCliente+cLoja
		cCont := SLO->LO_CODCON
		If !Empty(cCont) .AND. SLO->LO_STATUS == "1"
			If MEO->(DbSeek( xFilial("MEO") + cCont))
				nParc := MEO->MEO_PARCMA
				If nParc > 0
					RestArea(aArea)				
					//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
					//ณVerifica somente contratos ativosณ
					//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
					While !SLO->(Eof())  .AND. SLO->LO_FILIAL+SLO->LO_CLIENTE+SLO->LO_LOJA == xFilial("SLO")+cCliente+cLoja
						If SLO->LO_STATUS == "1" .AND. SLO->LO_DTENT > dDataBase
							aAdd(aLay,{SLO->LO_NUMLAY})
							SLO->(dbSkip())
						Else
							SLO->(dbSkip())
						EndIf
					End
				EndIf
				Exit
			Else                                                                       
				SLO->(dbSkip())		
			EndIf	
		Else
			SLO->(dbSkip())		
		EndIf
	End			
EndIf

If nParc > 0
	If nParc <= Len(aLay)
		aAdd(aRet,{cCont,nParc,.F.})
	Else
		aAdd(aRet,{cCont,nParc,.T.})
	EndIf
Else
	aAdd(aRet,{cCont,nParc,.T.})	
EndIf
	
SLO->(RestArea(aAreaSLO))
MEO->(RestArea(aAreaMEO))

Return(aRet)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800Cli   บAutor  ณVendas CRM          บ Data ณ  30/03/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRetorna nome do cliente                                    บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณSIGALOJA                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a800Cli(cCliente,cLoja)

Local aAreaSA1 	:= SA1->(GetArea())
Local cChave                          //Chave para pesquisa
Local cNomeCli  	                  //Nome do cliente
	
cChave  := cCliente

If !Empty(cLoja)
	cChave  += cLoja
EndIf

dbSelectArea("SA1")
dbSetOrder(1)
If dbSeek(xFilial("SA1")+cChave,.T.)
	cNomeCli:=A1_NOME
EndIf	

SA1->(RestArea(aAreaSA1))

Return(cNomeCli)


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณa800Vld   บAutor  ณVendas CRM          บ Data ณ  05/04/11   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Valida contrato digitado                                   บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Loja800                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function a800VldCon()
Local lRet
Local aAreaMEO  := MEO->(GetArea())

DbSelectArea("MEO")
DbSetOrder(1)

If !Empty(cContrato)	
	If DbSeek( xFilial("MEO") + cContrato)
		lRet := .T.
	Else
		Aviso(STR0088,STR0098,{STR0091},3)
		lRet := .F.
	EndIf	
Else 
	lRet := .T.
EndIf   

MEO->(RestArea(aAreaMEO))

Return lRet
