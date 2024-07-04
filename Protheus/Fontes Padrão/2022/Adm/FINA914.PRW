#include "protheus.ch"
#include "fina914.ch"
#include "fileio.ch"
#include "FWMVCDEF.CH"

Static __oHshCFil   := Nil  //Objeto do tipo LJCHasheTable com as filiais cadastradas para importacao
Static __oHashTef	:= Nil	//Objeto do tipo LJCHasheTable com as filiais cadastradas nos parametros - Software Express
Static __oHashAme	:= Nil	//Objeto do tipo LJCHasheTable com as filiais cadastradas nos parametros - Amex
Static __oHashCie	:= Nil	//Objeto do tipo LJCHasheTable com as filiais cadastradas nos parametros - Cielo
Static __oHashRed	:= Nil	//Objeto do tipo LJCHasheTable com as filiais cadastradas nos parametros - Rede
Static __oFINA914 	:= Nil //Objeto para receber comandos da classe FwTemporaryTable
Static __nTmNomAr   := TamSX3("FVR_NOMARQ")[1]
Static __lAPixTpd   := FindFunction("F918AtuTPD") .And. F918AtuTPD()

//--------------------------------------------------------------------------
/*{Protheus.doc} FINA914()
Rotina para importação de arquivos TEF dos seguintes layouts:
- AMEX
- Cielo
- Rede
- Software Express

@author Pedro Pereira Lima
@since 18/12/2017
@version 12.1.17
*/
//--------------------------------------------------------------------------
Function FINA914(lAutomato As Logical, lOpt As Logical)
Local aArea     As Array
Local cMay      As Character
Local cEmpFVR   As Character
Local cUniFVR   As Character
Local cFilFVR   As Character
Local cEmpFV3   As Character
Local cUniFV3   As Character
Local cFilFV3   As Character
Local nOptModo  As Numeric
Local oDlg 		As Object
Local oPanel 	As Object
Local oFont1	As Object
Local oFont2	As Object
Local oSayTop	As Object
Local oBtnTEF	As Object
Local oBtnPD	As Object

//Determina se o registro TEF, se ja importado, seja reprocessado em ExecAuto
Default lOpt	  := .T. 
Default lAutomato := .F.
Default nOptModo  := 1 	

cEmpFVR := FWMODEACCESS("FVR",1)
cUniFVR := FWMODEACCESS("FVR",2)
cFilFVR := FWMODEACCESS("FVR",3)
cEmpFV3 := FWMODEACCESS("FV3",1)
cUniFV3 := FWMODEACCESS("FV3",2)
cFilFV3 := FWMODEACCESS("FV3",3)

cMay := "FINA914"

	//Verifica o compartilhamento das tabelas FVR e FV3 são iguais e compartilhado..
	If ((cEmpFVR == "E") .Or. (cUniFVR == "E") .Or. (cFilFVR== "E")) .Or. ((cEmpFV3 == "E") .Or. (cUniFV3 == "E") .Or. (cFilFV3 == "E"))
		MsgStop(STR0050)
		Return(.F.)
	EndIf

	If !MayIUseCode( cMay )
		MsgStop(STR0008 + STR0051)
		Return(.F.)
	Endif

	aArea := GetArea()

	If (!lAutomato)
		Define MsDialog oDlg TITLE STR0074 From 180, 180 TO 400, 770 Pixel

		oPanel  := TPanel():New(0,0,,oDlg,,,,,,350,95,.F.,.F.)
		oFont1 	:= TFont():New(STR0075,, -20, .T., .T.,,,,, )
		oFont2 	:= TFont():New(STR0075,, -15, .F., .F.,,,,, )

		oSayTop	:= TSay():New( 10, 15, { || STR0072 }, oPanel,, oFont1 ,,,, .T., CLR_BLUE, ) //"Importação de dados para a conciliação de pagamentos"
		oSayTop	:= TSay():New( 40, 85, { || STR0073 }, oPanel,, oFont2,,,, .T., CLR_BLUE, ) //Selecione abaixo o modo de pagamento:

		oBtnTEF := TButton():New( 65, 30, STR0070, oPanel,{ || FINA914Wiz(lAutomato, lOpt), oDlg:End() }, 100, 30,, oFont1,.F.,.T.,.F.,,.F.,,,.F. ) // TEF
				
		oBtnPD 	:= TButton():New( 65, 150, STR0071, oPanel,{ || IIF((__lAPixTpd .And. cPaisLoc == "BRA"), FINA914a(), (Help(" ", 1, "F914Desatu",, STR0153, 1, 0,,,,,, { STR0154 }))), oDlg:End() }, 120, 30,, oFont1,.F.,.T.,.F.,,.F.,,,.F. ) 

		Activate MsDialog oDlg Centered
	Else
		FINA914Wiz(lAutomato, lOpt)
	EndIf

	RestArea(aArea)

Return

//--------------------------------------------------------------------------
/*{Protheus.doc} FINA914Wiz()
Montagem do wizard para importação dos arquivos

@author Pedro Pereira Lima
@since 18/12/2017
@version 12.1.17
*/
//--------------------------------------------------------------------------
Function FINA914Wiz(lAutomato As Logical, lOpt As Logical)

//Variáveis para uso geral
Private oStepWiz As Object
Private oPagina1 As Object
Private oPagina2 As Object
Private oPagina3 As Object
Private oPagina4 As Object
Private oPagina5 As Object

//Variáveis para a página 2
Private lCheckA	As Logical // Amex
Private lCheckB	As Logical // Cielo
Private lCheckC	As Logical // Rede
Private lCheckD	As Logical // Software Express
Private lWhenA	As Logical
Private lWhenB	As Logical
Private lWhenC	As Logical
Private lWhenD	As Logical
Private lWhenT	As Logical
Private lCheckZ As Logical

//Variáveis para processamento dos arquivos
Private aFolderA As Array // Amex
Private aFolderB As Array // Cielo
Private aFolderC As Array // Rede
Private aFolderD As Array // Software Express

// Variaveis do browse log - FVR
Private aHdrFVR     As Array // Cabecalho do log
Private aLogFVR     As Array // Registros do log
Private oColBrwLog  As Object // Variaveis do browse log - FVR
Private n1  		As Numeric // Variaveis do browse log - FVR
Private n2  		As Numeric // Variaveis do browse log - FVR
Private n3  		As Numeric // Variaveis do browse log - FVR
Private n4  		As Numeric // Variaveis do browse log - FVR
Private n5  		As Numeric // Variaveis do browse log - FVR
Private n6  		As Numeric // Variaveis do browse log - FVR
Private n7  		As Numeric // Variaveis do browse log - FVR
Private n8  		As Numeric // Variaveis do browse log - FVR
Private n9  		As Numeric // Variaveis do browse log - FVR
Private n10 		As Numeric // Variaveis do browse log - FVR
Private n11 		As Numeric // Variaveis do browse log - FVR
Private n12 		As Numeric // Variaveis do browse log - FVR
Private n13 		As Numeric // Variaveis do browse log - FVR
Private n14 		As Numeric // Variaveis do browse log - FVR
Private n15 		As Numeric // Variaveis do browse log - FVR
Private oBrowse     As Object
Private lQtdAlt     As Logical // Define se existe campo para gravar nro de alterações

Default lAutomato := .F.
Default lOpt	  := .T.

lCheckA		:= .F.
lCheckB		:= .F.
lCheckC		:= .F.
lCheckD		:= .F.

lWhenA		:= .F.
lWhenB		:= .F.
lWhenC		:= .F.
lWhenD		:= .F.
lWhenT		:= .F.

lCheckZ		:= .F.
lQtdAlt		:= (FVR->(ColumnPos( 'FVR_QTDALT' ) ) > 0)

//Estrutura:
//	[1] - Rede
//	[2] - Caminho do Arq. para Importação
//	[3] - Caminho dos Arq. Importados
//	[4] - Caminho dos Arq. Inconsistentes
aFolderA := {}
aFolderB := {}
aFolderC := {}
aFolderD := {}
aHdrFVR  := {}
aLogFVR  := {}

If FindFunction("F918AtuTPD") 
	__lAPixTpd := F918AtuTPD() //Valida se o ambiente está atualizado
Endif

If lAutomato
	If Fa914Rede(lAutomato)
		Fa914Imp(lAutomato, lOpt)
	EndIf
Else

	// Instancia a classe FWWizardControl
	oStepWiz := FWWizardControl():New(/*oObjPai*/, { 600, 850 })	
	oStepWiz:ActiveUISteps()
	
	//----------------------
	// Página 1
	//----------------------
	oPagina1 := oStepWiz:AddStep( '1STSTEP', { | Panel | Fa914Pnl1(Panel) } )
	oPagina1:SetStepDescription(STR0001)	//"Início"
	oPagina1:SetNextTitle(STR0002) 	        //"Próximo"
	oPagina1:SetNextAction({ || Fa914Rede() })

	// Define o bloco que será executado ao clicar no botão Voltar
	oPagina1:SetCancelAction({ || .T. })
	
	//----------------------
	// Página 2
	//----------------------
	oPagina2 := oStepWiz:AddStep('2NDSTEP', { | Panel | Fa914Pnl2(Panel) })

	oPagina2:SetStepDescription(STR0003)	//"Layouts"
	oPagina2:SetNextTitle(STR0002)    	    //"Próximo"
	oPagina2:SetNextAction({ || .T. })
	oPagina2:SetCancelWhen({ || lCheckA .Or. lCheckB .Or. lCheckC .Or. lCheckD })

	// Define o bloco que será executado ao clicar no botão Voltar
	oPagina2:SetPrevAction({ || .T. })	
	
	//----------------------
	// Página 3
	//----------------------
	oPagina3 := oStepWiz:AddStep('3RDSTEP', { | Panel | Fa914Pnl3(Panel) })
	oPagina3:SetStepDescription(STR0004) 	//"Processamento"
	oPagina3:SetNextTitle(STR0002) 		    //"Próximo"
	oPagina3:SetNextAction({ || Fa914Imp() })
	oPagina3:SetCancelWhen({ || .F. })
	oPagina3:SetPrevAction({ || .T. })
	
	//----------------------
	// Página 4
	//----------------------
	oPagina4 := oStepWiz:AddStep('4THSTEP', { | Panel | Fa914Pnl4(Panel) })
	oPagina4:SetStepDescription(STR0005)	//"Log"
	oPagina4:SetNextTitle(STR0002)		    //"Próximo"
	oPagina4:SetNextAction({ || .T. })
	oPagina4:SetPrevWhen({ || .F. })
	oPagina4:SetCancelWhen({ || .F. })
	
	//----------------------
	// Página 5
	//----------------------
	oPagina5 := oStepWiz:AddStep('5THSTEP', { | Panel | Fa914Pnl5( Panel ) })
	oPagina5:SetStepDescription(STR0006)	 //"Conclusão"
	oPagina5:SetNextTitle(STR0007)		     //"Finalizar"
	oPagina5:SetNextAction({ || .T. })
	oPagina5:SetCancelWhen({ || .F. })
	
	oStepWiz:Activate()
	
	oStepWiz:Destroy()
EndIf

Return

//--------------------------------------------------------------------------
// Início dos blocos de construçãos das páginas de cada passo
//--------------------------------------------------------------------------

//--------------------------------------------------------------------------
/*{Protheus.doc} Fa914Pnl1
Construção do Painel 1

@param oPanel

@author Pedro Pereira Lima
@since 18/12/2017
@version 12.1.17
*/
//--------------------------------------------------------------------------
Static Function Fa914Pnl1(oPanel As Object)
Local oFont		As Object
Local oSayTop	As Object

oFont 	:= TFont():New( ,, -20, .T., .T.,,,,, )

oSayTop	:= TSay():New( 10, 15, { || STR0008 }, oPanel,, oFont,,,, .T., CLR_BLUE, ) //"Importação de arquivos de conciliação TEF"

Return

//--------------------------------------------------------------------------
/*{Protheus.doc} Fa914Pnl2()
Construção do Painel 2

@param oPanel

@author Pedro Pereira Lima
@since 18/12/2017
@version 12.1.17
*/
//--------------------------------------------------------------------------
Static Function Fa914Pnl2(oPanel As Object)
Local oFontA	As Object
Local oFontB	As Object
Local oSayDesc	As Object
Local oSayFolA	As Object
Local oSayFolB	As Object
Local oSayFolC	As Object
Local oSayFolD	As Object
Local oSayObs	As Object
Local oCheckA	As Object
Local oCheckB	As Object
Local oCheckC	As Object
Local oCheckD	As Object
Local oCheckZ	As Object

oFontA := TFont():New( ,, -16, .T., .T.,,,,, )
oFontB := TFont():New( ,, -12, .T., .T.,,,,, )

oSayDesc := TSay():New( 010, 010, { || STR0009 }, oPanel,, oFontA,,,, .T., CLR_BLUE, )	//"Estão disponíveis os seguintes layouts para conciliação TEF:"

oCheckA := TCheckBox():New( 031, 025, (STR0010 + STR0035 + 'V3.0'), bSetGet( lCheckA ), oPanel, 100, 300,, { |v,w,x| Fa914Focus( oCheckA, oCheckZ ) }, oFontB,,,,, .T.,,, { || lWhenA } )	//"American Express", "\ Versão "
oSayFolA := TSay():New( 031, 170, { || IIf( !Empty( aFolderA ), aFolderA[01][02], STR0023 ) }, oPanel,, oFontB,,,, .T., CLR_GRAY, ) //"Diretório não configurado."

oCheckB := TCheckBox():New( 051, 025, (STR0011 + STR0035 + '013 / 014'), bSetGet( lCheckB ), oPanel, 100, 300,, { |v,w,x| Fa914Focus( oCheckB, oCheckZ ) }, oFontB,,,,, .T.,,, { || lWhenB } )	//"Cielo", "\ Versão "
oSayFolB := TSay():New( 051, 170, { || IIf( !Empty( aFolderB ), aFolderB[01][02], STR0023 ) }, oPanel,, oFontB,,,, .T., CLR_GRAY, ) //"Diretório não configurado."

oCheckC := TCheckBox():New( 071, 025, (STR0012 + STR0035 + 'V2.01') , bSetGet( lCheckC ), oPanel, 100, 300,, { |v,w,x| Fa914Focus( oCheckC, oCheckZ ) }, oFontB,,,,, .T.,,, { || lWhenC } )	//"Rede", "\ Versão "
oSayFolC := TSay():New( 071, 170, { || IIf( !Empty( aFolderC ), aFolderC[01][02], STR0023 ) }, oPanel,, oFontB,,,, .T., CLR_GRAY, ) //"Diretório não configurado."

oCheckD := TCheckBox():New( 091, 025, (STR0013 + STR0035 + 'V3.6'), bSetGet( lCheckD ), oPanel, 100, 300,, { |v,w,x| Fa914Focus( oCheckD, oCheckZ ) }, oFontB,,,,, .T.,,, { || lWhenD } )	//"Software Express", "\ Versão "
oSayFolD := TSay():New( 091, 170, { || IIf( !Empty( aFolderD ), aFolderD[01][02], STR0023 ) }, oPanel,, oFontB,,,, .T., CLR_GRAY, ) //"Diretório não configurado."

oSayObs := TSay():New( 151, 025, { || STR0024 + CRLF + STR0025 }, oPanel,, oFontB,,,, .T., CLR_BLACK,,, 200 ) //"Os diretórios para importação dos arquivos TEF devem ser configurados na rotina 'Código de Administradores Sitef',", "somente nas administradoras que possuírem o campo 'Tipo Cartão' com seu conteúdo preechido como 'Rede'."

oCheckZ := TCheckBox():New( 181, 025, STR0014, bSetGet( lCheckZ ), oPanel, 100, 300,, { |v,w,x,y,z| Fa914ChAll( oCheckA, oCheckB, oCheckC, oCheckD, oCheckZ ) }, oFontB,,,,, .T.,,, { || lWhenT } )	//"Marca/Desmarca todos"

Return

//--------------------------------------------------------------------------
/*{Protheus.doc} Fa914Pnl3()
Construção do Painel 3

@param oPanel

@author Pedro Pereira Lima
@since 18/12/2017
@version 12.1.17
*/
//--------------------------------------------------------------------------
Static Function Fa914Pnl3(oPanel As Object)
Local oFont		As Object
Local oSayDesc	As Object

oFont := TFont():New( ,, -16, .T., .T.,,,,, )

oSayDesc := TSay():New( 10, 10, { || STR0015 }, oPanel,, oFont,,,, .T., CLR_BLUE, ) //"Clique em 'Próximo' para iniciar o processamento dos arquivos."

Return

//--------------------------------------------------------------------------
/*{Protheus.doc} Fa914Pnl4
Construção do Painel 4

@param oPanel

@author Pedro Pereira Lima
@since 19/12/2017
@version 12.1.17
*/
//--------------------------------------------------------------------------
Static Function Fa914Pnl4( oPanel As Object )

Local nX as Numeric

// Iniciliza variáveis private do Browse Log - n1/n2/n3/n4...
n1  := 1
n2  := n1+1
n3  := n2+1
n4  := n3+1
n5  := n4+1
n6  := n5+1
n7  := n6+1
n8  := n7+1
n9  := n8+1
n10 := n9+1
n11 := n10+1
n12 := n11+1
n13 := n12+1
n14 := n13+1
n15 := n14+1
n16 := n15+1

oBrowse := FWBrowse():New()
oBrowse:SetOwner(oPanel)
oBrowse:SetDataArray()
oBrowse:SetArray(aLogFVR)

oBrowse:AddLegend('oBrowse:odata:aarray[oBrowse:At()][aScan(aHdrFVR, {|x| Alltrim(x[2]) == "FVR_STATUS"})] == "0"', "GREEN"	, STR0026) //"Importado com sucesso"
oBrowse:AddLegend('oBrowse:odata:aarray[oBrowse:At()][aScan(aHdrFVR, {|x| Alltrim(x[2]) == "FVR_STATUS"})] == "1"', "RED"	, STR0027) //"Arquivo já importado"
oBrowse:AddLegend('oBrowse:odata:aarray[oBrowse:At()][aScan(aHdrFVR, {|x| Alltrim(x[2]) == "FVR_STATUS"})] == "2"', "WHITE"	, STR0028) //"Versão do arquivo incompatível"
oBrowse:AddLegend('oBrowse:odata:aarray[oBrowse:At()][aScan(aHdrFVR, {|x| Alltrim(x[2]) == "FVR_STATUS"})] == "3"', "BROWN"	, STR0029) //"Falha na abertura do arquivo"
oBrowse:AddLegend('oBrowse:odata:aarray[oBrowse:At()][aScan(aHdrFVR, {|x| Alltrim(x[2]) == "FVR_STATUS"})] == "4"', "YELLOW", STR0030) //"Importado parcialmente"
oBrowse:AddLegend('oBrowse:odata:aarray[oBrowse:At()][aScan(aHdrFVR, {|x| Alltrim(x[2]) == "FVR_STATUS"})] == "5"', "BLACK"	, STR0037) //"Arquivo Inconsistente Serasa"
oBrowse:AddLegend('oBrowse:odata:aarray[oBrowse:At()][aScan(aHdrFVR, {|x| Alltrim(x[2]) == "FVR_STATUS"})] == "6"', "BLUE"	, STR0049) //"Arquivo não importado"

For nX := 1 to Len(aHdrFVR)
	
	If nX <= n16 .And. !(Alltrim(aHdrFVR[nX][2]) $ "FVR_STATUS")
		oColBrwLog := FWBrwColumn():New()
		&("oColBrwLog:SetData({|| aLogFVR[oBrowse:At(), n"+Alltrim(Str(nX))+" ]})")
		&("oColBrwLog:SetTitle( (aHdrFVR[n"+Alltrim(Str(nX))+"][1]) )")
		oBrowse:SetColumns({oColBrwLog})
	EndIf
	
Next nX

oBrowse:Activate() //-- Ativação do Browse

Return

//--------------------------------------------------------------------------
/*{Protheus.doc} Fa914Pnl5
Construção do Painel 5

@param oPanel

@author Pedro Pereira Lima
@since 18/12/2017
@version 12.1.17
*/
//--------------------------------------------------------------------------
Static Function Fa914Pnl5( oPanel As Object )

oFont := TFont():New( ,, -16, .T., .T.,,,,, )

oSayDesc := TSay():New( 10, 10, { || STR0022 }, oPanel,, oFont,,,, .T., CLR_BLUE, ) //"Importação concluída."

Return

//--------------------------------------------------------------------------
/*{Protheus.doc} Fa914Rede()
Verificação de quais redes estão configuradas para importação de arquivos

@author Pedro Pereira Lima
@since 20/12/2017
@version 12.1.17
*/
//--------------------------------------------------------------------------
Static Function Fa914Rede( lAutomato As Logical ) As Logical

Local cAliasQry	  As Character
Local lRetorno    As Logical
Local cDiretA     As Character
Local cDiretB     As Character
Local cDiretC     As Character
Local cDiretD     As Character
Local lFolderA12  As Logical
Local lFolderA13  As Logical
Local lFolderA14  As Logical
Local lFolderB12  As Logical
Local lFolderB13  As Logical
Local lFolderB14  As Logical
Local lFolderC12  As Logical
Local lFolderC13  As Logical
Local lFolderC14  As Logical
Local lFolderD12  As Logical
Local lFolderD13  As Logical
Local lFolderD14  As Logical
Local lExisA      As Logical
Local lExisB      As Logical
Local lExisC      As Logical
Local lExisD      As Logical
Local cDir1       As Character
Local cDir2       As Character
Local cDir3       As Character
Local cAlert      As Character
Local nRemType    As Numeric
Local cRemType    As Character
Local lF914Help   As Logical
Local cF914Help   As Character

Default lAutomato := .F.

cAliasQry  := GetNextAlias()
lRetorno   := .T.
lFolderA12 := .F.
lFolderA13 := .F.
lFolderA14 := .F.
lFolderB12 := .F.
lFolderB13 := .F.
lFolderB14 := .F.
lFolderC12 := .F.
lFolderC13 := .F.
lFolderC14 := .F.
lFolderD12 := .F.
lFolderD13 := .F.
lFolderD14 := .F.
lExisA     := .F.
lExisB     := .F.
lExisC     := .F.
lExisD     := .F.
cDiretA    := ""
cDiretB    := ""
cDiretC    := ""
cDiretD    := ""
cAlert     := ""
nRemType   := GetRemoteType(@cRemType)
cF914Help  := ""
lF914Help  := .F.

cDir1 := Posicione("SX3",2,"MDE_ARQIMP","X3Titulo()")
cDir2 := Posicione("SX3",2,"MDE_ARQPRO","X3Titulo()")
cDir3 := Posicione("SX3",2,"MDE_ARQINC","X3Titulo()")

BeginSql Alias cAliasQry
	SELECT MDE.MDE_CODIGO, MDE.MDE_DESC, MDE.MDE_ARQIMP, MDE.MDE_ARQPRO, MDE.MDE_ARQINC
	
	FROM %Table:MDE% MDE
	
	WHERE
	MDE.MDE_TIPO = %Exp:'RD'%
	AND	MDE.MDE_ARQIMP <> %Exp:' '%
	AND MDE.MDE_DESC IN (%Exp:'REDE'%,%Exp:'REDECARD'%,%Exp:'AMEX'%,%Exp:'AMERICAN EXPRESS'%,%Exp:'CIELO'%,%Exp:'SOFTWARE EXPRESS'%,%Exp:'SOFTWAREEXPRESS'%)
	AND MDE.%NotDel%
EndSql

(cAliasQry)->( dbGoTop() )
While !(cAliasQry)->( Eof() )
	If AllTrim( (cAliasQry)->MDE_DESC ) $ 'AMEX|AMERICAN EXPRESS'
		
		aAdd( aFolderA, {'AMEX', AllTrim( (cAliasQry)->MDE_ARQIMP ), AllTrim( (cAliasQry)->MDE_ARQPRO ), AllTrim( (cAliasQry)->MDE_ARQINC ), AllTrim( (cAliasQry)->MDE_CODIGO ) } )
		
		//Verifica se os Diretorios cadastrados existem
		lFolderA12 := ExistDir(aFolderA[01][02])
		lFolderA13 := ExistDir(aFolderA[01][03])
		lFolderA14 := ExistDir(aFolderA[01][04])
		
		If lFolderA12 .AND. lFolderA13 .AND. lFolderA14
			If Len(Directory( aFolderA[01][02] + '\*.*' )) > 0
				lWhenA := .T.
				If lAutomato
					lCheckA := .T.
				EndIf
			EndIf
		EndIf
		
		If !lFolderA12
			lExisA := .T.
			cDiretA += If(Empty(Alltrim(cDiretA)),"",chr(13)+chr(10))+cDir1+": "+If(!Empty(Alltrim(aFolderA[01][02])),aFolderA[01][02],STR0023)
		EndIf
		
		If !lFolderA13
			lExisA := .T.
			cDiretA += If(Empty(Alltrim(cDiretA)),"",chr(13)+chr(10))+cDir2+": "+If(!Empty(Alltrim(aFolderA[01][03])),aFolderA[01][03],STR0023)
		EndIf
		
		If !lFolderA14
			lExisA := .T.
			cDiretA += If(Empty(Alltrim(cDiretA)),"",chr(13)+chr(10))+cDir3+": "+If(!Empty(Alltrim(aFolderA[01][04])),aFolderA[01][04],STR0023)
		EndIf
		
		If lExisA
			cAlert += If(Empty(Alltrim(cAlert)),"",chr(13)+chr(10))+chr(13)+chr(10)+"- "+STR0010+chr(13)+chr(10)+cDiretA
		End
		
	ElseIf AllTrim( (cAliasQry)->MDE_DESC ) $ 'CIELO'
		
		aAdd( aFolderB, {'CIELO', AllTrim( (cAliasQry)->MDE_ARQIMP ), AllTrim( (cAliasQry)->MDE_ARQPRO ), AllTrim( (cAliasQry)->MDE_ARQINC ), AllTrim( (cAliasQry)->MDE_CODIGO ) } )
		
		//Verifica se os Diretorios cadastrados existem
		lFolderB12 := ExistDir(aFolderB[01][02])
		lFolderB13 := ExistDir(aFolderB[01][03])
		lFolderB14 := ExistDir(aFolderB[01][04])
		
		If lFolderB12 .AND. lFolderB13 .AND. lFolderB14
			If Len(Directory( aFolderB[01][02] + '\*.*' )) > 0
				lWhenB := .T.
				If lAutomato
					lCheckB := .T.
				EndIf
			EndIf
		EndIf
		
		If !lFolderB12
			lExisB := .T.
			cDiretB += If(Empty(Alltrim(cDiretB)),"",chr(13)+chr(10))+cDir1+": "+If(!Empty(Alltrim(aFolderB[01][02])),aFolderB[01][02],STR0023)
		EndIf
		
		If !lFolderB13
			lExisB := .T.
			cDiretB += If(Empty(Alltrim(cDiretB)),"",chr(13)+chr(10))+cDir2+": "+If(!Empty(Alltrim(aFolderB[01][03])),aFolderB[01][03],STR0023)
		EndIf
		
		If !lFolderB14
			lExisB := .T.
			cDiretB += If(Empty(Alltrim(cDiretB)),"",chr(13)+chr(10))+cDir3+": "+If(!Empty(Alltrim(aFolderB[01][04])),aFolderB[01][04],STR0023)
		EndIf
		
		If lExisB
			cAlert += If(Empty(Alltrim(cAlert)),"",chr(13)+chr(10))+chr(13)+chr(10)+"- "+STR0011+chr(13)+chr(10)+cDiretB
		End
		
	ElseIf AllTrim( (cAliasQry)->MDE_DESC ) $ 'REDE|REDECARD'
		
		aAdd( aFolderC, {'REDE', AllTrim( (cAliasQry)->MDE_ARQIMP ), AllTrim( (cAliasQry)->MDE_ARQPRO ), AllTrim( (cAliasQry)->MDE_ARQINC ), AllTrim( (cAliasQry)->MDE_CODIGO ) } )
		
		//Verifica se os Diretorios cadastrados existem
		lFolderC12 := ExistDir(aFolderC[01][02])
		lFolderC13 := ExistDir(aFolderC[01][03])
		lFolderC14 := ExistDir(aFolderC[01][04])
		
		If lFolderC12 .AND. lFolderC13 .AND. lFolderC14
			If Len(Directory( aFolderC[01][02] + '\*.*' )) > 0
				lWhenC := .T.
				If lAutomato
					lCheckC := .T.
				EndIf
			EndIf
		EndIf
		
		If !lFolderC12
			lExisC := .T.
			cDiretC += If(Empty(Alltrim(cDiretC)),"",chr(13)+chr(10))+cDir1+": "+If(!Empty(Alltrim(aFolderC[01][02])),aFolderC[01][02],STR0023)
		EndIf
		
		If !lFolderC13
			lExisC := .T.
			cDiretC += If(Empty(Alltrim(cDiretC)),"",chr(13)+chr(10))+cDir2+": "+If(!Empty(Alltrim(aFolderC[01][03])),aFolderC[01][03],STR0023)
		EndIf
		
		If !lFolderC14
			lExisC := .T.
			cDiretC += If(Empty(Alltrim(cDiretC)),"",chr(13)+chr(10))+cDir3+": "+If(!Empty(Alltrim(aFolderC[01][04])),aFolderC[01][04],STR0023)
		EndIf
		
		If lExisC
			cAlert := If(Empty(Alltrim(cAlert)),"",chr(13)+chr(10))+chr(13)+chr(10)+"- "+STR0012+chr(13)+chr(10)+cDiretC
		End
		
	ElseIf AllTrim( (cAliasQry)->MDE_DESC ) $ 'SOFTWAREEXPRESS|SOFTWARE EXPRESS'
		
		aAdd( aFolderD, {'SOFESS', AllTrim( (cAliasQry)->MDE_ARQIMP ), AllTrim( (cAliasQry)->MDE_ARQPRO ), AllTrim( (cAliasQry)->MDE_ARQINC ), AllTrim( (cAliasQry)->MDE_CODIGO ) } )
		
		//Verifica se os Diretorios cadastrados existem
		lFolderD12 := ExistDir(aFolderD[01][02])
		lFolderD13 := ExistDir(aFolderD[01][03])
		lFolderD14 := ExistDir(aFolderD[01][04])
		
		If lFolderD12 .AND. lFolderD13 .AND. lFolderD14
			If Len(Directory( aFolderD[01][02] + '\*.*' )) > 0
				lWhenD := .T.
				If lAutomato
					lCheckD := .T.
				EndIf
			EndIf
		EndIf
		
		If !lFolderD12
			lExisD := .T.
			cDiretD += If(Empty(Alltrim(cDiretD)),"",chr(13)+chr(10))+cDir1+": "+If(!Empty(Alltrim(aFolderD[01][02])),aFolderD[01][02],STR0023)
		EndIf
		
		If !lFolderD13
			lExisD := .T.
			cDiretD += If(Empty(Alltrim(cDiretD)),"",chr(13)+chr(10))+cDir2+": "+If(!Empty(Alltrim(aFolderD[01][03])),aFolderD[01][03],STR0023)
		EndIf
		
		If !lFolderD14
			lExisD := .T.
			cDiretD += If(Empty(Alltrim(cDiretD)),"",chr(13)+chr(10))+cDir3+": "+If(!Empty(Alltrim(aFolderD[01][04])),aFolderD[01][04],STR0023)
		EndIf
		
		If lExisD
			cAlert += If(Empty(Alltrim(cAlert)),"",chr(13)+chr(10))+chr(13)+chr(10)+"- "+STR0013+chr(13)+chr(10)+cDiretD
		End
		
	EndIf
	
	(cAliasQry)->( dbSkip() )
EndDo

If lWhenA .Or. lWhenB .Or. lWhenC .Or. lWhenD
	lWhenT := .T.
EndIf

(cAliasQry)->( dbCloseArea() )

If lAutomato
	lRetorno := lWhenA .OR. lWhenB .OR. lWhenC .OR. lWhenD
EndIf

If lExisA .Or. lExisB .OR. lExisC .OR. lExisD
	Alert(STR0038+chr(13)+chr(10)+cAlert)
End

If nRemType = 5 // SmartCliente HTML sendo usado
	If !Empty( aFolderA ) .AND. (Substr(ltrim(aFolderA[01][02]),1,1) <> "\" .OR. Substr(ltrim(aFolderA[01][03]),1,1) <> "\" .OR. Substr(ltrim(aFolderA[01][04]),1,1) <> "\")
		lF914Help := .T.
	End
	
	If !Empty( aFolderB ) .AND. (Substr(ltrim(aFolderB[01][02]),1,1) <> "\" .OR. Substr(ltrim(aFolderB[01][03]),1,1) <> "\" .OR. Substr(ltrim(aFolderB[01][04]),1,1) <> "\" )
		lF914Help := .T.
	End
	
	If !Empty( aFolderC ) .AND. (Substr(ltrim(aFolderC[01][02]),1,1) <> "\" .OR. Substr(ltrim(aFolderC[01][03]),1,1) <> "\" .OR. Substr(ltrim(aFolderC[01][04]),1,1) <> "\" )
		lF914Help := .T.
	End
	
	If !Empty( aFolderD ) .AND. (Substr(ltrim(aFolderD[01][02]),1,1) <> "\" .OR. Substr(ltrim(aFolderD[01][03]),1,1) <> "\" .OR. Substr(ltrim(aFolderD[01][04]),1,1) <> "\" )
		lF914Help := .T.
	End
	
	If lF914Help
		HELP(NIL, NIL, "F914HELP", NIL, STR0038+" "+STR0045 , 1, 0, NIL, NIL, NIL, NIL, NIL, {STR0039+chr(13)+chr(10)+chr(13)+chr(10)+STR0040+chr(13)+chr(10)+STR0041+chr(13)+chr(10)+STR0042+chr(13)+chr(10)+STR0043})
	End
	
End

Return lRetorno

//--------------------------------------------------------------------------
/*{Protheus.doc} Fa914Imp()
Função que prepara a importação dos layouts disponíveis

@author Pedro Pereira Lima
@since 26/12/2017
@version 12.1.17
*/
//--------------------------------------------------------------------------
Static Function Fa914Imp(lAutomato As Logical, lOpt As Logical) As Logical
Local aArqRede	As Array
Local aArqCielo	As Array
Local aArqAmex	As Array
Local aArqSofEx	As Array
Local aExistFld	As Array
Local nQtdRedes	As Numeric
Local nQtdAmex	As Numeric
Local nQtdCielo	As Numeric
Local nQtdRede	As Numeric
Local nQtdSofEx	As Numeric
Local oProcess	As Object

Default lAutomato := .F.
Default lOpt	  := .T.

nQtdRedes	:= 0
nQtdAmex	:= 0
nQtdCielo	:= 0
nQtdRede	:= 0
nQtdSofEx	:= 0
aArqRede	:= {}
aArqCielo	:= {}
aArqAmex	:= {}
aArqSofEx	:= {}
aExistFld	:= { .T., .T., .T., .T. }

If !Empty( aFolderA ) .And. lCheckA
	If ExistDir( aFolderA[01][02] )
		aArqAmex := Directory( aFolderA[01][02] + '\*.*' )
		nQtdRedes++
	Else
		aExistFld[1] := .F.
	EndIf
EndIf

If !Empty( aFolderB ) .And. lCheckB
	If ExistDir( aFolderB[01][02] )
		aArqCielo := Directory( aFolderB[01][02] + '\*.*' )
		nQtdRedes++
	Else
		aExistFld[2] := .F.
	EndIf
EndIf

If !Empty( aFolderC ) .And. lCheckC
	If ExistDir( aFolderC[01][02] )
		aArqRede := Directory( aFolderC[01][02] + '\*.*' )
		nQtdRedes++
	Else
		aExistFld[3] := .F.
	EndIf
EndIf

If !Empty( aFolderD ) .And. lCheckD
	If ExistDir( aFolderD[01][02] )
		aArqSofEx := Directory( aFolderD[01][02] + '\*.*' )
		nQtdRedes++
	Else
		aExistFld[4] := .F.
	EndIf
EndIf

If lAutomato
	Fa914Proc( oProcess, nQtdRedes, aArqAmex, aArqCielo, aArqRede, aArqSofEx, aExistFld, lAutomato, lOpt )
Else
	oProcess := MsNewProcess():New( { | s, t, u, v, w, x, y, z | Fa914Proc( oProcess, nQtdRedes, aArqAmex, aArqCielo, aArqRede, aArqSofEx, aExistFld ) }, STR0016, "...", .F. ) //"Importação de Arquivos TEF"
	oProcess:Activate()
EndIf

Return .T.

//--------------------------------------------------------------------------
/*{Protheus.doc} Fa914Proc()
Função que processa a importação dos layouts disponíveis

@author Pedro Pereira Lima
@since 26/12/2017
@version 12.1.17
*/
//--------------------------------------------------------------------------
Static Function Fa914Proc( oProcess As Object, nQtd As Numeric, aAmex As Array, aCielo As Array, aRede As Array, aSofEx As Array, aExistFld As Array, lAutomato As Logical, lOpt As Logical )

Local nX		As Numeric
Local nZ		As Numeric
Local nHandle	As Numeric
Local nQtdReg	As Numeric
Local nTamParc	As Numeric
Local nVlBrut	As Numeric
Local nVlLiq	As Numeric
Local nVlCom	As Numeric
Local nTamBco	As Numeric
Local nTamAge	As Numeric
Local nTamCta	As Numeric
Local nTxAdm	As Numeric
Local nTxServ	As Numeric
Local nParcelas	As Numeric
Local nTamPar	As Numeric
Local nTamTot	As Numeric
Local nQtdNProc	As Numeric
Local nQtdFilOk	As Numeric
Local nQdtImp   As Numeric
Local nQtdAlt   As Numeric
Local nLinha	As Numeric
Local cTipReg   As Character
Local cCurrLine	As Character
Local cEmpTef	As Character
Local cNumRV	As Character
Local cNumCV	As Character
Local cNuComp   As Character
Local cTime		As Character
Local cNumCart	As Character
Local cCodAut	As Character
Local cTotPar	As Character
Local cCodBan	As Character
Local cCaptura	As Character
Local cSeqFIF	As Character
Local cQuery	As Character
Local cCodAmex	As Character
Local cCodCielo	As Character
Local cCodRede	As Character
Local cCodSOFEX	As Character
Local cHoraIni	As Character
Local cStatus	As Character
Local cProdDeb  As Character
Local cFIFAlias	As Character
Local cNSUTEF	As Character
Local cNSUARQ   As Character
Local cMotAjust As Character
Local cCodFil   As Character
Local cParcela  As Character
Local cTipoParc As Character
Local cParAlf   As Character
Local dDataIni	As Date
Local dDataTef	As Date
Local dDtCredito As Date
Local dDtPagtoOp As Date
Local lErro		As Logical
Local lInclui	As Logical
Local lLancPgto	As Logical
Local lDebito	As Logical
Local lLinOk	As Logical
Local lContinua As Logical
Local aBanco	As Array
Local aCurrLine	As Array
Local aCieAjus	As Array
Local aCieParc	As Array
Local aAuxCie	As Array
Local cParcTot	As Character
Local cParcAtu	As Character
Local cParcUlt	As Character
Local nPc		As Numeric
Local lParcela  As Logical
Local cArqEEFI 	As Character
Local lTem035 	As Logical
Local cParc   	As Character
Local cNuresu  	As Character
Local cCodEst  	As Character
Local dDataDeb	As Date
Local dDataCre	As Date
Local nQtd035 	As Numeric
Local nTamNsu	As Numeric
Local nRoVBrut 	As Numeric
Local nSomaVBrut As Numeric
Local nDifVBrut	 As Numeric
Local cDescLeg   As Character
Local cIdProc    As Character
Local aArqLog    As Array
Local cLinLog    As Character
Local cNomArq 	 As Character
Local cCodEstab  As Character
Local aCodEst    As Array
Local nPos27 	 As Numeric
Local nQtdSerasa As Numeric
Local aRegNProc  As Array
Local nRegNProc  As Numeric
Local cCodUser	 As Character
Local lFilEmp 	 As Logical
Local nQtdLida 	 As Numeric
Local nLinTotal  As Numeric
Local a012Parc   As Array
Local n012VlTot  As Numeric
Local n012Vl1Par As Numeric
Local n012VlDema As Numeric
Local nK 		 As Numeric
Local lBackReg   As Logical 
Local cFifNuComp As Character
Local lCarEsp    As Logical
Local lNsutef    As Logical
Local lNuComp    As Logical

cArqEEFI := GetNextAlias()

Default lAutomato := .F.
Default lOpt	  := .T.

aFields := {}
aAdd( aFields, { "CODEST", "C", 9, 0 } )
aAdd( aFields, { "FILIAL", "C", 20, 0 } )
aAdd( aFields, { "NURESU", "C", 9, 0 } )
aAdd( aFields, { "DTTEF", "D", 8, 0 } )
aAdd( aFields, { "NSUTEF", "C", 12, 0 } )
aAdd( aFields, { "NSUARQ", "C", 12, 0 } )
aAdd( aFields, { "NUCART", "C", 16, 0 } )
aAdd( aFields, { "CAPTUR", "C", 1, 0 } )
aAdd( aFields, { "VLR", "C", TamSX3('FIF_VLBRUT')[1], TamSX3('FIF_VLBRUT')[2] } )
aAdd( aFields, { "PARC"	, "C", 3, 0 } )
aAdd( aFields, { "NUMPV", "C", 9, 0 } )
aAdd( aFields, { "MOTAJUST", "C", 2, 0 } )
aAdd( aFields, { "VLBRUT", "C", TamSX3('FIF_VLBRUT')[1], TamSX3('FIF_VLBRUT')[2] } )
aAdd( aFields, { "VLAJUST", "C", TamSX3('FIF_VLBRUT')[1], TamSX3('FIF_VLBRUT')[2] } )
aAdd( aFields, { "VLRTX", "C", TamSX3('FIF_VLBRUT')[1], TamSX3('FIF_VLBRUT')[2] } )
aAdd( aFields, { "VLRPARC", "C", TamSX3('FIF_VLBRUT')[1], TamSX3('FIF_VLBRUT')[2] } )
aAdd( aFields, { "VLRORIG", "C", TamSX3('FIF_VLBRUT')[1], TamSX3('FIF_VLBRUT')[2] } )
aAdd( aFields, { "STDCRED"	, "C", 1, 0 } )

// Alimenta array de Tipos de registros que o Conciliador não processará
// Operadora / Tipo de Registro /Cod.Estab Inicio / Cod.Estab Tam./ Descrição do Registro
aRegNProc:={}
aAdd(aRegNProc,{STR0012,STR0091, 4,9,STR0092})
aAdd(aRegNProc,{STR0012,STR0093, 4,9,STR0094})
aAdd(aRegNProc,{STR0012,STR0095, 4,9,STR0096})
aAdd(aRegNProc,{STR0012,STR0097, 4,9,STR0098})
aAdd(aRegNProc,{STR0012,STR0099, 4,9,STR0100})
aAdd(aRegNProc,{STR0012,STR0101, 4,9,STR0102})
aAdd(aRegNProc,{STR0012,STR0103, 4,9,STR0104})
aAdd(aRegNProc,{STR0012,STR0105, 4,9,STR0106})
aAdd(aRegNProc,{STR0012,STR0107, 0,0,STR0108})
aAdd(aRegNProc,{STR0012,STR0109, 4,9,STR0110})
aAdd(aRegNProc,{STR0012,STR0111, 4,9,STR0112})
aAdd(aRegNProc,{STR0012,STR0113, 4,9,STR0114})
aAdd(aRegNProc,{STR0012,STR0115, 4,9,STR0116})
aAdd(aRegNProc,{STR0012,STR0117, 4,9,STR0118})
aAdd(aRegNProc,{STR0012,STR0119, 4,9,STR0120})
aAdd(aRegNProc,{STR0012,STR0121, 4,9,STR0122})
aAdd(aRegNProc,{STR0012,STR0123, 4,9,STR0124})
aAdd(aRegNProc,{STR0012,STR0125, 4,9,STR0126})
aAdd(aRegNProc,{STR0012,STR0127,37,9,STR0128})
aAdd(aRegNProc,{STR0012,STR0129,29,9,STR0130})
aAdd(aRegNProc,{STR0012,STR0131,70,9,STR0132})
aAdd(aRegNProc,{STR0012,STR0133,70,9,STR0134})
aAdd(aRegNProc,{STR0012,STR0135, 4,9,STR0136})
aAdd(aRegNProc,{STR0012,STR0137, 0,0,STR0138})
aAdd(aRegNProc,{STR0012,STR0139, 0,0,STR0140})
aAdd(aRegNProc,{STR0012,STR0141, 0,0,STR0142})
aAdd(aRegNProc,{STR0012,STR0143, 0,0,STR0144})

aAdd(aRegNProc,{STR0011,STR0145,2,10,STR0146})
aAdd(aRegNProc,{STR0011,STR0147,2,10,STR0148})
aAdd(aRegNProc,{STR0011,STR0149,2,10,STR0150})
aAdd(aRegNProc,{STR0011,STR0151,2,10,STR0152})

//Cria tabela temporária no banco de dados
__oFINA914 := FwTemporaryTable():New(cArqEEFI)
__oFINA914:SetFields(aFields)
__oFINA914:AddIndex("1", {"CODEST","DTTEF","NURESU"})
__oFINA914:Create()

//Alimento os HashTables
Fa914Hash()
Fa914Fil()

cQuery := " SELECT MAX(FIF_SEQFIF) MAXFIF FROM " + RetSqlName("FIF")

dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), "TRB" )

If TRB->( !Eof() )
	cSeqFIF := Soma1( TRB->MAXFIF )
Else
	cSeqFIF := Soma1( "000000" )
EndIf

TRB->(DbCloseArea())

nQtdReg		:= 0
nQtdAlt		:= 0 
aBanco		:= {}
lErro		:= .F.
nVlBrut		:= 0
nVlLiq		:= 0
nVlCom		:= 0
nTxServ		:= 0
nParcelas	:= 0
lLancPgto	:= .F.
lDebito		:= .F.
cProdDeb	:= ""
cTipoParc 	:= SuperGetMV( "MV_1DUP", .F., "1" )
cMotAjust	:= ""
cTipReg		:= ""
aCieAjus	:= {}
aCieParc	:= {}
aAuxCie		:= {}
cParcTot	:= ""
cParcAtu	:= ""
cParcUlt	:= ""
nPc			:= 0
nRoVBrut 	:= 0
nSomaVBrut 	:= 0
nDifVBrut	:= 0
lParcela	:= .F.
dDtCredito  := CtoD("")
dDtPagtoOp  := CtoD("")

nTamParc	:= TamSX3('E1_PARCELA')[1]
nTamNsu	    := TamSX3('E1_NSUTEF')[1]
nTamBco	    := TamSX3('FIF_CODBCO')[1]
nTamAge	    := TamSX3('FIF_CODAGE')[1]
nTamCta	    := TamSX3('FIF_NUMCC')[1]
nTamTot	    := TamSX3('FIF_TOTPAR')[1]
nTamPar	    := TamSX3('FIF_PARCEL')[1]
nTamNSUTEF  := TAMSX3("FIF_NSUTEF")[1]
nTamTXSERV  := TAMSX3("FIF_TXSERV")[2]
nTamVLLIQ   := TAMSX3("FIF_VLLIQ")[2]
nTamVLBRUT  := TAMSX3("FIF_VLBRUT")[2]
nTamNUCOMP  := TAMSX3("FIF_NUCOMP")[1]
nTamVLCOM   := TAMSX3("FIF_VLCOM")[2]
nTamLinha   := TAMSX3("FV3_LINARQ")[1]
nTxAdm		:= 0
cCodUser	:= RetCodUsr() //R

aHdrFVR 	:= apBuildHeader("FVR",{"FVR_IDPROC","FVR_NOMADM","FVR_NOMUSU"}) // Guarda os campos da tabela de Log

If !lQtdAlt // Caso o Campo FVR_QTDALT não exista inclui manualmente para demosntrar apenas no wizard.
	aAdd(aHdrFVR,{"Linhas Editadas","FVR_QTDALT","@E 9,999,999,999,999,999                     ",16,0,;
	"                                                                                                                                ",;
	"x       x       x       x       x       x       x       x       x       x       x       x       x       x       x x     ",;
	"N","      "," "})
EndIf

a012Parc    := {}

If !lAutomato
	oProcess:SetRegua1( nQtd )
EndIf
//------------------------------------------------
// Processamento dos arquivos AMEX
//------------------------------------------------
If !Empty( aAmex ) .And. aExistFld[1]
	
	If !lAutomato
		oProcess:IncRegua1( STR0017 ) //"Processando arquivos do layout AMEX"
		
		oProcess:SetRegua2( Len( aAmex ) )
	EndIf
	
	For nX := 1 To Len( aAmex )
		//Seto a variável como falso novamente (caso já tenha sido executada)
		lErro 	    := .F.
		aBanco 	    := {}
		lContinua	:= .T.
		lLancPgto	:= .F.
		cCodFil		:= ""
		nQtdReg		:= 0
		nQtdAlt		:= 0 
		nQtdNProc	:= 0
		nQdtImp  	:= 0
		nLinha		:= 0
		nVlBrut		:= 0
		nVlLiq		:= 0
		nVlCom		:= 0
		nTxServ		:= 0
		nParcelas	:= 0
		lLinOk		:= .T.
		dDataIni 	:= dDataBase
		cTime		:= Time()
		cHoraIni 	:= SubStr( cTime, 01, 08 )
		cStatus		:= ""
		cNSUTEF		:= ""
		cNSUARQ     := ""
		cNomArq 	:= ""
		cCodEstab 	:= ""
		cNuComp 	:= ""
		cIdProc 	:= ""
		aArqLog 	:= {}
		aCodEst 	:= {}
		nPos27 		:= 0
		cLinLog 	:= ""
		cDescLeg 	:= ""
		nQtdLida 	:= 0
		nLinTotal   := 0
		cFifNuComp  := ""
		lCarEsp 	:= .F.
		lNsutef     := .F.
		lNuComp		:= .F.
		
		If !lAutomato
			oProcess:IncRegua2( STR0018 + aAmex[nX][01] ) //"Processando arquivo: "
		EndIf
		
		DbSelectArea("FVR")
		DbSetOrder(2) //FVR_NOMARQ+DTOS(FVR_DTPROC)+FVR_HRPROC
		
		cIdProc  := GetSxeNum("FVR","FVR_IDPROC")
		cCodAmex := aFolderA[01][05]
		cNomArq  := aAmex[nX][01]
		
		If FVR->(DbSeek(SubStr(aAmex[nX][01],1,__nTmNomAr)))
			lErro 		:= .T.
			cStatus		:= "1" // 1=Arquivo já importado
			cDescLeg 	:= STR0027
		Else
			
			nHandle := FT_FUSE( aFolderA[01][02] + '\' + aAmex[nX][01] )
			
			If nHandle != -1
				FT_FGOTOP()
				
				cCurrLine := FT_FREADLN()
				
				BEGIN TRANSACTION
				
				While !FT_FEOF()
					
					nLinha++
					lLinOk	:= !Empty(cCurrLine)
					cLinLog := StrZero( nLinha, nTamLinha )
					
					// Tratamento da linha para evitar error.log com linhas em branco e arquivos sem vínculo com a operadora (sujeira)
					If lLinOk
						aCurrLine	:= StrToKArr( cCurrLine, ',' )
						If nLinha == 1 .And. ( Len(aCurrLine) > 06 .And. aCurrLine[06] <> '0')
							cStatus	:= "2" // 2=Versão do arquivo incompatível
							cDescLeg := STR0028+" "+Alltrim(aCurrLine[12])+"."
							lErro 	:= .T.
							lLinOk := .F.
							Exit
						ElseIf nLinha == 1 .and. Len(aCurrLine) < 06
							cStatus	:= "2" // 2=Versão do arquivo incompatível
							cDescLeg := STR0028+"."
							lErro 	:= .T.
							lLinOk := .F.
							Exit
						ElseIf nLinha > 1 .And. Len(aCurrLine) < 06
							lLinOk := .F.
						EndIf
					EndIf
					
					If lLinOk
						//Header
						If aCurrLine[06] == '0'
							nQtdLida++
							If aCurrLine[12] != 'V 3.0' //Caso a versão do arquivo seja diferente da versão 3.0, não processo
								lErro 	:= .T.
								cStatus	:= "2" // 2=Versão do arquivo incompatível
								cDescLeg := STR0028+" "+Alltrim(aCurrLine[12])+"."
								//HELP(" ",1,"VERSAO",,STR0031 + aCurrLine[12] + STR0032 + aAmex[nX][01] + STR0033 ,2,0,,,,,, {STR0034}) //"A versão ", " do arquivo ", " não está homologada no Protheus."
								Exit
							EndIf
						ElseIf aCurrLine[06] == '9'// Trailer
							nQtdLida++
						Endif
						
						lContinua	:= Fa914VldImp(aCurrLine[01], "AMEX" ,@cCodFil) // Valida se filial poderá ser importada
						
						If !lContinua .and. aCurrLine[06] <> '0' .and. aCurrLine[06] <> '9' // Não valido empresa/filial para Header e Trailer
							nQtdNProc++
							cCodEstab 	:= aCurrLine[01]
							cNuComp 	:= Alltrim(aCurrLine[09])
							If Alltrim(cCodFil) == ""
								cDescLeg :=  STR0036
							Endif
							F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg,"AMEX",,,,@aCodEst,.T.,cCodFil) // Grava detalhes do Log
						Endif
					EndIf
					
					If lLinOk .and. lContinua
						
						//Resumo de vendas
						If aCurrLine[06] == '1'
							
							nQtdLida++
							aAdd( aBanco, SubStr( aCurrLine[09], ( 09 - nTamBco ) + 1, nTamBco ) )
							aAdd( aBanco, SubStr( aCurrLine[10], ( 06 - nTamAge ) + 1, nTamAge ) )
							aAdd( aBanco, SubStr( aCurrLine[11], ( 20 - nTamCta ) + 1, nTamCta ) )
							lLancPgto := Alltrim(aCurrLine[20]) == "P" // Lançamento de Pagamento
							
							//Detalhamento dos comprovantes de vendas
						ElseIf aCurrLine[06] == '3'
							
							nQtdLida++
							nVlBrut := Val(LEFT(aCurrLine[11], Len(Alltrim(aCurrLine[11]))-2)+"."+RIGHT(aCurrLine[11], 2))
							nVlDesc	:= -(Val(LEFT(aCurrLine[12], Len(Alltrim(aCurrLine[12]))-2)+"."+RIGHT(aCurrLine[12], 2))) // Conforme layout AMEX, vlr virá  com "-" se for valor negativo. O Sinal é invertido para tratar positivo e negativo
							nTxServ	:= Round(( nVlDesc / nVlBrut )  * 100, nTamTXSERV)
							
							//Detalhamento dos comprovantes de vendas
						ElseIf aCurrLine[06] == '4'
							
							// Valida inclusao ou atualização da FIF
							lInclui		:= .T.
							cNSUTEF	 	:= PADR("", nTamNsu - len(Alltrim(aCurrLine[09])),"0") + Alltrim(aCurrLine[09])
							cFifNuComp 	:= PADR("", nTamNUCOMP - len(Alltrim(aCurrLine[09])),"0") + Alltrim(aCurrLine[09])
							cNSUARQ	 	:= Alltrim(aCurrLine[09])
							cParcela 	:= Iif(Val(SubStr( aCurrLine[16], ( 5 - nTamPar ) + 1, nTamPar )) > 0 ,SubStr( aCurrLine[16], ( 5 - nTamPar ) + 1, nTamPar ),'1')
							cParcela 	:= Padl(cParcela,nTamParc,'0')
							cParAlf  	:= TrataParc( cParcela, cTipoParc )
							
							DbSelectArea("FIF")
							FIF->(DbSetOrder(6)) //FIF_CODFIL, FIF_DTCRED, FIF_NSUTEF, FIF_PARCEL
							If FIF->(DbSeek(cCodFil + aCurrLine[02] + cNSUTEF + cParcela))
								
								If lLancPgto
									If Empty(FIF->FIF_STATUS) // Se FIF foi incluída manualmente estará com status "FIF_STATUS" como " "
										lInclui	:= .F. // Nesse caso será necessário atualizar os dados
										cDescLeg  := STR0064
										F914GrvLog('2', cIdProc, cLinLog, cNomArq, dDataIni, cHoraIni,aCurrLine[01],cNSUTEF,cDescLeg,"AMEX",,,,,.F.)
									Else
										lContinua := .F. // do contrario não prossegue, pula o registro
									EndIf
								Else
									If FIF->FIF_STVEND == "6" // Se  FIF foi incluída manualmente pela conciliacao vendas estará com status "FIF_STVEND" como "6"
										lInclui	:= .F. // Nesse caso será necessário atualizar os dados
										cDescLeg  := STR0064
										F914GrvLog('2', cIdProc, cLinLog, cNomArq, dDataIni, cHoraIni,aCurrLine[01],cNSUTEF,cDescLeg,"AMEX",,,,,.F.)
									Else
										lContinua := .F. // do contrario não prossegue, pula o registro
									EndIf
								EndIf
							EndIf
							
							// Validação para verificar caracter especial na composição dos campos FIF_NSUTEF e FIF_NUCOMP
							lCarEsp := FINCARCESP(cNSUTEF,cFifNuComp)
							
							If !lContinua .or. lCarEsp
								nQtdNProc++
								nQdtImp++
								cCodEstab 	:= aCurrLine[01]
								If !lCarEsp
									cDescLeg := STR0047 + ' '+  cNSUTEF
								else
									cDescLeg := STR0066 
									lCarEsp  := .F.
								Endif 	
								
								F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNSUTEF,cDescLeg,STR0067) // Grava detalhes do Log
							Else
								Iif(lInclui,nQtdReg++,nQtdAlt++)
								nQtdLida++
								nParcelas	:= Val(Alltrim(aCurrLine[15]))
								If nParcelas > 0
									nVlBrut	:= Val(LEFT(aCurrLine[13], Len(Alltrim(aCurrLine[13]))-2)+"."+RIGHT(aCurrLine[13], 2))
								Else
									nVlBrut	:= Val(LEFT(aCurrLine[12], Len(Alltrim(aCurrLine[12]))-2)+"."+RIGHT(aCurrLine[12], 2))
								EndIf
								nVlLiq	:= Round(nVlBrut - (nVlBrut * nTxServ / 100), nTamVLLIQ)
								nVlCom	:= nVlBrut - nVlLiq
								
								RecLock( 'FIF', lInclui )
								FIF->FIF_FILIAL	:= xFilial("FIF")
								FIF->FIF_TPREG	:= '1'
								FIF->FIF_INTRAN := '0'
								FIF->FIF_CODEST := aCurrLine[01]
								FIF->FIF_DTTEF	:= StoD( aCurrLine[08] )
								FIF->FIF_NURESU	:= cNSUTEF
								FIF->FIF_NUCOMP := cFifNuComp
								FIF->FIF_NSUTEF := cNSUTEF
								FIF->FIF_NUCART := aCurrLine[11]
								FIF->FIF_VLBRUT := nVlBrut
								FIF->FIF_TOTPAR := SubStr( aCurrLine[15], ( 5 - nTamTot ) + 1, nTamTot )
								FIF->FIF_VLLIQ	:= nVlLiq
								FIF->FIF_VLCOM 	:= nVlCom
								FIF->FIF_TXSERV	:= nTxServ
								FIF->FIF_DTCRED := StoD( aCurrLine[02] )
								FIF->FIF_PARCEL := cParcela
								FIF->FIF_TPPROD := 'C'
								FIF->FIF_CAPTUR := ''
								FIF->FIF_CODRED := ''
								FIF->FIF_CODBCO := aBanco[1]
								FIF->FIF_CODAGE := aBanco[2]
								FIF->FIF_NUMCC	:= aBanco[3]
								FIF->FIF_CODAUT := aCurrLine[10]
								FIF->FIF_SEQREG := PadL( Str( nQtdReg ), 6, '0' )
								FIF->FIF_DTIMP	:= dDataBase
								FIF->FIF_MSIMP	:= DtoS( dDataBase )
								FIF->FIF_CODFIL := cCodFil
								FIF->FIF_CODBAN := ''
								FIF->FIF_SEQFIF	:= cSeqFIF
								FIF->FIF_PARALF	:= cParAlf
								If lLancPgto
									FIF->FIF_STATUS	:= '1' // 1-Não Conciliado para Pagamento
									FIF->FIF_ARQPAG := aAmex[nX][01]
								Else
									FIF->FIF_STVEND	:= '1' // 1-Não Conciliado para Vendas
									FIF->FIF_ARQVEN := aAmex[nX][01]
								EndIf
								FIF->FIF_CODADM	:= cCodAmex
								FIF->FIF_CODLOJ := aCurrLine[01]
								FIF->FIF_NSUARQ := cNSUARQ
								If __lAPixTpd
									FIF->FIF_MODPAG	:= '1' // 1-TEF / 2_Carteiras Digitais
								Endif
								
								FIF->( MsUnlock() )
								
								cSeqFIF := Soma1( cSeqFIF )
							EndIf
							
							
							//Ajustes a crédito ou a débito serão demonstrados através deste registro
						ElseIf aCurrLine[06] == '5'
							
							cEmpTef		:= aCurrLine[01]
							cNSUTEF		:= PADR("", nTamNsu - len(Alltrim(aCurrLine[24])),"0") + Alltrim(aCurrLine[24])
							cFifNuComp  := PADR("", nTamNUCOMP - len(Alltrim(aCurrLine[24])),"0") + Alltrim(aCurrLine[24])
							cNSUARQ     := aCurrLine[24]
							cFIFAlias	:= GetNextAlias()
							nPos27 		:= Len(aCurrLine)
							
							cQuery := " SELECT FIF_NSUTEF   "
							cQuery += " FROM "+RetSqlName("FIF")
							cQuery += " WHERE FIF_FILIAL = '" + xFilial("FIF") + "' "
							cQuery += "   AND FIF_TPREG  = '3' "
							cQuery += "   AND FIF_INTRAN = '0' "
							cQuery += "   AND FIF_DTTEF  = '" + aCurrLine[23] + "' "
							cQuery += "   AND FIF_NSUTEF = '" + cNSUTEF + "' "
							cQuery += "   AND FIF_NUCART = '" + aCurrLine[14] + "' "
							cQuery += "   AND FIF_VLBRUT = "+ Str(Round( Val( aCurrLine[9] ) / 100, nTamVLBRUT ))+" "
							cQuery += "   AND FIF_VLLIQ	 = "+ Str(Round( Val( aCurrLine[13] ) / 100, nTamVLLIQ ))+" "
							cQuery += "   AND FIF_DTCRED  = '" + aCurrLine[02] + "' "
							cQuery += "   AND FIF_TPPROD = 'C' "
							cQuery += "   AND FIF_CODADM = '" + cCodAmex + "' "
							cQuery += "   AND FIF_CODMAJ = '" + aCurrLine[15] + "' "
							cQuery += "   AND FIF_CODFIL = '" + cCodFil + "' "
							cQuery += "   AND FIF_CODEST = '" + cEmpTef + "' "
							cQuery += "   AND FIF_CODLOJ = '" + cEmpTef + "' "
							If nPos27 == 27
								cQuery += "   AND FIF_IDORAJ = '" + aCurrLine[27] + "' "
							Endif
							cQuery := ChangeQuery(cQuery)
							
							dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cFIFAlias,.F.,.T.)
							(cFIFAlias)->(dbgotop())
							
							If 	(cFIFAlias)->(!EOF())
								lContinua := .F.
							EndIf
							(cFIFAlias)->( dbCloseArea() )
							
							// Validação para verificar caracter especial na composição dos campos FIF_NSUTEF e FIF_NUCOMP
							lCarEsp := FINCARCESP(cNSUTEF,cFifNuComp)
							
							If !lContinua .or. lCarEsp
								nQtdNProc++
								nQdtImp++
								cCodEstab 	:= aCurrLine[01]
								If !lCarEsp
									cDescLeg := STR0048 + ' '+  cNSUTEF
								else
									cDescLeg := STR0066
									lCarEsp  := .F.
								Endif		

								F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNSUTEF,cDescLeg,STR0067) // Grava detalhes do Log
								
							Else
								
								nQtdReg++
								nQtdLida++
								RecLock( 'FIF', .T. )
								FIF->FIF_FILIAL	:= xFilial("FIF")
								FIF->FIF_TPREG	:= '3'
								FIF->FIF_INTRAN := '0'
								FIF->FIF_CODEST := cEmpTef
								FIF->FIF_DTTEF	:= StoD( aCurrLine[23] )
								FIF->FIF_NURESU	:= cNSUTEF
								FIF->FIF_NUCOMP := cFifNuComp
								FIF->FIF_NSUTEF := cNSUTEF
								FIF->FIF_NUCART := aCurrLine[14]
								FIF->FIF_VLBRUT := Round( Val( aCurrLine[9] ) / 100, nTamVLBRUT )
								FIF->FIF_TOTPAR := ""
								FIF->FIF_VLLIQ	:= Round( Val( aCurrLine[13] ) / 100, nTamVLLIQ )
								FIF->FIF_VLCOM 	:= FIF->FIF_VLBRUT - FIF->FIF_VLLIQ
								FIF->FIF_TXSERV	:= Round(( FIF->FIF_VLCOM / FIF->FIF_VLBRUT )  * 100, nTamTXSERV)
								FIF->FIF_DTCRED := StoD( aCurrLine[02] )
								FIF->FIF_PARCEL := ""
								FIF->FIF_TPPROD := "C"
								FIF->FIF_CAPTUR := ""
								FIF->FIF_CODRED := ""
								FIF->FIF_CODBCO := ""
								FIF->FIF_CODAGE := ""
								FIF->FIF_NUMCC	:= ""
								FIF->FIF_SEQREG := PadL( Str( nQtdReg ), 6, '0' )
								FIF->FIF_DTIMP	:= dDataBase
								FIF->FIF_MSIMP	:= DtoS( dDataBase )
								FIF->FIF_CODFIL := cCodFil
								FIF->FIF_CODBAN := ""
								FIF->FIF_SEQFIF	:= cSeqFIF
								If lLancPgto
									FIF->FIF_STATUS	:= '1' // 1-Não Conciliado para Pagamento
									FIF->FIF_ARQPAG := aAmex[nX][01]
								Else
									FIF->FIF_STVEND	:= '1' // 1-Não Conciliado para Vendas
									FIF->FIF_ARQVEN := aAmex[nX][01]
								EndIf
								FIF->FIF_CODADM	:= cCodAmex
								FIF->FIF_CODMAJ := aCurrLine[15]
								FIF->FIF_CODLOJ := cEmpTef
								If nPos27 == 27
									FIF->FIF_IDORAJ := aCurrLine[27]
								EndIf
								FIF->FIF_NSUARQ := cNSUARQ
								If __lAPixTpd
									FIF->FIF_MODPAG	:= '1' // 1-TEF / 2_Carteiras Digitais
								Endif
								
								FIF->( MsUnlock() )
								
								cSeqFIF := Soma1( cSeqFIF )
							EndIf
						EndIf
						
					EndIf
					
					FT_FSKIP()
					cCurrLine	:= FT_FREADLN()
					
				EndDo
				
				If cStatus <> "2"
					A914Status(@lErro, @cStatus, @cDescLeg, nQtdReg, nQtdNProc, nLinha, nQtdLida, nQdtImp, 0, nqtdAlt)
				EndIf
				
				END TRANSACTION
			Else
				//Erro na abertura do arquivo
				lErro 	:= .T.
				cStatus	:= "3" // 3="Falha na abertura do arquivo"
				cDescLeg := STR0029
			EndIf
			
			FT_FUSE()
		EndIf
		
		nLinTotal := nQtdNProc + nQtdLida
		F914GrvLog('1',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg,'AMEX',nQtdReg,nQtdNProc,cStatus,,,,cCodAmex,cCodUser,nQtdLida,nLinTotal)
		
		// Guarda Log temporário
		F914LogFVR( FVR->(Recno()) )
		
		//Copio o arquivo para o folder correspondente
		If lErro
			_CopyFile( aFolderA[01][02] + '\' + aAmex[nX][01], aFolderA[01][04] + '\' + aAmex[nX][01] )
		Else
			_CopyFile( aFolderA[01][02] + '\' + aAmex[nX][01], aFolderA[01][03] + '\' + aAmex[nX][01] )
		EndIf
		
		FERASE( aFolderA[01][02] + '\' + aAmex[nX][01] )
		
		nQtdReg := 0
		
	Next nX
EndIf

//------------------------------------------------
// Processamento dos arquivos CIELO
//------------------------------------------------
If !Empty( aCielo ) .And. aExistFld[2]
	
	If !lAutomato
		oProcess:IncRegua1( STR0019 ) //"Processando arquivos do layout Cielo"
		
		oProcess:SetRegua2( Len( aCielo ) )
	EndIf
	
	For nX := 1 To Len( aCielo )
		//Seto a variável como falso novamente (caso já tenha sido executada)
		lErro 	    := .F.
		aBanco 	    := {}
		lContinua	:= .T.
		lDebito		:= .F.
		cCodFil		:= ""
		nQtdReg     := 0
		nQtdAlt		:= 0 
		nQtdNProc	:= 0
		nQdtImp		:= 0
		dDataIni 	:= dDataBase
		cTime		:= Time()
		cHoraIni 	:= SubStr( cTime, 01, 08 )
		cStatus		:= ""
		cProdDeb	:= "011/014/017/018/022/023/025/036/037/041/045/046/065/066/071/094/097" // Códigos de produtos débitos conforme layout CIELO (Tabela IV)
		cMotAjust	:= ""
		cTipReg		:= ""
		aCieAjus	:= {}
		aCieParc	:= {}
		aAuxCie		:= {}
		cParcTot	:= ""
		cParcAtu	:= ""
		cParcUlt	:= ""
		cNSUTEF		:= ""
		cNSUARQ     := ""
		nPc			:= 0
		nRoVBrut 	:= 0
		nSomaVBrut 	:= 0
		nDifVBrut	:= 0
		lParcela	:= .F.
		dDtCredito  := CtoD("")
		dDtPagtoOp  := CtoD("")
		cCodEstab 	:= ""
		cIdProc 	:= ""
		aArqLog 	:= {}
		cNomArq 	:= ""
		cCodEstab 	:= ""
		cNuComp 	:= ""
		aCodEst 	:= {}
		cLinLog 	:= ""
		cDescLeg 	:= ""
		nLinha 		:= 0
		lFilEmp 	:= .F.
		nQtdLida 	:= 0
		nLinTotal 	:= 0
		lCarEsp 	:= .F.
		lNsutef     := .F.
		lNuComp		:= .F.
		
		If !lAutomato
			oProcess:IncRegua2( STR0018 + aCielo[nX][01] ) //"Processando arquivo: "
		EndIf
		
		DbSelectArea("FVR")
		DbSetOrder(2) //FVR_NOMARQ+DTOS(FVR_DTPROC)+FVR_HRPROC
		
		cIdProc   := GetSxeNum("FVR","FVR_IDPROC")
		cCodCielo := aFolderB[01][05]
		cNomArq   := aCielo[nX][01]
		
		If FVR->(DbSeek(SubStr(aCielo[nX][01],1,__nTmNomAr)))
			lErro 		:= .T.
			cStatus			:= "1" // 1=Arquivo já importado
			cDescLeg 	:= STR0027
		Else
			
			nHandle := FT_FUSE( aFolderB[01][02] + '\' + aCielo[nX][01] )
			
			If nHandle != -1
				FT_FGOTOP()
				
				cCurrLine := FT_FREADLN()
				
				If Alltrim(SubStr(cCurrLine,048,002)) == "04" // Lançamento de Pagamentos
					
					BEGIN TRANSACTION
					
					While !FT_FEOF()
						
						nLinha++
						lLinOk	:= !Empty(cCurrLine)
						cLinLog := StrZero( nLinha, nTamLinha )
						
						If !Empty(cCurrLine)
							
							//Header
							If SubStr(cCurrLine,1,1) == '0'
								nQtdLida++
								// Identifica o tipo de arquivo e o nome comercial do estabelecimento
								If SubStr(cCurrLine,071,003) != '001' .and. (SubStr(cCurrLine,071,003) != '013' .and. SubStr(cCurrLine,071,003) != '014')  //Verifico se as versoes dos arquivos sao homologadas.
									lErro := .T.
									cStatus	:= "2" // 2=Versão do arquivo incompatível
									cDescLeg :=	STR0028+" "+Alltrim(SubStr(cCurrLine,071,003))+"."
									//HELP(" ",1,"VERSAO",,STR0031 + SubStr(cCurrLine,071,003) + STR0032 + aCielo[nX][01] + STR0033 ,2,0,,,,,, {STR0034}) //"A versão ", " do arquivo ", " não está homologada no Protheus."
									Exit
								EndIf
							Endif
							//Detalhe RO
							
							If SubStr(cCurrLine,1,1) == '9' // Trailler
								// Grava ajustes que não possuem detalhes de venda
								If Len(aCieAjus) > 0
									
									// Valida inclusao ou atualização da FIF
									lInclui	:= .T.
									lContinua := .T.
									dDtCredito := aCieAjus[aScan(aCieAjus, {|x| x[1] == "FIF_DTCRED"})][2]
									cNumCV := PADR(aCieAjus[aScan(aCieAjus, {|x| x[1] == "FIF_NUCOMP"})][2],nTamNUCOMP,'')

									FIF->(DbSetOrder(7)) //FIF_FILIAL+DTOS(FIF_DTCRED)+FIF_NUCOMP+FIF_PARCEL
									If FIF->(DbSeek(cCodFil + DtoS(dDtCredito) + cNumCV ))
										
										If Alltrim(FIF->FIF_TPREG) == '3' .And. Alltrim(FIF->FIF_CODADM) == cCodCielo //3-Ajustes
											lInclui	:= .F. // Nesse caso será necessário atualizar os dados

											cAjuLinArq  := aCieAjus[aScan(aCieAjus, {|x| x[1] == "CLINARQ"})][2]
											cAjuCodEst  := aCieAjus[aScan(aCieAjus, {|x| x[1] == "FIF_CODEST"})][2]
											cDescLeg  := STR0063 //"Registro alterado por motivo de ajuste" 
											F914GrvLog('2', cIdProc, cAjuLinArq, cNomArq, dDataIni, cHoraIni,cAjuCodEst,cNumCV,cDescLeg,"CIELO",,,,,.F.)
										EndIf
									EndIf
									
									If lContinua
										Iif(lInclui,nQtdReg++,nQtdAlt++)
										RecLock( 'FIF', lInclui )
										For nZ := 2 to Len(aCieAjus)
											FIF->&( aCieAjus[nZ][1] ) := aCieAjus[nZ][2]
										Next nZ
										FIF->FIF_ARQVEN := aCielo[nX][01]
										If __lAPixTpd
											FIF->FIF_MODPAG	:= '1' // 1-TEF / 2-Carteiras Digitais
										Endif
										FIF->( MsUnlock() )
										cSeqFIF := Soma1( cSeqFIF )
									Endif
									aCieAjus:= {}
								EndIf
								nQtdLida++
							EndIf
							
							If SubStr(cCurrLine,1,1) <> '0' .and. SubStr(cCurrLine,1,1) <> '9'
								lContinua	:= Fa914VldImp(SubStr(cCurrLine,2,10), "CIELO", @cCodFil ) // Valida se filial poderá ser importada
								
								If !lContinua
									nQtdNProc++
									cCodEstab 	:= SubStr(cCurrLine,2,10)
									cNuComp 	:= PADR("", nTamNUCOMP - len(Alltrim(SubStr(cCurrLine,188,015))),'0') + Alltrim(SubStr(cCurrLine,188,015))
									cDescLeg 	:= STR0036
									F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg,"CIELO",,,,@aCodEst,.T.,cCodFil) // Grava detalhes do Log
									
								Else
									If SubStr(cCurrLine,1,1) == '1'
										
										// Grava ajustes que não possuem detalhes de venda
										If Len(aCieAjus) > 0 .And. lContinua
											
											// Valida inclusao ou atualização da FIF
											lInclui	:= .T.
											dDtCredito := aCieAjus[aScan(aCieAjus, {|x| x[1] == "FIF_DTCRED"})][2]
											cNumCV := PADR(aCieAjus[aScan(aCieAjus, {|x| x[1] == "FIF_NUCOMP"})][2],nTamNUCOMP,'')
											
											FIF->(DbSetOrder(7))//FIF_CODFIL+DTOS(FIF_DTCRED)+FIF_NUCOMP+FIF_PARCEL
											If FIF->(DbSeek(cCodFil + DtoS(dDtCredito) + cNumCV ))
												
												If Alltrim(FIF->FIF_TPREG) == '3' .And. Alltrim(FIF->FIF_CODADM) == cCodCielo //3-Ajustes
													lInclui	:= .F. // Nesse caso será necessário atualizar os dados
													
													cAjuLinArq  := aCieAjus[aScan(aCieAjus, {|x| x[1] == "CLINARQ"})][2]
													cAjuCodEst  := aCieAjus[aScan(aCieAjus, {|x| x[1] == "FIF_CODEST"})][2]
													cDescLeg    := STR0063 //"Registro alterado por motivo de ajuste" 
													F914GrvLog('2', cIdProc, cAjuLinArq, cNomArq, dDataIni, cHoraIni,cAjuCodEst,cNumCV,cDescLeg,"CIELO",,,,,.F.)
												EndIf
											EndIf
											
											Iif(lInclui,nQtdReg++,nQtdAlt++)
											RecLock( 'FIF', lInclui )
											For nZ := 2 to Len(aCieAjus)
												FIF->&( aCieAjus[nZ][1] ) := aCieAjus[nZ][2]
											Next nZ
											FIF->FIF_ARQPAG := aCielo[nX][01]
											If __lAPixTpd
												FIF->FIF_MODPAG	:= '1' // 1-TEF / 2-Carteiras Digitais
											Endif	
											FIF->( MsUnlock() )
											cSeqFIF := Soma1( cSeqFIF )
											aCieAjus:= {}
										EndIf
										nQtdLida++
										// Detalhe do RO (com a primeira parcela) & Detalhe do RO (previsão da segunda parcela em diante)
										If lContinua
											aAdd( aBanco, Right(Alltrim(SubStr(cCurrLine,100,004)),nTamBco) ) // Banco
											aAdd( aBanco, AllTrim( SubStr(cCurrLine,104,005) ) ) // Agência
											aAdd( aBanco, AllTrim( SubStr(cCurrLine,109,014) ) ) // Conta
											
											cCodRede	:= SubStr(cCurrLine,224,001)
											cNumCV 		:= PADR("", nTamNUCOMP - len(Alltrim(SubStr(cCurrLine,188,015))),'0') + Alltrim(SubStr(cCurrLine,188,015))
											cCodBan		:= SubStr(cCurrLine,185,003)
											nTxAdm		:= Round( Val( SubStr(cCurrLine,210,004) ) / 100, 2 )
											cCaptura	:= SubStr(cCurrLine,223,002)
											lDebito 	:= Alltrim(SubStr(cCurrLine,233,003)) $ cProdDeb
											cMotAjust	:= Alltrim(SubStr(cCurrLine,146,002))
											
											dDtCredito	:= CtoD(SubStr(cCurrLine,036,002)+"/"+SubStr(cCurrLine,034,002)+"/"+SubStr(cCurrLine,032,002))
											
											If !Empty(cMotAjust)
												cTipReg := '3' // 3-Ajustes
												
												// Armazena dados para caso o ajuste não tenha detalhe de venda
												nVlLiq		:= Round( Val( SubStr(cCurrLine,087,013) ) / 100, nTamVLLIQ )
												aCieAjus := {}
												aAdd(aCieAjus, {"CLINARQ"   , cLinLog} ) 
												aAdd(aCieAjus, {"FIF_FILIAL", xFilial("FIF")} )
												aAdd(aCieAjus, {"FIF_TPREG"	, cTipReg} )
												aAdd(aCieAjus, {"FIF_INTRAN", "0"} )
												aAdd(aCieAjus, {"FIF_CODEST", SubStr(cCurrLine,2,10)} )
												aAdd(aCieAjus, {"FIF_DTTEF" , dDtCredito} )
												aAdd(aCieAjus, {"FIF_NURESU", ""} )
												aAdd(aCieAjus, {"FIF_NUCOMP", cNumCV} )
												aAdd(aCieAjus, {"FIF_NSUTEF", ""} )
												aAdd(aCieAjus, {"FIF_NUCART", cNumCart} )
												aAdd(aCieAjus, {"FIF_VLBRUT", nVlLiq} )
												aAdd(aCieAjus, {"FIF_VLLIQ" , nVlLiq} )
												aAdd(aCieAjus, {"FIF_DTCRED", dDtCredito} )
												aAdd(aCieAjus, {"FIF_TPPROD", IIf( lDebito, 'D', 'C')} )
												aAdd(aCieAjus, {"FIF_CAPTUR", cCaptura} )
												aAdd(aCieAjus, {"FIF_CODRED", cCodRede} )
												aAdd(aCieAjus, {"FIF_CODBCO", aBanco[1]} )
												aAdd(aCieAjus, {"FIF_CODAGE", aBanco[2]} )
												aAdd(aCieAjus, {"FIF_NUMCC" , aBanco[3]} )
												aAdd(aCieAjus, {"FIF_SEQREG", PadL( Str( nQtdReg ), 6, '0' )} )
												aAdd(aCieAjus, {"FIF_DTIMP" , dDataBase} )
												aAdd(aCieAjus, {"FIF_MSIMP" , DtoS( dDataBase )} )
												aAdd(aCieAjus, {"FIF_CODFIL", cCodFil} )
												aAdd(aCieAjus, {"FIF_CODBAN", cCodBan} )
												aAdd(aCieAjus, {"FIF_SEQFIF", cSeqFIF} )
												aAdd(aCieAjus, {"FIF_STATUS", '1'} ) // 1-Não Conciliado para Pagamento
												aAdd(aCieAjus, {"FIF_CODADM", cCodCielo} )
												aAdd(aCieAjus, {"FIF_CODMAJ", cMotAjust} )
												aAdd(aCieAjus, {"FIF_CODLOJ", SubStr(cCurrLine,2,10)} )
												
											ElseIf SubStr(cCurrLine,161,001) == "A" //A-Antecipado na CIELO - ARV
												cTipReg := '20' //20-Transações Antecipadas
											ElseIf SubStr(cCurrLine,021,001) == "A" //Tratamento para aceleração de parcelas
												cTipReg := '3'
												cMotAjust := "AP" // Motivo para Aceleração de Parcelas da CIELO
											Else
												cTipReg := '1'
											EndIf
										EndIf
										//Detalhe CV
									ElseIf SubStr(cCurrLine,1,1) == '2'
										// Detalhe do comprovante de venda
										cEmpTef	:= SubStr(cCurrLine,002,010)
										cNSUTEF := PADR("", nTamNsu - len(Alltrim(SubStr(cCurrLine,093,006))),"0") + Alltrim(SubStr(cCurrLine,093,006))
										
										If lContinua
											// Valida inclusao ou atualização da FIF
											lInclui	 := .T.
											cNSUARQ  := SubStr(cCurrLine,093,006)
											cParcela := IiF(Val(SubStr(cCurrLine,060,002)) > 0, SubStr(cCurrLine,060,002), '1')
											cParcela := Padl(Val(cParcela),nTamParc,'0')
											cParAlf  := TrataParc( cParcela, cTipoParc )
											
											DbSelectArea("FIF")
											FIF->(DbSetOrder(6)) //FIF_CODFIL, FIF_DTCRED, FIF_NSUTEF, FIF_PARCEL
											If FIF->(DbSeek(cCodFil + DtoS(dDtCredito) + cNSUTEF + cParcela))
												While ((cCodFil + DtoS(dDtCredito) + cNSUTEF + cParcela ) == (FIF->FIF_CODFIL + DtoS(FIF->FIF_DTCRED) + FIF->FIF_NSUTEF + FIF->FIF_PARCEL))
													If Alltrim(FIF->FIF_NUCOMP) == cNumCV
														If Empty(FIF->FIF_STATUS) .Or. cTipReg == "3" // Se FIF foi incluída manualmente estará com status "FIF_STATUS" como " "
															lInclui	:= .F. // Nesse caso será necessário atualizar os dados
															cDescLeg  := IIF(cTipReg == "3",STR0063,STR0064) //"Registro alterado por motivo de ajuste" //"Registro incluido manualmente foi atualizado"
															F914GrvLog('2', cIdProc, cLinLog, cNomArq, dDataIni, cHoraIni,cEmpTef,cNumCV,cDescLeg,"CIELO",,,,,.F.)
														Else
															lContinua := .F. // do contrario não prossegue, pula o registro
														EndIf
														Exit
													Endif
													FIF->(Dbskip())
												EndDo
											Else
												If cTipReg == '20' // Não inclui antecipações pelo pagamento casonão encontre a venda, pois estas são efetuadas pelo arquivo 06-Antecipações de Recebíveis
													lContinua := .F.
												Endif
											EndIf
											
											// Validação para verificar caracter especial na composição dos campos FIF_NSUTEF e FIF_NUCOMP
											lCarEsp := FINCARCESP(cNSUTEF,cNumCV,@lNsuTef,@lNuComp)
											
											If lContinua .and. !lCarEsp
												Iif(lInclui,nQtdReg++,nQtdAlt++)
												nQtdLida++
												cNumRV		:= SubStr(cCurrLine,012,007)
												cNumCart	:= SubStr(cCurrLine,019,019)
												cCodAut		:= SubStr(cCurrLine,067,006)
												dDataTef	:= StoD( SubStr(cCurrLine,038,008) )
												nVlBrut		:= Round( Val( SubStr(cCurrLine,047,013) ) / 100, 2 )
												nVlLiq		:= nVlBrut - Round( ( nVlBrut * ( nTxAdm / 100 ) ), 2 )
												nVlCom		:= nVlBrut - nVlLiq
												
												RecLock( 'FIF', lInclui )
												FIF->FIF_FILIAL	:= xFilial("FIF")
												FIF->FIF_TPREG	:= cTipReg
												FIF->FIF_INTRAN := '0'
												FIF->FIF_CODEST := cEmpTef
												FIF->FIF_DTTEF	:= dDataTef
												FIF->FIF_NURESU	:= cNumRV
												FIF->FIF_NUCOMP := cNumCV
												FIF->FIF_NSUTEF := cNSUTEF
												FIF->FIF_NUCART := cNumCart
												FIF->FIF_VLBRUT := nVlBrut
												FIF->FIF_TOTPAR := SubStr(cCurrLine,062,002)
												FIF->FIF_VLLIQ	:= nVlLiq
												FIF->FIF_DTCRED := dDtCredito
												FIF->FIF_PARCEL := cParcela
												FIF->FIF_TPPROD := IIf( lDebito, 'D', 'C')
												FIF->FIF_CAPTUR := cCaptura
												FIF->FIF_CODRED := cCodRede
												FIF->FIF_CODBCO := aBanco[1]
												FIF->FIF_CODAGE := aBanco[2]
												FIF->FIF_NUMCC	:= aBanco[3]
												FIF->FIF_CODAUT := cCodAut
												FIF->FIF_SEQREG := PadL( Str( nQtdReg ), 6, '0' )
												FIF->FIF_DTIMP	:= dDataBase
												FIF->FIF_MSIMP	:= DtoS( dDataBase )
												FIF->FIF_CODFIL := cCodFil
												FIF->FIF_CODBAN := cCodBan
												FIF->FIF_SEQFIF	:= cSeqFIF
												FIF->FIF_PARALF	:= cParAlf
												FIF->FIF_STATUS := Iif(cTipReg == '20' ,'6','1' ) // 1-Não Conciliado para Pagamento
												FIF->FIF_CODADM	:= cCodCielo
												FIF->FIF_CODLOJ := cEmpTef
												FIF->FIF_TXSERV	:= nTxAdm
												FIF->FIF_VLCOM	:= nVlCom
												If cTipReg == "3" // 3-Ajustes
													FIF->FIF_CODMAJ := cMotAjust
													aCieAjus := {}
												EndIf
												
												FIF->FIF_ARQPAG := aCielo[nX][01]
												FIF->FIF_NSUARQ := cNSUARQ
												If __lAPixTpd
													FIF->FIF_MODPAG	:= '1' // 1-TEF / 2_Carteiras Digitais
												Endif	
												
												FIF->( MsUnlock() )
												
												cSeqFIF := Soma1( cSeqFIF )
											Else
												nQtdNProc++
												nQdtImp++
												cCodEstab 	:= SubStr(cCurrLine,2,10)
												cNuComp 	:= cNumCV
												cDescLeg 	:= STR0047 + ' '+  cNSUTEF
												If !lCarEsp
													cDescLeg 	:= STR0047 + ' '+  cNSUTEF
												else
													cDescLeg := STR0066
													lCarEsp  := .F.
												Endif	
												
												F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,Iif(lNsutef,cNSUTEF,cNuComp),cDescLeg,STR0011) // Grava detalhes do Log

												lNsuTef  := .F.
												lNuComp  := .F.
											EndIf
										Else
											nQtdNProc++
											cCodEstab 	:= cEmpTef
											cNuComp 	:= ""
											cDescLeg 	:= STR0047 + ' '+  cNSUTEF
											
											F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cCodest,cDescLeg) // Grava detalhes do Log
										EndIf
									Endif
								Endif
							EndIf
						EndIf
						
						FT_FSKIP()
						cCurrLine := FT_FREADLN()
						
					EndDo
					
					END TRANSACTION
					
				ElseIf Alltrim(SubStr(cCurrLine,048,002)) == "03" // Lançamento de vendas com plano parcelado
					
					BEGIN TRANSACTION
					
					lFilEmp := .F.
					nQtdLida  := 0
					nLinTotal := 0
					
					While !FT_FEOF()
						
						nLinha++
						lLinOk	:= !Empty(cCurrLine)
						cLinLog := StrZero( nLinha, nTamLinha )
						
						If !Empty(cCurrLine)
							
							//Header
							If SubStr(cCurrLine,1,1) == '0'
								nQtdLida++
								// Identifica o tipo de arquivo e o nome comercial do estabelecimento
								If SubStr(cCurrLine,071,003) != '001' .and. (SubStr(cCurrLine,071,003) != '013' .and.  SubStr(cCurrLine,071,003) != '014')  //Verifico se as versoes dos arquivos sao homologadas.
									lErro := .T.
									cStatus	:= "2" // 2=Versão do arquivo incompatível
									cDescLeg :=	STR0028+" "+Alltrim(SubStr(cCurrLine,071,003))+"."
									//HELP(" ",1,"VERSAO",,STR0031 + SubStr(cCurrLine,071,003) + STR0032 + aCielo[nX][01] + STR0033 ,2,0,,,,,, {STR0034}) //"A versão ", " do arquivo ", " não está homologada no Protheus."
									Exit
								EndIf
							EndIf
							
							If SubStr(cCurrLine,1,1) == '9' // Trailler
								nQtdLida++
								// Grava ajustes que não possuem detalhes de venda
								If Len(aCieAjus) > 0
									
									// Valida inclusao ou atualização da FIF
									lInclui	:= .T.
									lContinua := .T.
									dDtCredito := aCieAjus[aScan(aCieAjus, {|x| x[1] == "FIF_DTCRED"})][2]
									cNumCV := PADR(aCieAjus[aScan(aCieAjus, {|x| x[1] == "FIF_NUCOMP"})][2],nTamNUCOMP,'')
									
									FIF->(DbSetOrder(7)) //FIF_FILIAL+DTOS(FIF_DTCRED)+FIF_NUCOMP+FIF_PARCEL
									If FIF->(DbSeek(cCodFil + DtoS(dDtCredito) + cNumCV ))
										
										If Alltrim(FIF->FIF_TPREG) == '3' .And. Alltrim(FIF->FIF_CODADM) == cCodCielo //3-Ajustes
											lInclui	:= .F. // Nesse caso será necessário atualizar os dados
											
											cAjuLinArq  := aCieAjus[aScan(aCieAjus, {|x| x[1] == "CLINARQ"})][2]
											cAjuCodEst  := aCieAjus[aScan(aCieAjus, {|x| x[1] == "FIF_CODEST"})][2]
											cDescLeg  := STR0063 //"Registro alterado por motivo de ajuste" 
											F914GrvLog('2', cIdProc, cAjuLinArq, cNomArq, dDataIni, cHoraIni,cAjuCodEst,cNumCV,cDescLeg,"CIELO",,,,,.F.)
										EndIf
									EndIf
									
									If lContinua
										
										Iif(lInclui,nQtdReg++,nQtdAlt++) // só conta como registro bom se não tiver a venda e for incluido por aqui.
										
										RecLock( 'FIF', lInclui )
										For nZ := 2 to Len(aCieAjus)
											FIF->&( aCieAjus[nZ][1] ) := aCieAjus[nZ][2]
										Next nZ
										FIF->FIF_ARQVEN := aCielo[nX][01]
										If __lAPixTpd
											FIF->FIF_MODPAG	:= '1' // 1-TEF / 2-Carteiras Digitais
										Endif	
										FIF->( MsUnlock() )
										cSeqFIF := Soma1( cSeqFIF )
									EndIf
									aCieAjus:= {}
								Endif
							Endif
							
							If SubStr(cCurrLine,1,1) <> '0' .and. SubStr(cCurrLine,1,1) <> '9'
								lContinua	:= Fa914VldImp(SubStr(cCurrLine,2,10), "CIELO", @cCodFil ) // Valida se filial poderá ser importada
								
								If !lContinua
									nQtdNProc++
									cCodEstab 	:= SubStr(cCurrLine,2,10)
									cNuComp 	:= PADR("", nTamNUCOMP - len(Alltrim(SubStr(cCurrLine,188,015))),'0') + Alltrim(SubStr(cCurrLine,188,015))
									cDescLeg 	:= STR0036
									F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg,"CIELO",,,,@aCodEst,.T.,cCodFil) // Grava detalhes do Log
								Else
									
									//Detalhe RO
									If SubStr(cCurrLine,1,1) == '1'
										
										nQtdLida++
										// Grava ajustes que não possuem detalhes de venda
										If Len(aCieAjus) > 0
											
											// Valida inclusao ou atualização da FIF
											lInclui	:= .T.
											lContinua := .T.
											dDtCredito := aCieAjus[aScan(aCieAjus, {|x| x[1] == "FIF_DTCRED"})][2]
											cNumCV := PADR(aCieAjus[aScan(aCieAjus, {|x| x[1] == "FIF_NUCOMP" })][2],nTamNUCOMP,'')
											
											FIF->(DbSetOrder(7)) //FIF_CODFIL+DTOS(FIF_DTCRED)+FIF_NUCOMP+FIF_PARCEL
											If FIF->(DbSeek(cCodFil + DtoS(dDtCredito) + cNumCV ))
												
												If Alltrim(FIF->FIF_TPREG) == '3' .And. Alltrim(FIF->FIF_CODADM) == cCodCielo //3-Ajustes
													lInclui	:= .F. // Nesse caso será necessário atualizar os dados
													
													cAjuLinArq  := aCieAjus[aScan(aCieAjus, {|x| x[1] == "CLINARQ"})][2]
													cAjuCodEst  := aCieAjus[aScan(aCieAjus, {|x| x[1] == "FIF_CODEST"})][2]
													cDescLeg    := STR0063 //"Registro alterado por motivo de ajuste" 
													F914GrvLog('2', cIdProc, cAjuLinArq, cNomArq, dDataIni, cHoraIni,cAjuCodEst,cNumCV,cDescLeg,"CIELO",,,,,.F.)
												EndIf
											EndIf
											
											If lContinua
												Iif(lInclui,nQtdReg++,nQtdAlt++) // só conta como registro bom se não tiver a venda e for incluido por aqui.
												RecLock( 'FIF', lInclui )
												For nZ := 2 to Len(aCieAjus)
													FIF->&( aCieAjus[nZ][1] ) := aCieAjus[nZ][2]
												Next nZ
												FIF->FIF_ARQVEN := aCielo[nX][01]
												If __lAPixTpd
													FIF->FIF_MODPAG	:= '1' // 1-TEF / 2-Carteiras Digitais
												Endif
												FIF->( MsUnlock() )
												cSeqFIF := Soma1( cSeqFIF )
											Endif
											aCieAjus:= {}
										EndIf
										// Detalhe do RO (com a primeira parcela) & Detalhe do RO (previsão da segunda parcela em diante)
										aAdd( aBanco, Right(Alltrim(SubStr(cCurrLine,100,004)),nTamBco) ) // Banco
										aAdd( aBanco, AllTrim( SubStr(cCurrLine,104,005) ) ) // Agência
										aAdd( aBanco, AllTrim( SubStr(cCurrLine,109,014) ) ) // Conta
										
										cCodRede	:= SubStr(cCurrLine,224,001)
										cNumCV 		:= PADR("", nTamNUCOMP - len(Alltrim(SubStr(cCurrLine,188,015))),'0') + Alltrim(SubStr(cCurrLine,188,015))
										cCodBan		:= SubStr(cCurrLine,185,003)
										nTxAdm		:= Round( Val( SubStr(cCurrLine,210,004) ) / 100, 2 )
										cCaptura	:= SubStr(cCurrLine,223,002)
										lDebito 	:= Alltrim(SubStr(cCurrLine,233,003)) $ cProdDeb
										cMotAjust	:= Alltrim(SubStr(cCurrLine,146,002))
										
										dDtCredito	:= CtoD(SubStr(cCurrLine,036,002)+"/"+SubStr(cCurrLine,034,002)+"/"+SubStr(cCurrLine,032,002))
										
										If !Empty(cMotAjust)
											cTipReg := '3' // 3-Ajustes
											
											// Armazena dados para caso o ajuste não tenha detalhe de venda
											nVlLiq	 := Round( Val( SubStr(cCurrLine,087,013) ) / 100, nTamVLLIQ )
											aCieAjus := {}
											aAdd(aCieAjus, {"CLINARQ"   , cLinLog} ) 
											aAdd(aCieAjus, {"FIF_FILIAL", xFilial("FIF")} )
											aAdd(aCieAjus, {"FIF_TPREG"	, cTipReg} )
											aAdd(aCieAjus, {"FIF_INTRAN", "0"} )
											aAdd(aCieAjus, {"FIF_CODEST", SubStr(cCurrLine,2,10)} )
											aAdd(aCieAjus, {"FIF_DTTEF" , dDtCredito} )
											aAdd(aCieAjus, {"FIF_NURESU", ""} )
											aAdd(aCieAjus, {"FIF_NUCOMP", cNumCV} )
											aAdd(aCieAjus, {"FIF_NSUTEF", ""} )
											aAdd(aCieAjus, {"FIF_NUCART", cNumCart} )
											aAdd(aCieAjus, {"FIF_VLBRUT", nVlLiq} )
											aAdd(aCieAjus, {"FIF_VLLIQ" , nVlLiq} )
											aAdd(aCieAjus, {"FIF_DTCRED", dDtCredito} )
											aAdd(aCieAjus, {"FIF_TPPROD", IIf( lDebito, 'D', 'C')} )
											aAdd(aCieAjus, {"FIF_CAPTUR", cCaptura} )
											aAdd(aCieAjus, {"FIF_CODRED", cCodRede} )
											aAdd(aCieAjus, {"FIF_CODBCO", aBanco[1]} )
											aAdd(aCieAjus, {"FIF_CODAGE", aBanco[2]} )
											aAdd(aCieAjus, {"FIF_NUMCC" , aBanco[3]} )
											aAdd(aCieAjus, {"FIF_SEQREG", PadL( Str( nQtdReg ), 6, '0' )} )
											aAdd(aCieAjus, {"FIF_DTIMP" , dDataBase} )
											aAdd(aCieAjus, {"FIF_MSIMP" , DtoS( dDataBase )} )
											aAdd(aCieAjus, {"FIF_CODFIL", cCodFil} )
											aAdd(aCieAjus, {"FIF_CODBAN", cCodBan} )
											aAdd(aCieAjus, {"FIF_SEQFIF", cSeqFIF} )
											aAdd(aCieAjus, {"FIF_STVEND", '1'} ) // 1-Não Conciliado para Vendas
											aAdd(aCieAjus, {"FIF_CODADM", cCodCielo} )
											aAdd(aCieAjus, {"FIF_CODMAJ", cMotAjust} )
											aAdd(aCieAjus, {"FIF_CODLOJ", SubStr(cCurrLine,2,10)} )
											aAdd(aCieAjus, {"FIF_NSUARQ", ""} )
											
										ElseIf SubStr(cCurrLine,021,001) == "A" //Tratamento para aceleração de parcelas
											cTipReg := '3'
											cMotAjust := "AP" // Motivo para Aceleração de Parcelas da CIELO
										Else
											cTipReg := '1'
										EndIf
										
										// Tratamento para venda parcelada -  Vendas Parceladas deverão replicar os comprovantes de vendas para as demais parcelas, pois essas informações só estão disponibilizadas para a primeira parcela no arquivo
										lParcela	:= .F.
										If SubStr(cCurrLine,021,001) == "/" // Venda Parcelada
											lParcela	:= .T.
											cParcAtu	:= SubStr(cCurrLine,019,002)
											If Len(aCieParc) > 0 .And. cParcAtu > "01"
												nRoVBrut 	:= Round( Val( SubStr(cCurrLine,047,013) ) / 100, nTamVLBRUT )
												nSomaVBrut	:= 0
												nDifVBrut	:= 0
												For nPc := 1 to Len(aCieParc)
													
													aAuxCie 	:= aClone(aCieParc[nPc])
													cParcTot	:= aAuxCie[aScan(aAuxCie, {|x| x[1] == "FIF_TOTPAR"})][2]
													
													If cParcAtu <= cParcTot
														
														// Valida inclusao ou atualização da FIF
														lInclui	:= .T.
														cNSUTEF	 := aAuxCie[aScan(aAuxCie, {|x| x[1] == "FIF_NSUTEF"})][2]
														cNSUARQ	 := aAuxCie[aScan(aAuxCie, {|x| x[1] == "FIF_NSUARQ"})][2]
														cParcela := IiF(Val(SubStr(cCurrLine,019,002)) > 0, SubStr(cCurrLine,019,002), '1')
														cParcela := Padl(Val(cParcela),nTamParc,'0')
														
														DbSelectArea("FIF")
														FIF->(DbSetOrder(6)) //FIF_CODFIL, FIF_DTCRED, FIF_NSUTEF, FIF_PARCEL
														If FIF->(DbSeek(cCodFil + DtoS(dDtCredito) + cNSUTEF + cParcela ))
															While ((cCodFil + DtoS(dDtCredito) + cNSUTEF + cParcela ) == (FIF->FIF_CODFIL + DtoS(FIF->FIF_DTCRED) + FIF->FIF_NSUTEF + FIF->FIF_PARCEL))
																If Alltrim(FIF->FIF_NUCOMP) == cNumCV
																	If FIF->FIF_STVEND == "6" .Or. cTipReg == "3" // Se  FIF foi incluída manualmente pela conciliacao vendas estará com status "FIF_STVEND" como "6"
																		lInclui	:= .F. // Nesse caso será necessário atualizar os dados
																		cDescLeg  := IIF(cTipReg == "3",STR0063,STR0064) //"Registro alterado por motivo de ajuste" //"Registro incluido manualmente foi atualizado"
																		F914GrvLog('2', cIdProc, cLinLog, cNomArq, dDataIni, cHoraIni,cEmpTef,cNumCV,cDescLeg,"CIELO",,,,,.F.)
																	Else
																		lContinua := .F. // do contrario não prossegue, pula o registro
																	EndIf
																	Exit
																Endif
																FIF->(Dbskip())
															EndDo
														EndIf
														
														If lContinua
															Iif(lInclui,nQtdReg++,nQtdAlt++)
															cParAlf 	:= TrataParc( cParcela, cTipoParc )
															nVlBrut		:= aAuxCie[aScan(aAuxCie, {|x| x[1] == "FIF_VLBRUT"})][2]
															
															// Tratamento para ajustar valores das demais parcelas, pois na primeira ocorre ajuste de arredondamento devido dízima periódica
															nSomaVBrut += nVlBrut
															If nSomaVBrut > nRoVBrut
																nDifVBrut := nRoVBrut - nSomaVBrut
																nVlBrut += nDifVBrut
															EndIf
															
															nVlLiq		:= nVlBrut - Round( ( nVlBrut * ( nTxAdm / 100 ) ), 2 )
															nVlCom		:= nVlBrut - nVlLiq
															cParAlf     := TrataParc( cParcela, cTipoParc )
															
															RecLock( 'FIF', lInclui )
															For nZ := 1 to Len(aAuxCie)
																FIF->&( aAuxCie[nZ][1] ) := aAuxCie[nZ][2]
															Next nZ
															FIF->FIF_DTCRED := dDtCredito
															FIF->FIF_PARCEL	:= cParcela
															FIF->FIF_PARALF	:= cParAlf
															FIF->FIF_VLBRUT := nVlBrut
															FIF->FIF_VLLIQ	:= nVlLiq
															FIF->FIF_TXSERV	:= nTxAdm
															FIF->FIF_VLCOM	:= nVlCom
															FIF->FIF_SEQFIF	:= cSeqFIF
															FIF->FIF_ARQVEN := aCielo[nX][01]
															If __lAPixTpd
																FIF->FIF_MODPAG	:= '1' // 1-TEF / 2-Carteiras Digitais
															Endif	

															FIF->( MsUnlock() )
															
															cSeqFIF := Soma1( cSeqFIF )
														EndIf
														
													EndIf
													
												Next nPc
												
												cParcUlt := SubStr(cCurrLine,022,002)
												If cParcAtu == cParcUlt
													aCieParc := {}
												EndIf
											EndIf
										EndIf
										//Detalhe CV
									ElseIf SubStr(cCurrLine,1,1) == '2'
										// Detalhe do comprovante de venda
										cEmpTef	:= SubStr(cCurrLine,002,010)
										cNSUTEF := PADR("", nTamNsu - len(Alltrim(SubStr(cCurrLine,093,006))),'0') + Alltrim(SubStr(cCurrLine,093,006))
										
										If lContinua
											
											// Valida inclusao ou atualização da FIF
											cNSUARQ  := SubStr(cCurrLine,093,006)
											cNumRV	 := SubStr(cCurrLine,012,007)
											cParcela := IiF(Val(SubStr(cCurrLine,060,002)) > 0, SubStr(cCurrLine,060,002), '1')
											cParcela := Padl(Val(cParcela),nTamParc,'0')
											cParAlf  := TrataParc( cParcela, cTipoParc )
											
											lInclui	:= .T.
											DbSelectArea("FIF")
											FIF->(DbSetOrder(6)) //FIF_CODFIL, FIF_DTCRED, FIF_NSUTEF, FIF_PARCEL
											If FIF->(Dbseek(cCodFil + DtoS(dDtCredito) + cNSUTEF + cParcela ))
												While ((cCodFil + DtoS(dDtCredito) + cNSUTEF + cParcela ) == (FIF->FIF_CODFIL + DtoS(FIF->FIF_DTCRED) + FIF->FIF_NSUTEF + FIF->FIF_PARCEL))
													If Alltrim(FIF->FIF_NUCOMP) == cNumCV
														If FIF->FIF_STVEND == "6" .Or. cTipReg == "3" // Se  FIF foi incluída manualmente pela conciliacao vendas estará com status "FIF_STVEND" como "6"
															lInclui	:= .F. // Nesse caso será necessário atualizar os dados
															cDescLeg  := IIF(cTipReg == "3",STR0063,STR0064) //"Registro alterado por motivo de ajuste" //"Registro incluido manualmente foi atualizado"
															F914GrvLog('2', cIdProc, cLinLog, cNomArq, dDataIni, cHoraIni,cEmpTef,cNumCV,cDescLeg,"CIELO",,,,,.F.)
														Else
															lContinua := .F. // do contrario não prossegue, pula o registro
														EndIf
														Exit
													EndIf
													FIF->(Dbskip())
												EndDo
											EndIf
											
											// Validação para verificar caracter especial na composição dos campos FIF_NSUTEF e FIF_NUCOMP
											lCarEsp := FINCARCESP(cNSUTEF,cNumCV,@lNsuTef,@lNuComp)
											
											If lContinua .and. !lCarEsp
												Iif(lInclui,nQtdReg++,nQtdAlt++)
												nQtdLida++
												cNumCart	:= SubStr(cCurrLine,019,019)
												cCodAut		:= SubStr(cCurrLine,067,006)
												dDataTef	:= StoD( SubStr(cCurrLine,038,008) )
												nVlBrut		:= Round( Val( SubStr(cCurrLine,047,013) ) / 100, 2 )
												nVlLiq		:= nVlBrut - Round( ( nVlBrut * ( nTxAdm / 100 ) ), 2 )
												nVlCom		:= nVlBrut - nVlLiq
												
												RecLock( 'FIF', lInclui )
												FIF->FIF_FILIAL	:= xFilial("FIF")
												FIF->FIF_TPREG	:= cTipReg
												FIF->FIF_INTRAN := '0'
												FIF->FIF_CODEST := cEmpTef
												FIF->FIF_DTTEF	:= dDataTef
												FIF->FIF_NURESU	:= cNumRV
												FIF->FIF_NUCOMP := cNumCV
												FIF->FIF_NSUTEF := cNSUTEF
												FIF->FIF_NUCART := cNumCart
												FIF->FIF_VLBRUT := nVlBrut
												FIF->FIF_TOTPAR := SubStr(cCurrLine,062,002)
												FIF->FIF_VLLIQ	:= nVlLiq
												FIF->FIF_DTCRED := dDtCredito
												FIF->FIF_PARCEL := cParcela
												FIF->FIF_TPPROD := IIf( lDebito, 'D', 'C')
												FIF->FIF_CAPTUR := cCaptura
												FIF->FIF_CODRED := cCodRede
												FIF->FIF_CODBCO := aBanco[1]
												FIF->FIF_CODAGE := aBanco[2]
												FIF->FIF_NUMCC	:= aBanco[3]
												FIF->FIF_CODAUT := cCodAut
												FIF->FIF_SEQREG := PadL( Str( nQtdReg ), 6, '0' )
												FIF->FIF_DTIMP	:= dDataBase
												FIF->FIF_MSIMP	:= DtoS( dDataBase )
												FIF->FIF_CODFIL := cCodFil
												FIF->FIF_CODBAN := cCodBan
												FIF->FIF_SEQFIF	:= cSeqFIF
												FIF->FIF_PARALF	:= cParAlf
												FIF->FIF_STVEND	:= '1' // 1-Não Conciliado para Vendas
												FIF->FIF_CODADM	:= cCodCielo
												FIF->FIF_CODLOJ := cEmpTef
												FIF->FIF_TXSERV	:= nTxAdm
												FIF->FIF_VLCOM	:= nVlCom
												If cTipReg == "3" // 3-Ajustes
													FIF->FIF_CODMAJ := cMotAjust
													aCieAjus := {}
												EndIf
												
												FIF->FIF_ARQVEN := aCielo[nX][01]
												FIF->FIF_NSUARQ := cNSUARQ
												If __lAPixTpd
													FIF->FIF_MODPAG	:= '1' // 1-TEF / 2-Carteiras Digitais
												Endif	
												FIF->( MsUnlock() )
												
												cSeqFIF := Soma1( cSeqFIF )
												
												If lParcela // Tratamento para venda parcelada -  Vendas Parceladas deverá replicar o comprovante de vendas para as demais parcelas, pois essas informações só vem para a primeira no arquivo
													aAuxCie := {}
													aAdd(aAuxCie, {"FIF_FILIAL", xFilial("FIF")} )
													aAdd(aAuxCie, {"FIF_TPREG"	, cTipReg} )
													aAdd(aAuxCie, {"FIF_INTRAN", "0"} )
													aAdd(aAuxCie, {"FIF_CODEST", cEmpTef} )
													aAdd(aAuxCie, {"FIF_DTTEF" , dDataTef} )
													aAdd(aAuxCie, {"FIF_NURESU", cNumRV} )
													aAdd(aAuxCie, {"FIF_NUCOMP", cNumCV} )
													aAdd(aAuxCie, {"FIF_NSUTEF", cNSUTEF} )
													aAdd(aAuxCie, {"FIF_NUCART", cNumCart} )
													aAdd(aAuxCie, {"FIF_VLBRUT", nVlBrut} )
													aAdd(aAuxCie, {"FIF_TOTPAR", SubStr(cCurrLine,062,002)} )
													aAdd(aAuxCie, {"FIF_VLLIQ" , nVlLiq} )
													aAdd(aAuxCie, {"FIF_TPPROD", IIf( lDebito, 'D', 'C')} )
													aAdd(aAuxCie, {"FIF_CAPTUR", cCaptura} )
													aAdd(aAuxCie, {"FIF_CODRED", cCodRede} )
													aAdd(aAuxCie, {"FIF_CODBCO", aBanco[1]} )
													aAdd(aAuxCie, {"FIF_CODAGE", aBanco[2]} )
													aAdd(aAuxCie, {"FIF_NUMCC" , aBanco[3]} )
													aAdd(aAuxCie, {"FIF_CODAUT" , cCodAut} )
													aAdd(aAuxCie, {"FIF_SEQREG", PadL( Str( nQtdReg ), 6, '0' )} )
													aAdd(aAuxCie, {"FIF_DTIMP" , dDataBase} )
													aAdd(aAuxCie, {"FIF_MSIMP" , DtoS( dDataBase )} )
													aAdd(aAuxCie, {"FIF_CODFIL", cCodFil} )
													aAdd(aAuxCie, {"FIF_CODBAN", cCodBan} )
													aAdd(aAuxCie, {"FIF_STVEND", '1'} ) // 1-Não Conciliado para Vendas
													aAdd(aAuxCie, {"FIF_CODADM", cCodCielo} )
													aAdd(aAuxCie, {"FIF_CODLOJ", cEmpTef} )
													aAdd(aAuxCie, {"FIF_TXSERV", nTxAdm} )
													aAdd(aAuxCie, {"FIF_VLCOM", nVlCom} )
													If cTipReg == "3" // 3-Ajustes
														aAdd(aAuxCie, {"FIF_CODMAJ", cMotAjust} )
													EndIf
													aAdd(aAuxCie, {"FIF_NSUARQ", cNSUARQ} )
													
													aAdd(aCieParc, aClone(aAuxCie) )
													
												EndIf
												
											Else
												nQtdNProc++
												nQdtImp++
												cCodEstab 	:= cEmpTef
												cNuComp 	:= cNumCV
												If !lCarEsp
													cDescLeg 	:= STR0047 + ' '+  cNSUTEF
												else
													cDescLeg := STR0066
													lCarEsp  := .F.
												Endif		
												
												F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,Iif(lNsutef,cNSUTEF,cNuComp),cDescLeg,STR0011) // Grava detalhes do Log
												
												lNsuTef  := .F.
												lNuComp  := .F.	
											EndIf
										Else
											nQtdNProc++
											cCodEstab 	:= cEmpTef
											cNuComp 	:= cNumCV
											cDescLeg 	:= STR0047 + ' '+  cNSUTEF
											
											F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cCodest,cDescLeg) // Grava detalhes do Log
										EndIf
										
									EndIf
								Endif
							EndIf
						EndIf
						
						FT_FSKIP()
						cCurrLine := FT_FREADLN()
						
					EndDo
					END TRANSACTION
					
				ElseIf Alltrim(SubStr(cCurrLine,048,002)) == "06" .OR. Alltrim(SubStr(cCurrLine,048,002)) == "10"// Antecipação de Recebíveis (versão 013) ou Antecipação de Recebíveis Alelo (versão 014)
					
					BEGIN TRANSACTION
					
					lFilEmp   := .F.
					nLinTotal := 0
					nQtdLida  := 0
					
					While !FT_FEOF()
						
						nLinha++
						lLinOk	:= !Empty(cCurrLine)
						cLinLog := StrZero( nLinha, nTamLinha )
						
						If !Empty(cCurrLine)
							
							//Header
							If SubStr(cCurrLine,1,1) == '0'
								nQtdLida++
								// Identifica o tipo de arquivo e o nome comercial do estabelecimento
								If SubStr(cCurrLine,071,003) != '001' .and. (SubStr(cCurrLine,071,003) != '013' .and. SubStr(cCurrLine,071,003) != '014')  //Verifico se as versoes dos arquivos sao homologadas.
									lErro := .T.
									cStatus	:= "2" // 2=Versão do arquivo incompatível
									cDescLeg :=	STR0028+" "+Alltrim(SubStr(cCurrLine,071,003))+"."
									//HELP(" ",1,"VERSAO",,STR0031 + SubStr(cCurrLine,071,003) + STR0032 + aCielo[nX][01] + STR0033 ,2,0,,,,,, {STR0034}) //"A versão ", " do arquivo ", " não está homologada no Protheus."
									Exit
								EndIf
							EndIf
							
							If SubStr(cCurrLine,1,1) == '9'
								nQtdLida++
							EndIf
							
							If SubStr(cCurrLine,1,1) <> '0' .and. SubStr(cCurrLine,1,1) <> '9'
								lContinua	:= Fa914VldImp(SubStr(cCurrLine,2,10), "CIELO", @cCodFil ) // Valida se filial poderá ser importada
								
								If !lContinua
									nQtdNProc++
									cCodEstab 	:= SubStr(cCurrLine,2,10)
									cNuComp 	:= PADR("", nTamNUCOMP - len(Alltrim(SubStr(cCurrLine,188,015))),'0') + Alltrim(SubStr(cCurrLine,188,015))
									cDescLeg 	:= STR0036
									F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg,"CIELO",,,,@aCodEst,.T.,cCodFil) // Grava detalhes do Log
								Else
									//Detalhe ARV
									If SubStr(cCurrLine,1,1) == '5'
										// Guarda data de pagamento da operação de Antecipação
										nQtdLida++
										dDtPagtoOp	:= StoD(SubStr(cCurrLine,021,008))
										nTxAdm		:= Val( SubStr(cCurrLine,141,005) ) / 1000 // Valor consirera 3 casas decimais
										
										//Detalhe RO
									ElseIf SubStr(cCurrLine,1,1) == '6'
										nQtdLida++
										dDtCredito	:= StoD(SubStr(cCurrLine,021,008))
										cCodBan		:= SubStr(cCurrLine,096,003)
										cTipReg 	:= '20' //20-Transações Antecipadas
										
										//Detalhe dos débitos de ROs Antecipados
									ElseIf SubStr(cCurrLine,1,1) == '7'
										nQtdLida++
										dDtCredito	:= StoD(SubStr(cCurrLine,041,008))
										cTipReg 	:= '3' //3-Ajuste
										
										//Detalhe CV
									ElseIf SubStr(cCurrLine,1,1) == '2'
										// Detalhe do comprovante de venda
										cEmpTef	:= SubStr(cCurrLine,002,010)
										cNSUTEF := PADR("", nTamNsu - len(Alltrim(SubStr(cCurrLine,093,006))),"0") + Alltrim(SubStr(cCurrLine,093,006))
										
										If lContinua
											
											// Valida inclusao ou atualização da FIF
											lInclui	 := .T.
											cNSUARQ  := SubStr(cCurrLine,093,006)
											cParcela := IiF(Val(SubStr(cCurrLine,060,002)) > 0, SubStr(cCurrLine,060,002), '1')
											cParcela := Padl(Val(cParcela),nTamParc,'0')
											cParAlf  := TrataParc( cParcela, cTipoParc )
											
											DbSelectArea("FIF")
											FIF->(DbSetOrder(6)) //FIF_CODFIL, FIF_DTCRED, FIF_NSUTEF, FIF_PARCEL
											If FIF->(DbSeek(cCodFil + DtoS(dDtCredito) + cNSUTEF + cParcela))
												While ((cCodFil + DtoS(dDtCredito) + cNSUTEF + cParcela ) == (FIF->FIF_CODFIL + DtoS(FIF->FIF_DTCRED) + FIF->FIF_NSUTEF + FIF->FIF_PARCEL))
													If Alltrim(FIF->FIF_NUCOMP) == cNumCV
														If Empty(FIF->FIF_STATUS) .Or. FIF->FIF_STATUS $ "1/6"
															lInclui	:= .F. // Nesse caso será necessário atualizar os dados
															cDescLeg  := STR0064 //"Registro incluido manualmente foi atualizado"
															F914GrvLog('2', cIdProc, cLinLog, cNomArq, dDataIni, cHoraIni,cEmpTef,cNumCV,cDescLeg,"CIELO",,,,,.F.)
														Else
															lContinua := .F. // se não achou não prossegue, pula o registro
														EndIf
														Exit
													Endif
													FIF->(Dbskip())
												EndDo
											Else
												lContinua := .F. // se não achou não prossegue, pula o registro
											EndIf
											
											// Validação para verificar caracter especial na composição dos campos FIF_NSUTEF e FIF_NUCOMP
											lCarEsp := FINCARCESP(cNSUTEF,cNumCV,@lNsuTef,@lNuComp)
											
											If lContinua .and. !lCarEsp
												Iif(lInclui,nQtdReg++,nQtdAlt++)
												nQtdLida++
												cNumRV		:= SubStr(cCurrLine,012,007)
												cNumCart	:= SubStr(cCurrLine,019,019)
												cCodAut		:= SubStr(cCurrLine,067,006)
												dDataTef	:= StoD( SubStr(cCurrLine,038,008) )
												nVlBrut		:= Round( Val( SubStr(cCurrLine,047,013) ) / 100, 2 )
												nVlLiq		:= nVlBrut - Round( ( nVlBrut * ( nTxAdm / 100 ) ), 2 )
												nVlCom		:= nVlBrut - nVlLiq
												
												RecLock( 'FIF', lInclui )
												FIF->FIF_FILIAL	:= xFilial("FIF")
												FIF->FIF_TPREG	:= cTipReg
												FIF->FIF_INTRAN := '0'
												FIF->FIF_CODEST := cEmpTef
												FIF->FIF_DTTEF	:= dDataTef
												FIF->FIF_NURESU	:= cNumRV
												FIF->FIF_NUCOMP := cNumCV
												FIF->FIF_NSUTEF := cNSUTEF
												FIF->FIF_NUCART := cNumCart
												FIF->FIF_VLBRUT := nVlBrut
												FIF->FIF_TOTPAR := SubStr(cCurrLine,062,002)
												FIF->FIF_VLLIQ	:= nVlLiq
												FIF->FIF_DTCRED := dDtPagtoOp
												FIF->FIF_PARCEL := cParcela
												FIF->FIF_CAPTUR := cCaptura
												FIF->FIF_CODAUT := cCodAut
												If lInclui
													FIF->FIF_SEQREG := PadL( Str( nQtdReg ), 6, '0' )
												EndIf
												FIF->FIF_DTIMP	:= dDataBase
												FIF->FIF_MSIMP	:= DtoS( dDataBase )
												FIF->FIF_CODFIL := cCodFil
												FIF->FIF_CODBAN := cCodBan
												FIF->FIF_SEQFIF	:= cSeqFIF
												FIF->FIF_PARALF	:= cParAlf
												FIF->FIF_STATUS := Iif(cTipReg == '20' ,'6','1' ) // 1-Não Conciliado para Pagamento
												FIF->FIF_CODADM	:= cCodCielo
												FIF->FIF_CODLOJ := cEmpTef
												FIF->FIF_TXSERV	:= nTxAdm
												FIF->FIF_VLCOM	:= nVlCom
												FIF->FIF_ARQVEN := aCielo[nX][01]
												FIF->FIF_NSUARQ := cNSUARQ
												If __lAPixTpd
													FIF->FIF_MODPAG	:= '1' // 1-TEF / 2-Carteiras Digitais
												Endif	
												FIF->( MsUnlock() )
												
												cSeqFIF := Soma1( cSeqFIF )
											Else
												nQtdNProc++
												cCodEstab 	:= cEmpTef
												cNuComp 	:= cNumCV
												cDescLeg 	:= STR0047 + ' '+  cNSUTEF
												
												F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cCodest,cDescLeg) // Grava detalhes do Log
											EndIf
										Else
											nQtdNProc++
											cCodEstab 	:= cEmpTef
											cNuComp 	:= cNumCV

											If !lCarEsp
												cDescLeg 	:= STR0047 + ' '+  cNSUTEF
											else
												cDescLeg := STR0066
												lCarEsp  := .F.
											Endif		
											
											F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,Iif(lNsutef,cNSUTEF,cNuComp),cDescLeg,STR0011) // Grava detalhes do Log
											
											lNsuTef  := .F.
											lNuComp  := .F.	
										EndIf
									EndIf
								Endif
							EndIf
						EndIf
						
						FT_FSKIP()
						cCurrLine := FT_FREADLN()
						
					EndDo
					
					END TRANSACTION
					
				Else
					nLinha++
					lLinOk	:= !Empty(cCurrLine)
					cLinLog := StrZero( nLinha, nTamLinha )
					
					nRegNProc := AScan(aRegNProc, { |x| Upper(x[1]) == "CIELO" .AND. x[2] == SubStr(cCurrLine,048,002) })
					
					If nRegNProc == 0
						cDescLeg := STR0052 +SubStr(cCurrLine,1,1)+ STR0053 // "Registro "  //" não é processado pelo conciliador."
						cCodEstab := ""
						cNuComp := ""
					Else
						cDescLeg :=  STR0052 +SubStr(cCurrLine,048,002)+" - "+Alltrim(aRegNProc[nRegNProc][5])+ STR0053 // "Registro "  //" não é processado pelo conciliador."
						cCodEstab := iIf(aRegNProc[nRegNProc][3] > 0,SubStr(cCurrLine,aRegNProc[nRegNProc][3],aRegNProc[nRegNProc][4]),"")
						cNuComp := ""
					EndIf
					
					F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg)
					
					nQtdNProc++
				EndIf
				
				If cStatus <> "2"
					A914Status(@lErro, @cStatus, @cDescLeg, nQtdReg, nQtdNProc, nLinha, nQtdLida, nQdtImp, 0,nQtdAlt)
				EndIf
			Else
				//Erro na abertura do arquivo
				lErro := .T.
				cStatus	:= "3" // 3="Falha na abertura do arquivo"
				cDescLeg := STR0029
			EndIf
			
			FT_FUSE()
		EndIf
		
		nLinTotal := nQtdNProc + nQtdLida
		// Gravação do Log Pai
		F914GrvLog('1',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg,'CIELO',nQtdReg,nQtdNProc,cStatus,,,,cCodCielo,cCodUser,nQtdLida,nLinTotal,nQtdAlt)
		
		// Guarda Log temporário
		F914LogFVR( FVR->(Recno()),nQtdAlt)
		
		//Copio o arquivo para o folder correspondente
		If lErro
			_CopyFile( aFolderB[01][02] + '\' + aCielo[nX][01], aFolderB[01][04] + '\' + aCielo[nX][01] )
		Else
			_CopyFile( aFolderB[01][02] + '\' + aCielo[nX][01], aFolderB[01][03] + '\' + aCielo[nX][01] )
		EndIf
		
		FERASE( aFolderB[01][02] + '\' + aCielo[nX][01] )
		
		nQtdReg := 0
		
	Next nX
EndIf

//------------------------------------------------
// Processamento dos arquivos REDE
//------------------------------------------------
If !Empty( aRede ) .And. aExistFld[3]
	If !lAutomato
		oProcess:IncRegua1( STR0020 ) //"Processando arquivos do layout Rede"
		
		oProcess:SetRegua2( Len( aRede ) )
	EndIf
	
	For nX := 1 To Len( aRede )
		//Seto a variável como falso novamente (caso já tenha sido executada)
		lErro 		:= .F.
		aBanco 		:= {}
		lContinua	:= .T.
		cCodFil		:= ""
		nQtdReg		:= 0
		nQtdAlt		:= 0 
		nQdtImp 	:= 0
		nQtdNProc	:= 0
		nLinha		:= 0
		lLinOk		:= .T.
		dDataIni 	:= dDataBase
		cTime		:= Time()
		cHoraIni 	:= SubStr( cTime, 01, 08 )
		cStatus		:= ""
		cNSUARQ     := ""
		cNomArq 	:= ""
		cCodEstab 	:= ""
		cNuComp 	:= ""
		cIdProc 	:= ""
		aArqLog 	:= {}
		cCodEstab 	:= ""
		cNuComp 	:= ""
		aArqLog 	:= {}
		aCodEst 	:= {}
		cLinLog 	:= ""
		cDescLeg 	:= ""
		nQtdSerasa  := 0
		lFilEmp 	:= .F.
		nLinTotal 	:= 0
		nQtdLida 	:= 0
		a012Parc	:= {}
		lBackReg    := .F. 
		lCarEsp 	:= .F.
		lNsutef     := .F.
		lNuComp		:= .F.

		If !lAutomato
			oProcess:IncRegua2( STR0018 + aRede[nX][01] ) //"Processando arquivo: "
		EndIf
		
		DbSelectArea("FVR")
		DbSetOrder(2) //FVR_NOMARQ+DTOS(FVR_DTPROC)+FVR_HRPROC
		
		cIdProc  := GetSxeNum("FVR","FVR_IDPROC")
		cCodRede := aFolderC[01][05]
		cNomArq  := aRede[nX][01]
		
		If FVR->(DbSeek(SubStr(aRede[nX][01],1,__nTmNomAr)))
			lErro    := .T.
			cStatus	 := "1" // 1=Arquivo já importado
			cDescLeg := STR0027
		Else
			
			nHandle := FT_FUSE( aFolderC[01][02] + '\' + aRede[nX][01] )
			
			If nHandle != -1
				FT_FGOTOP()
				
				cCurrLine := FT_FREADLN()
				
				lCredito := SubStr(cCurrLine,118,4) == 'EEVC'
				
				If lCredito //Processo arquivo com vendas de cartão de crédito
					
					BEGIN TRANSACTION
					
					While !FT_FEOF()
						
						nLinha++
						lLinOk	:= !Empty(cCurrLine)
						cLinLog := StrZero( nLinha, nTamLinha )
						
						If lLinOk
							
							//Header
							If SubStr(cCurrLine,1,3) == '002'
								nQtdLida++
								// Identifica o tipo de arquivo e o nome comercial do estabelecimento
								If SubStr(cCurrLine,102,05) != 'V2.01' //Caso a versão do arquivo seja diferente da versão 2.01, não processo
									cStatus	 := "2" // 2=Versão do arquivo incompatível
									cDescLeg := STR0028+" "+Alltrim(SubStr(cCurrLine,102,05))+"."
									lErro 	 := .T.
									lLinOk   := .F.
									Exit
								EndIf
								//Resumo de vendas - Rotativo
							EndIf
							If (SubStr(cCurrLine,1,3) $ "004/026/028")
								nQtdLida++
							EndIf
							
							If SubStr(cCurrLine,1,3) <> '002' .and. !(SubStr(cCurrLine,1,3) $ "004/026/028")
								lContinua	:= Fa914VldImp(SubStr(cCurrLine,004,009), "REDE", @cCodFil ) // Valida se filial poderá ser importada
								
								If !lContinua
									nQtdNProc++
									cCodEstab 	:= SubStr(cCurrLine,004,009)
									cNuComp 	:= SubStr(cCurrLine,013,009)
									cDescLeg    := STR0036
									
									F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg,"REDE",,,,@aCodEst,.T.,cCodFil) // Grava detalhes do Log
								Else
									
									If SubStr(cCurrLine,1,3) == '006'
										// Identifica o resumo de vendas que agrupa CV/NSUs de transações de crédito rotativo
										nQtdLida++
										cEmpTef		:= SubStr(cCurrLine,004,009)
										cRegVenda	:= SubStr(cCurrLine,013,009)
										cCodBan		:= SubStr(cCurrLine,137,001)
										
										aAdd( aBanco, SubStr(cCurrLine,022,003) ) // Banco
										aAdd( aBanco, SubStr(cCurrLine,025,005) ) // Agência
										aAdd( aBanco, SubStr(cCurrLine,030,011) ) // Conta
										
										dDtCredito := CtoD( SubStr(cCurrLine,129,002) + '/' + SubStr(cCurrLine,131,002) + '/' + SubStr(cCurrLine,133,004) )
										
										
										//Comprovante de venda (CV/NSU) rotativo
									ElseIf SubStr(cCurrLine,1,3) == '008'
										// Identifica a transação de crédito rotativo
										cNumCV		:= PADR("", nTamNsu - len(Alltrim(SubStr(cCurrLine,87,12))),"0") + Alltrim(SubStr(cCurrLine,87,12))
										cNSUARQ 	:= SubStr(cCurrLine,87,12)
										cCodEstab 	:= SubStr(cCurrLine,004,009)
										cNuComp 	:= SubStr(cCurrLine,013,009)
										
										If lContinua
											
											cParcela    := PadL( '1', nTamParc, '0' )
											cParAlf     := TrataParc( cParcela, cTipoParc )
											
											// Valida inclusao ou atualização da FIF
											lInclui	:= .T.
											DbSelectArea("FIF")
											FIF->(DbSetOrder(6)) //FIF_CODFIL, FIF_DTCRED, FIF_NSUTEF, FIF_PARCEL
											If FIF->(DbSeek(cCodFil + DtoS(dDtCredito) + PADR(cNumCV, nTamNSUTEF,'') + cParcela))
												
												If FIF->FIF_STVEND == "6" // Se  FIF foi incluída manualmente estará com status "FIF_STVEND" como "6"
													lInclui	:= .F. // Nesse caso será necessário atualizar os dados
													cDescLeg  := STR0064 //"Registro incluido manualmente foi atualizado"
													F914GrvLog('2', cIdProc, cLinLog, cNomArq, dDataIni, cHoraIni,cEmpTef,cNumCV,cDescLeg,"REDE",,,,,.F.)
												Else
													lContinua := .F. // do contrario não prossegue, pula o registro
												EndIf
											EndIf
											
											// Validação para verificar caracter especial na composição dos campos FIF_NSUTEF e FIF_NUCOMP
											lCarEsp := FINCARCESP(cNumCV,cNumCV)
											
											If lContinua .and. !lCarEsp
												
												Iif(lInclui,nQtdReg++,nQtdAlt++)
												nQtdLida++
												cNumRV		:= SubStr(cCurrLine,13,09)
												cNumCart	:= SubStr(cCurrLine,68,16)
												dDataTef	:= CtoD( SubStr(cCurrLine,22,02) + '/' + SubStr(cCurrLine,24,02) + '/' + SubStr(cCurrLine,26,04) )
												cCodAut		:= SubStr(cCurrLine,127,06)
												
												RecLock( 'FIF', lInclui )
												FIF->FIF_FILIAL	:= xfilial("FIF")
												FIF->FIF_TPREG	:= '1'
												FIF->FIF_INTRAN := '0'
												FIF->FIF_CODEST := cEmpTef
												FIF->FIF_DTTEF	:= dDataTef
												FIF->FIF_NURESU	:= cNumRV
												FIF->FIF_NUCOMP := PADR("", nTamNUCOMP - len(Alltrim(cNumCV)),"0") + Alltrim(cNumCV)
												FIF->FIF_NSUTEF := cNumCV
												FIF->FIF_NUCART := cNumCart
												FIF->FIF_VLBRUT := Round( Val( SubStr(cCurrLine,38,15) ) / 100, 2 )
												FIF->FIF_TOTPAR := '00'
												FIF->FIF_VLLIQ	:= Round( Val( SubStr(cCurrLine,204,15) ) / 100, 2 )
												FIF->FIF_DTCRED := dDtCredito
												FIF->FIF_PARCEL := cParcela
												FIF->FIF_TPPROD := 'C'
												FIF->FIF_CAPTUR := SubStr(cCurrLine,203,01)
												FIF->FIF_CODRED := SubStr(cCurrLine,230,01)
												FIF->FIF_CODBCO := aBanco[1]
												FIF->FIF_CODAGE := aBanco[2]
												FIF->FIF_NUMCC	:= aBanco[3]
												FIF->FIF_VLCOM	:= Round( Val( SubStr(cCurrLine,112,15) ) / 100, 2 )
												FIF->FIF_TXSERV	:= Round(( FIF->FIF_VLCOM / FIF->FIF_VLBRUT )  * 100, nTamTXSERV)
												FIF->FIF_CODAUT := cCodAut
												FIF->FIF_SEQREG := PadL( Str( nQtdReg ), 6, '0' )
												FIF->FIF_DTIMP	:= dDataBase
												FIF->FIF_MSIMP	:= DtoS( dDataBase )
												FIF->FIF_CODFIL := cCodFil
												FIF->FIF_CODBAN := cCodBan
												FIF->FIF_SEQFIF	:= cSeqFIF
												FIF->FIF_PARALF	:= cParAlf
												FIF->FIF_STVEND	:= '1' // REDE - Registros dos arquivos EEVC ou EEVD serão considerados para conciliação de vendas. Registros EEFI serão considerados para pagto.
												FIF->FIF_CODADM	:= cCodRede
												FIF->FIF_CODLOJ := cEmpTef
												FIF->FIF_ARQVEN := aRede[nX][01]
												FIF->FIF_NSUARQ := cNSUARQ
												If __lAPixTpd
													FIF->FIF_MODPAG	:= '1' // 1-TEF / 2-Carteiras Digitais
												Endif	
												FIF->( MsUnlock() )
												
												cSeqFIF := Soma1( cSeqFIF )
											Else
												nQtdNProc++
												nQdtImp++
												cNuComp  := cNumCV

												If !lCarEsp
													cDescLeg := STR0052 +"008"+ STR0054 // "Registro "  //" Já importado anteriormente."
												else
													cDescLeg := STR0066
													lCarEsp  := .F.
												Endif		
									
												F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNumCV,cDescLeg,STR0012 ) // Grava detalhes do Log
											EndIf
										Else
											nQtdNProc++
											cNuComp  	:= cNumCV
											cDescLeg 	:= STR0047 + ' '+  cNSUARQ
											F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg)
										EndIf
										
										//Resumo de vendas - Parcelado sem juros
									ElseIf SubStr(cCurrLine,1,3) == '010'
										// Identifica o resumo de vendas que agrupa CV/NSUs de transações de crédito parcelado sem juros
										nQtdLida++
										cEmpTef		:= SubStr(cCurrLine,004,009)
										cRegVenda	:= SubStr(cCurrLine,013,009)
										cCodBan		:= SubStr(cCurrLine,137,001)
										
										aAdd( aBanco, SubStr(cCurrLine,22,03) ) // Banco
										aAdd( aBanco, SubStr(cCurrLine,25,05) ) // Agência
										aAdd( aBanco, SubStr(cCurrLine,30,11) ) // Conta
										
										a012Parc := {} // Inicia um novo processo de avaliação dos registros 012
										lBackReg := .F. 
										
									ElseIf SubStr(cCurrLine,1,3) == '011'
										// Identifica o resumo de vendas que agrupa CV/NSUs de transações de crédito parcelado sem juros
										cEmpTef		:= SubStr(cCurrLine,004,009)
										dDataTef	:= CtoD( SubStr(cCurrLine,22,02) + '/' + SubStr(cCurrLine,24,02) + '/' + SubStr(cCurrLine,26,04) )
										cCodBan		:= SubStr(cCurrLine,119,001)
										cFIFAlias	:= GetNextAlias()
										
										aAdd( aBanco, SubStr(cCurrLine,069,003) ) // Banco
										aAdd( aBanco, SubStr(cCurrLine,072,006) ) // Agência
										aAdd( aBanco, SubStr(cCurrLine,078,011) ) // Conta
										
										cQuery := " SELECT COUNT(1) CONTADOR " + CRLF
										cQuery += " FROM "+RetSqlName("FIF") + CRLF
										cQuery += " WHERE FIF_FILIAL = '" + xFilial("FIF") + "' " + CRLF
										cQuery += "   AND FIF_DTTEF  = '" + DtoS(dDataTef) + "' " + CRLF
										cQuery += "   AND FIF_TPREG  = '3' " + CRLF
										cQuery += "   AND FIF_CODEST = '" + cEmpTef + "' " + CRLF
										cQuery += "   AND FIF_CODFIL = '" + cCodFil + "' " + CRLF
										cQuery += "   AND FIF_CODADM = '" + cCodRede + "' " + CRLF
										cQuery += "   AND FIF_CODBCO = '" + SubStr(cCurrLine,69,03) + "' " + CRLF
										cQuery += "   AND FIF_CODAGE = '" + SubStr(cCurrLine,72,06) + "' " + CRLF
										cQuery += "   AND FIF_NUMCC  = '" + SubStr(cCurrLine,78,11)+ "' " + CRLF
										cQuery += "   AND D_E_L_E_T_ = ' ' " + CRLF
										cQuery := ChangeQuery(cQuery)
										
										dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),cFIFAlias,.F.,.T.)
										
										If !(cFIFAlias)->(Eof()) .And. (cFIFAlias)->CONTADOR == 0
											
											nQtdReg++
											nQtdLida++
											RecLock( 'FIF', .T. )
											FIF->FIF_FILIAL	:= xFilial("FIF")
											FIF->FIF_TPREG	:= '3'
											FIF->FIF_INTRAN := '0'
											FIF->FIF_CODEST := cEmpTef
											FIF->FIF_DTTEF	:= dDataTef
											FIF->FIF_NURESU	:= ""
											FIF->FIF_NUCOMP := ""
											FIF->FIF_NSUTEF := ""
											FIF->FIF_NUCART := ""
											FIF->FIF_VLBRUT := Round( Val( SubStr(cCurrLine,053,015) ) / 100, 2 )
											FIF->FIF_TOTPAR := ""
											FIF->FIF_VLLIQ	:= Round( Val( SubStr(cCurrLine,030,015) ) / 100, 2 )
											FIF->FIF_VLCOM 	:= FIF->FIF_VLBRUT - FIF->FIF_VLLIQ
											FIF->FIF_TXSERV	:= Round(( FIF->FIF_VLCOM / FIF->FIF_VLBRUT )  * 100, nTamTXSERV)
											FIF->FIF_DTCRED := dDataTef
											FIF->FIF_PARCEL := ""
											FIF->FIF_TPPROD := SubStr(cCurrLine,68,1)
											FIF->FIF_CAPTUR := ""
											FIF->FIF_CODRED := cCodBan
											FIF->FIF_CODBCO := aBanco[1]
											FIF->FIF_CODAGE := aBanco[2]
											FIF->FIF_NUMCC	:= aBanco[3]
											FIF->FIF_SEQREG := PadL( Str( nQtdReg ), 6, '0' )
											FIF->FIF_DTIMP	:= dDataBase
											FIF->FIF_MSIMP	:= DtoS( dDataBase )
											FIF->FIF_CODFIL := cCodFil
											FIF->FIF_CODBAN := cCodBan
											FIF->FIF_SEQFIF	:= cSeqFIF
											FIF->FIF_STVEND	:= '1'  // REDE - Registros dos arquivos EEVC ou EEVD serão considerados para conciliação de vendas. Registros EEFI serão considerados para pagto.
											FIF->FIF_CODADM	:= cCodRede
											FIF->FIF_CODMAJ := SubStr(cCurrLine,089,002)
											FIF->FIF_CODLOJ := cEmpTef
											FIF->FIF_ARQVEN := aRede[nX][01]
											FIF->FIF_NSUARQ := cNSUARQ
											If __lAPixTpd
												FIF->FIF_MODPAG	:= '1' // 1-TEF / 2-Carteiras Digitais
											Endif	
											FIF->( MsUnlock() )
											
											cSeqFIF := Soma1( cSeqFIF )
										Else
											nQtdNProc++
											nQdtImp++
											cCodEstab 	:= SubStr(cCurrLine,004,009)
											cNuComp 	:= SubStr(cCurrLine,013,009)
											cDescLeg 	:= STR0052 + ' '+  SubStr(cCurrLine,089,002) // "Registro  "
											
											F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg,"REDE",,,,@aCodEst,.T.,cCodFil) // Grava detalhes do Log
											
										EndIf
										(cFIFAlias)->( dbCloseArea() )
										
										aBanco := {}
										
										//Comprovante de venda parcelado sem juros
									ElseIf SubStr(cCurrLine,1,3) == '012'
										// Identifica a transação de crédito parcelado sem juros
										nQtdLida++
										cNumCart	:= SubStr(cCurrLine,68,16)
										cNumCV	    := PADR("", nTamNsu - len(Alltrim(SubStr(cCurrLine,89,12))),"0") + Alltrim(SubStr(cCurrLine,89,12))
										cNSUARQ     := SubStr(cCurrLine,89,12)
										dDataTef	:= CtoD( SubStr(cCurrLine,22,02) + '/' + SubStr(cCurrLine,24,02) + '/' + SubStr(cCurrLine,26,04) )
										cNumRV	    := SubStr(cCurrLine,013,009)
										cCodAut		:= SubStr(cCurrLine,129,006)
										cTotPar		:= IiF(Val(SubStr(cCurrLine,087,002)) > 0, SubStr(cCurrLine,087,002), '1')
										cCaptura	:= SubStr(cCurrLine,205,001)
										n012VlTot   := Round(  Val(SubStr(cCurrLine,038,015))  / Val(cTotPar) / 100, 2)  // Valor Total da Venda
										n012Vl1Par  := Round(  Val(SubStr(cCurrLine,221,015))  / 100, 2 ) // Valor da 1 Parcela
										n012VlDema  := Round(  Val(SubStr(cCurrLine,236,015))  / 100, 2 ) // Valor das demais parcelas
										
										
										//Rede Possui um conceito de que aglutina vendas distintas no mesmo reistro 014 gerando um registro 012 para cada venda,
										//com isso é necessário armazenar as informações do 012 para gravar usando a data de crédito do registro 014.
										
										Aadd(a012Parc,{cCodFil, cNumCV, cNumRV, dDataTef, cNumCart, cTotPar, cCaptura, cCodAut, n012VlTot, n012Vl1Par, n012VlDema})
										
										//Parcela de transação parcelada sem juros
									ElseIf SubStr(cCurrLine,1,3) == '014'
										// Identifica o lançamento das parcelas do RV, da operação parcelada sem juros
										dDtCredito := CToD( SubStr(cCurrLine,085,002) + '/' + SubStr(cCurrLine,087,002) + '/' + SubStr(cCurrLine,089,04) )
										cParcela   := IiF(Val(SubStr(cCurrLine,038,002)) > 0, SubStr(cCurrLine,038,002), '1')
										cParcela   := Padl(Val(cParcela),nTamParc,'0')
										cParAlf    := TrataParc( cParcela, cTipoParc )
										If Len(a012Parc) > 0
											lBackReg := .F. 
											nk := 1
											While nk <= Len(a012Parc)
																							
												// Valida inclusao ou atualização da FIF
												lInclui	:= .T.
												lContinua := .T. 
												DbSelectAre("FIF")
												FIF->(DbSetOrder(6)) //FIF_CODFIL, FIF_DTCRED, FIF_NSUTEF, FIF_PARCEL
												If FIF->(DbSeek(a012Parc[nK,1]+ DtoS(dDtCredito) + PADR(a012Parc[nK,2], nTamNSUTEF,'') + cParcela ))
													
													If FIF->FIF_STVEND == "6" // Se  FIF foi incluída manualmente estará com status "FIF_STVEND" como "6"
														lInclui	  := .F. // Nesse caso será necessário atualizar os dados
														cDescLeg  := STR0064 //"Registro incluido manualmente foi atualizado"
														F914GrvLog('2', cIdProc, cLinLog, cNomArq, dDataIni, cHoraIni,cEmpTef,cNumCV,cDescLeg,"REDE",,,,,.F.)
													Else
														lContinua := .F. // do contrario não prossegue, pula o registro
													EndIf
												EndIf
												
												// Validação para verificar caracter especial na composição dos campos FIF_NSUTEF e FIF_NUCOMP
												lCarEsp := FINCARCESP(a012Parc[nK,2],a012Parc[nK,2])
											
												If lContinua .And. !lCarEsp
													
													nQtdReg++ 
													If nK == 1 .And. !lBackReg
														nQtdLida++  // Conta apenas uma linha do arquivo...
													EndIf
													
													RecLock( 'FIF', lInclui )
													FIF->FIF_FILIAL	:= xFilial("FIF")
													FIF->FIF_TPREG	:= '1'
													FIF->FIF_INTRAN := '0'
													FIF->FIF_CODEST := cEmpTef
													FIF->FIF_DTTEF	:= a012Parc[nK,4]
													FIF->FIF_NURESU	:= a012Parc[nK,3]
													FIF->FIF_NUCOMP := PADR("", nTamNUCOMP - len(Alltrim(a012Parc[nK,2])),"0") + Alltrim(a012Parc[nK,2])
													FIF->FIF_NSUTEF := a012Parc[nK,2]
													FIF->FIF_NUCART := a012Parc[nK,5]
													FIF->FIF_VLBRUT := a012Parc[nK,9]
													FIF->FIF_TOTPAR := a012Parc[nK,6]
													FIF->FIF_VLLIQ	:= IIf(Val(cParcela)==1,a012Parc[nK,10],a012Parc[nK,11])
													FIF->FIF_DTCRED := dDtCredito
													FIF->FIF_PARCEL := cParcela
													FIF->FIF_TPPROD := 'C'
													FIF->FIF_CAPTUR := a012Parc[nK,7]
													FIF->FIF_CODRED := cCodBan
													FIF->FIF_CODBCO := aBanco[1]
													FIF->FIF_CODAGE := aBanco[2]
													FIF->FIF_NUMCC	:= aBanco[3]
													FIF->FIF_VLCOM	:= FIF->FIF_VLBRUT - FIF->FIF_VLLIQ
													FIF->FIF_TXSERV	:= Round(( FIF->FIF_VLCOM / FIF->FIF_VLBRUT )  * 100, nTamTXSERV)
													FIF->FIF_CODAUT := a012Parc[nK,8]
													FIF->FIF_SEQREG := PadL( Str( nQtdReg ), 6, '0' )
													FIF->FIF_DTIMP	:= dDataBase
													FIF->FIF_MSIMP	:= DtoS( dDataBase )
													FIF->FIF_CODFIL := cCodFil
													FIF->FIF_CODBAN := cCodBan
													FIF->FIF_SEQFIF	:= cSeqFIF
													FIF->FIF_STATUS	:= ' '
													FIF->FIF_PARALF	:= cParAlf
													FIF->FIF_STVEND	:= '1'  // REDE - Registros dos arquivos EEVC ou EEVD serão considerados para conciliação de vendas. Registros EEFI serão considerados para pagto.
													FIF->FIF_CODADM	:= cCodRede
													FIF->FIF_CODLOJ := cEmpTef
													FIF->FIF_ARQVEN := aRede[nX][01]
													FIF->FIF_NSUARQ := cNSUARQ
													If __lAPixTpd
														FIF->FIF_MODPAG	:= '1' // 1-TEF / 2-Carteiras Digitais
													Endif														
													
													FIF->( MsUnlock() )													
													cSeqFIF := Soma1( cSeqFIF )
												Else
													If nK == 1 .And. !lBackReg // conto apenas uma linha lida do arquivo
														nQtdNProc++
														nQdtImp++
														cNuComp  := PADR("", nTamNUCOMP - len(Alltrim(a012Parc[nK,2])),"0") + Alltrim(a012Parc[nK,2])

														If !lCarEsp
															cDescLeg := STR0052 +"014"+ STR0054 // "Registro"  //"Já importado anteriormente."
														else
															cDescLeg := STR0066
															lCarEsp  := .F.
														Endif		
												
														F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg,STR0012) // Grava detalhes do Log
													EndIf
												EndIf
												
												If Val(a012Parc[nK,6]) == Val(cParcela)
														
													lBackReg := nK  <> Len(a012Parc)
												
													// Atingiu o maximo de parcela exclui do array para não gerar parcelas indevidas.
  													aDel(a012Parc,nK)
												
													aSize(a012Parc,Len(a012Parc)-1)
													// em caso de exclusão de uma posição a cima volto o contador para a linha anterior para seguir o processo. 
													
												Else
													nK++	
												EndIf				
											EndDo 
										Else
											cNuComp  := cNumCV
											cDescLeg := STR0065 // "Inconsistencia entre o registro 012 em conjunto com o 014, reveja o Arquivo"
											F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg)
											nQtdNProc++
											nQdtImp++
										EndIf
										//Consulta Serasa
									ElseIf SubStr(cCurrLine,1,3) == '040' .OR.  SubStr(cCurrLine,1,3) == '019'  // Consulta Serasa
										nRegNProc := AScan(aRegNProc, { |x| Upper(x[1]) == "REDE" .AND. x[2] == SubStr(cCurrLine,1,3) })
										
										If nRegNProc == 0
											cDescLeg  := STR0052 + SubStr(cCurrLine,1,3) + STR0053 // "Registro"  //" não é processado pelo conciliador."
											cCodEstab := ""
											cNuComp   := ""
										Else
											cDescLeg  := STR0052 + SubStr(cCurrLine,1,3) + " - "+Alltrim(aRegNProc[nRegNProc][5]) + STR0053 // "Registro"  //" não é processado pelo conciliador."
											cCodEstab := iIf(aRegNProc[nRegNProc][3] > 0,SubStr(cCurrLine,aRegNProc[nRegNProc][3],aRegNProc[nRegNProc][4]),"")
											cNuComp   := ""
										EndIf
										
										F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg)
										
										nQtdNProc++
										nQtdSerasa++
									Else
										nRegNProc := AScan(aRegNProc, { |x| Upper(x[1]) == "REDE" .AND. x[2] == SubStr(cCurrLine,1,3) })
										
										If nRegNProc == 0
											cDescLeg  :=  STR0052 + SubStr(cCurrLine,1,3)+ STR0053 // "Registro"  //" não é processado pelo conciliador."
											cCodEstab := ""
											cNuComp   := ""
										Else
											cDescLeg  := STR0052 + SubStr(cCurrLine,1,3)+" - "+Alltrim(aRegNProc[nRegNProc][5])+ STR0053 // "Registro"  //" não é processado pelo conciliador."
											cCodEstab := iIf(aRegNProc[nRegNProc][3] > 0,SubStr(cCurrLine,aRegNProc[nRegNProc][3],aRegNProc[nRegNProc][4]),"")
											cNuComp   := ""
										EndIf
										
										F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg)
										
										nQtdNProc++
									EndIf
								EndIf
							Endif
						Endif
						
						FT_FSKIP()
						cCurrLine := FT_FREADLN()
						
					EndDo
					
					END TRANSACTION
					
				ElseIf SubStr(cCurrLine,147,4) == 'EEVD' //Processo arquivo com vendas de cartão de débito
					
					BEGIN TRANSACTION
					
					lFilEmp 	:= .F.
					nLinTotal 	:= 0
					nQtdLida 	:= 0
					
					While !FT_FEOF()
						
						nLinha++
						lLinOk	:= !Empty(cCurrLine)
						cLinLog := StrZero( nLinha, nTamLinha )
						
						// Tratamento da linha para evitar error.log com linhas em branco e arquivos sem vínculo com a operadora (sujeira)
						If lLinOk
							aCurrLine	:= StrToKArr( cCurrLine, ',' )
							If nLinha == 1 .And. ( Len(aCurrLine) > 01 .And. aCurrLine[01] <> '00' .Or. Len(aCurrLine) < 01)
								cStatus	:= "2" // 2=Versão do arquivo incompatível
								lErro 	:= .T.
								lLinOk  := .F.
								Exit
							ElseIf nLinha > 1 .And. Len(aCurrLine) < 01
								lLinOk := .F.
							EndIf
						EndIf
						
						If lLinOk
							
							//Header
							If aCurrLine[01] == '00'
								nQtdLida++
								If SubStr(aCurrLine[10],1,5) != 'V1.04' //Caso a versão do arquivo seja diferente da versão 2.01, não processo
									cStatus	 := "2" // 2=Versão do arquivo incompatível
									cDescLeg := STR0028+" "+Alltrim(SubStr(aCurrLine[10],1,5))+"."
									lErro 	 := .T.
									lLinOk   := .F.
									Exit
								EndIf
							EndIf
							If SubStr(cCurrLine,1,3) == "052" // Rever não temos esse registro
								nQtdLida++
							EndIf
							If SubStr(cCurrLine,1,3) <> '00'.and. SubStr(cCurrLine,1,3) <> "052"
								
								lContinua	:= Fa914VldImp(SubStr(cCurrLine,004,009), "REDE", @cCodFil ) // Valida se filial poderá ser importada
								
								If !lContinua
									nQtdNProc++
									cCodEstab 	:= SubStr(aCurrLine[02],1,9)
									cNuComp 	:= SubStr(aCurrLine[05],1,9)
									cDescLeg    := STR0036
									
									F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg,"REDE",,,,@aCodEst,.T.,cCodFil) // Grava detalhes do Log
									
									//Resumo de vendas
								Else
									
									If aCurrLine[01] == '01'
										nQtdLida++
										aAdd( aBanco, aCurrLine[11] )
										aAdd( aBanco, aCurrLine[12] )
										aAdd( aBanco, aCurrLine[13] )
										
										//Detalhamento dos comprovantes de vendas
									ElseIf aCurrLine[01] == '05'
										dDtCredito := CtoD( SubStr( aCurrLine[11], 001, 002 ) + '/' + SubStr( aCurrLine[11], 003, 002 ) + '/' + SubStr( aCurrLine[11], 005, 004 ) )
										cNumCV     := PADR("", nTamNsu - len(Alltrim(aCurrLine[10])),"0") + Alltrim(aCurrLine[10])
										cNSUARQ    := aCurrLine[10]
										cParcela   := PadL( '1', nTamParc, '0' )
										cParAlf    := TrataParc( cParcela, cTipoParc )
										
										// Valida inclusao ou atualização da FIF
										lInclui	:= .T.
										DbSelectArea("FIF")
										FIF->(DbSetOrder(6)) //FIF_CODFIL, FIF_DTCRED, FIF_NSUTEF, FIF_PARCEL
										If FIF->(DbSeek(cCodFil + DtoS(dDtCredito) + PADR(cNumCV, nTamNSUTEF,'')  + cParcela ))
											
											If FIF->FIF_STVEND == "6" // Se  FIF foi incluída manualmente estará com status "FIF_STVEND" como "6"
												lInclui	 := .F. // Nesse caso será necessário atualizar os dados
												cDescLeg := STR0064 // "Registro incluido manualmente foi atualizado"
												F914GrvLog('2', cIdProc, cLinLog, cNomArq, dDataIni, cHoraIni,cEmpTef,cNumCV,cDescLeg,"REDE",,,,,.F.)
											Else
												lContinua := .F. // do contrario não prossegue, pula o registro
											EndIf
										EndIf
										
										// Validação para verificar caracter especial na composição dos campos FIF_NSUTEF e FIF_NUCOMP
										lCarEsp := FINCARCESP(cNumCV,cNumCV)
											
										If lContinua .and. !lCarEsp
											
											Iif(lInclui,nQtdReg++,nQtdAlt++)
											nQtdLida++
											RecLock( 'FIF', lInclui )
											FIF->FIF_FILIAL	:= xFilial("FIF")
											FIF->FIF_TPREG	:= '1'
											FIF->FIF_INTRAN := '0'
											FIF->FIF_CODEST := aCurrLine[02]
											FIF->FIF_DTTEF	:= CtoD( SubStr( aCurrLine[04], 001, 002 ) + '/' + SubStr( aCurrLine[04], 003, 002 ) + '/' + SubStr( aCurrLine[04], 005, 004 ) )
											FIF->FIF_NURESU	:= aCurrLine[03]
											FIF->FIF_NUCOMP := PADR("", nTamNUCOMP - len(Alltrim(cNumCV)),"0") + Alltrim(cNumCV)
											FIF->FIF_NSUTEF := cNumCV
											FIF->FIF_NUCART := aCurrLine[08]
											FIF->FIF_VLBRUT := Round( Val( aCurrLine[05] ) / 100, 2 )
											FIF->FIF_TOTPAR := '00'
											FIF->FIF_VLLIQ	:= Round( Val( aCurrLine[07] ) / 100, 2 )
											FIF->FIF_DTCRED := CtoD( SubStr( aCurrLine[11], 001, 002 ) + '/' + SubStr( aCurrLine[11], 003, 002 ) + '/' + SubStr( aCurrLine[11], 005, 004 ) )
											FIF->FIF_PARCEL := cParcela
											FIF->FIF_TPPROD := 'D'
											FIF->FIF_CAPTUR := ''
											FIF->FIF_CODRED := ''
											FIF->FIF_CODBCO := aBanco[1]
											FIF->FIF_CODAGE := aBanco[2]
											FIF->FIF_NUMCC	:= aBanco[3]
											FIF->FIF_VLCOM	:= Round( Val( aCurrLine[06] ) / 100, 2 )
											FIF->FIF_TXSERV	:= Round(( FIF->FIF_VLCOM / FIF->FIF_VLBRUT )  * 100, nTamTXSERV)
											FIF->FIF_CODAUT := ''
											FIF->FIF_SEQREG := PadL( Str( nQtdReg ), 6, '0' )
											FIF->FIF_DTIMP	:= dDataBase
											FIF->FIF_MSIMP	:= DtoS( dDataBase )
											FIF->FIF_CODFIL := cCodFil
											FIF->FIF_CODBAN := aCurrLine[19]
											FIF->FIF_SEQFIF	:= cSeqFIF
											FIF->FIF_PARALF	:= cParAlf
											FIF->FIF_STVEND	:= '1'  // REDE - Registros dos arquivos EEVC ou EEVD serão considerados para conciliação de vendas. Registros EEFI serão considerados para pagto.
											FIF->FIF_CODADM	:= cCodRede
											FIF->FIF_CODLOJ := aCurrLine[02]
											FIF->FIF_ARQVEN := aRede[nX][01]
											FIF->FIF_NSUARQ := cNSUARQ
											If __lAPixTpd
												FIF->FIF_MODPAG	:= '1' // 1-TEF / 2-Carteiras Digitais
											Endif	
											
											FIF->( MsUnlock() )
											
											cSeqFIF := Soma1( cSeqFIF )
										Else
											nQtdNProc++
											nQdtImp++
											cNuComp  := cNumCV
										
											If !lCarEsp
												cDescLeg := STR0052 +"05"+ STR0054 // "Registro "  //" Já importado anteriormente."
											else
												cDescLeg := STR0066
												lCarEsp  := .F.
											Endif		
									
											F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg,STR0012) // Grava detalhes do Log
										EndIf
									ElseIf !(SubStr(cCurrLine,1,3) $ "037/050")  // Rever não tem esses registros
										nRegNProc := AScan(aRegNProc, { |x| Upper(x[1]) == "REDE" .AND. x[2] == SubStr(cCurrLine,1,3) })
										
										If nRegNProc == 0
											cDescLeg  := STR0052 + aCurrLine[01]+ STR0053 // "Registro"  //" não é processado pelo conciliador."
											cCodEstab := ""
											cNuComp   := ""
										Else
											cDescLeg  :=  STR0052+ aCurrLine[01]+" - "+Alltrim(aRegNProc[nRegNProc][5])+ STR0053 // "Registro"  //" não é processado pelo conciliador."
											cCodEstab := iIf(aRegNProc[nRegNProc][3] > 0,SubStr(cCurrLine,aRegNProc[nRegNProc][3],aRegNProc[nRegNProc][4]),"")
											cNuComp   := ""
										EndIf
										
										F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg)
										nQtdNProc++
									EndIf
								EndIf
							EndIf
						EndIf
						
						FT_FSKIP()
						cCurrLine := FT_FREADLN()
						
					EndDo
					
					END TRANSACTION
					
				Elseif  SubStr(cCurrLine,122,4) == 'EEFI' //Processo arquivo de pagamento REDE
					
					BEGIN TRANSACTION
					
					lTem035 	:= .F.
					nQtd035 	:= 0
					nQtdSerasa  := 0
					lFilEmp		:= .F.
					nLinTotal 	:= 0
					nQtdLida 	:= 0
					
					While !FT_FEOF() //pesquisa para encontrar o registro 035
						
						lLinOk	:= !Empty(cCurrLine)
						
						If lLinOk .and.  SubStr(cCurrLine,1,3) == '035'
							nQtd035++
							
							(cArqEEFI)->(DbAppend())
							(cArqEEFI)->Filial	 := xFilial("FIF")
							(cArqEEFI)->CODEST	 := SubStr( cCurrLine, 4, 9 )
							//Chave entre registtros 034 e 035
							(cArqEEFI)->NUMPV 	 := SubStr( cCurrLine, 04, 9 )
							(cArqEEFI)->NURESU	 := SubStr( cCurrLine, 13, 9 )
							(cArqEEFI)->DTTEF	 := CToD( SubStr( cCurrLine, 147, 2 ) + '/' + SubStr( cCurrLine, 149, 2 ) + '/' + SubStr( cCurrLine, 151, 04 ) )
							(cArqEEFI)->NSUTEF	 := PADR("", nTamNsu-len(Alltrim(SubStr(cCurrLine,093,006))),"0") + Alltrim(SubStr(cCurrLine,093,006))
							(cArqEEFI)->NSUARQ	 := SubStr(cCurrLine,093,006)
							(cArqEEFI)->NUCART	 := SubStr( cCurrLine, 76, 16 )
							(cArqEEFI)->CAPTUR	 := SubStr( cCurrLine, 257, 16 )
							//Motivo do ajuste
							(cArqEEFI)->MOTAJUST := SubStr( cCurrLine, 46, 2 )
							//Valores referente ao ajuste
							(cArqEEFI)->VLAJUST	 := SubStr(cCurrLine,30,15 )
							(cArqEEFI)->VLRTX	 := SubStr(cCurrLine,100,15 )
							(cArqEEFI)->VLRPARC	 := SubStr(cCurrLine,179,15 )
							(cArqEEFI)->VLRORIG	 := SubStr(cCurrLine,194,15 )
							(cArqEEFI)->VLBRUT	 := SubStr(cCurrLine,209,15 )
							(cArqEEFI)->VLRPARC	 := SubStr(cCurrLine,224,15 )
						Endif
						FT_FSKIP()
						cCurrLine	:= FT_FREADLN()
					Enddo
					
					
					//Volto Arquivo para inicio para começar a leitura
					FT_FGOTOP()
					cCurrLine := FT_FREADLN()
					
					While !FT_FEOF()
						
						nLinha++
						
						lLinOk	:= !Empty(cCurrLine)
						cLinLog := StrZero( nLinha, nTamLinha )
						
						If lLinOk  .And. SubStr(cCurrLine,1,3) == '032'
							lLinOk := .F.
							nQtdLida++
						EndIf
						
						If lLinOk
							
							//Header
							If SubStr(cCurrLine,1,3) == '030'
								nQtdLida++
								If SubStr(cCurrLine,106,5) != "V3.01" //Caso a versão do arquivo seja diferente da versão 2.01, não processo
									cStatus	 := "2" // 2=Versão do arquivo incompatível
									cDescLeg := STR0028+" "+Alltrim(SubStr(cCurrLine,106,5))+"."
									lErro 	 := .T.
									lLinOk   := .F.
									Exit
								EndIf
							EndIf
							If SubStr(cCurrLine,1,3) == '052'
								nQtdLida++
							EndIF
							
							If SubStr(cCurrLine,1,3) <> '030' .and. SubStr(cCurrLine,1,3) <> '052'
								
								lContinua	:= Fa914VldImp(SubStr(cCurrLine,004,009), "REDE", @cCodFil ) // Valida se filial poderá ser importada
								
								If !lContinua
									nQtdNProc++
									cCodEstab 	:= SubStr(cCurrLine,004,009)
									cNuComp 	:= SubStr(cCurrLine,013,11)
									cDescLeg    := STR0036
									
									F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg,"REDE",,,,@aCodEst,.T.,cCodFil) // Grava detalhes do Log
								Else
									
									//Ordem de Crédito
									If SubStr(cCurrLine,1,3) == '034'
										lTem035    := .F.
										cCodEst	   := SubStr(cCurrLine,04,9)
										dDtCredito := CtoD( SubStr( cCurrLine, 24, 2 ) + '/' + SubStr( cCurrLine, 26, 2 ) + '/' + SubStr( cCurrLine, 28, 04 ) )
										cNuresu	   := SubStr(cCurrLine,76,9)
										cParc 	   := SubStr(cCurrLine,125,2)
										
										//Verifica se o registro 034 possui algum ajuste 035
										(cArqEEFI)->( DbGoTop() )
										
										If (cArqEEFI)->(DbSeek(cCodEst + Dtos(dDtCredito) + cNuresu))
											lTem035 := .T.
										EndIf
										
										// Encontra o título na FIF referente ao registro 034
										cQuery := "SELECT FIF_FILIAL, FIF_CODEST, FIF_DTCRED, FIF_PARCEL, FIF_NURESU, FIF_NSUTEF "
										cQuery += "FROM " + AllTrim(RetSqlName("FIF")) + " FIF "
										cQuery += "WHERE FIF_FILIAL = '" + FWxFilial("FIF") + "'"
										
										cQuery += "AND FIF_CODEST = '" + cCodEst + "' "
										cQuery += "AND FIF_DTCRED = '" + Dtos(dDtCredito) + "' "
										cQuery += "AND FIF_NURESU = '" + cNuresu + "' "
										cQuery += "AND FIF_PARCEL = '" + cParc + "' "
										cQuery += "AND FIF_STATUS = ' ' "
										cQuery += "AND FIF_STVEND = '1' "
										cQuery += "AND FIF.D_E_L_E_T_ <> '*' "
										
										cQuery := ChangeQuery( cQuery )
										
										cAliasQry := GetNextAlias()
										dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry, .F., .T. )
										
										// Valida atualização da FIF referente ao registro 034
										DbSelectArea("FIF")
										FIF->(DbSetOrder(6)) //FIF_CODFIL, FIF_DTCRED, FIF_NSUTEF, FIF_PARCEL
										If DbSeek(cCodFil + (cAliasQry)->FIF_DTCRED + (cAliasQry)->FIF_NSUTEF + (cAliasQry)->FIF_PARCEL )
											nQtdAlt++
											nQtdLida++
											RecLock( 'FIF', .F. )
											If lTem035
												FIF->FIF_STATUS	:= '1'
												FIF->FIF_TPREG	:= '3'
												FIF->FIF_CODMAJ := (cArqEEFI)->MOTAJUST
											Else
												FIF->FIF_STATUS	:= '1'
											Endif
											FIF->FIF_ARQPAG := aRede[nX][01]
											FIF->( MsUnlock() )
											
											cCodEstab 	:= cCodEst
											cNuComp 	:= SubStr(cCurrLine,013,11)
											cDescLeg 	:= STR0063  //"Registro alterado por motivo de ajuste"  
											F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg)
										Else
											nQtdNProc++
											cCodEstab 	:= cCodEst
											cNuComp 	:= SubStr(cCurrLine,013,11)
											cDescLeg 	:= STR0046 + ' NSUTEF '+  cNuresu //Arquivo de pagamento/antecipação sem vendas localizadas
											F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg)
										EndIf
										(cAliasQry)->( dbCloseArea() )
										
										//Resumo Antecipado RAV
									ElseIf SubStr(cCurrLine,1,3) == '036'
										lTem035  := .F.
										cCodEst	 := SubStr(cCurrLine,04,9)
										dDataTef := CtoD( SubStr( cCurrLine, 24, 2 ) + '/' + SubStr( cCurrLine, 26, 2 ) + '/' + SubStr( cCurrLine, 28, 04 ) )
										dDataDeb := CtoD( SubStr( cCurrLine, 243, 2 ) + '/' + SubStr( cCurrLine, 245, 2 ) + '/' + SubStr( cCurrLine, 247, 04 ) )
										cNuresu	 := SubStr(cCurrLine,68,9)
										cNuComp  := PADR("", nTamNUCOMP - len(Alltrim(SubStr(cCurrLine,013,11))),'0') + Alltrim(SubStr(cCurrLine,013,11))
										
										aAdd( aBanco, SubStr(cCurrLine,048,003) ) // Banco
										aAdd( aBanco, SubStr(cCurrLine,051,006) ) // Agência
										aAdd( aBanco, SubStr(cCurrLine,057,011) ) // Conta
										
										cParcela := IiF(Val(SubStr(cCurrLine,108,2)) > 0, SubStr(cCurrLine,108,2), '1')
										cParcela := Padl(Val(cParcela),nTamParc,'0')
										
										//Verifica se o registro 036 possui algum ajuste 035
										(cArqEEFI)->( DbGoTop() )
										
										If (cArqEEFI)->(DbSeek(cCodEst + Dtos(dDataTef) + cNuresu))
											cNumCV  := (cArqEEFI)->NSUTEF
											cNSUARQ := (cArqEEFI)->NSUARQ
											lTem035 := .T.
										Else
											cNumCV  := ''
											cNSUARQ := ''
										Endif
										
										// Valida inclusao
										DbSelectArea("FIF")
										FIF->(DbSetOrder(6)) //FIF_CODFIL, FIF_DTCRED, FIF_NSUTEF, FIF_PARCEL
										If FIF->(DbSeek(cCodFil + DtoS(dDataDeb) + cNumCV  + cParcela))
											lContinua := .F.
										EndIf
										
										// Validação para verificar caracter especial na composição dos campos FIF_NSUTEF e FIF_NUCOMP
										lCarEsp := FINCARCESP(cNumCV,cNuComp,@lNsuTef,@lNuComp)
											
										If lContinua .And. !lCarEsp

											nQtdReg++
											nQtdLida++
											RecLock( 'FIF', .T. )
											FIF->FIF_FILIAL	:= xFilial("FIF")
											FIF->FIF_TPREG	:= '3'
											FIF->FIF_INTRAN := '0'
											FIF->FIF_CODEST := cCodEst
											FIF->FIF_DTTEF	:= dDataTef
											FIF->FIF_NURESU	:= cNuresu
											FIF->FIF_NUCOMP := cNuComp
											FIF->FIF_NSUTEF := cNumCV
											FIF->FIF_NUCART := If(lTem035,(cArqEEFI)->NUCART,'')
											FIF->FIF_CODBCO := aBanco[1]
											FIF->FIF_CODAGE := aBanco[2]
											FIF->FIF_NUMCC	:= aBanco[3]
											FIF->FIF_CODFIL := cCodFil
											FIF->FIF_CODBAN := SubStr(cCurrLine,152,1)
											FIF->FIF_SEQREG := PadL( Str( nQtdReg ), 6, '0' )
											FIF->FIF_DTIMP	:= dDataBase
											FIF->FIF_MSIMP	:= DtoS( dDataBase )
											FIF->FIF_SEQFIF	:= cSeqFIF
											FIF->FIF_STATUS	:= '1' // Será apresentado tanto na venda quanto no pagamento
											FIF->FIF_STVEND	:= '1'
											FIF->FIF_CODADM	:= cCodRede
											FIF->FIF_CODMAJ := If(lTem035,(cArqEEFI)->MOTAJUST,'')
											FIF->FIF_CODLOJ := cCodEst
											FIF->FIF_VLBRUT := IF(lTem035,Round( Val((cArqEEFI)->VLBRUT ) / 100, nTamVLBRUT ),Round( Val( SubStr(cCurrLine,113,15) ) / 100, nTamVLBRUT ))
											FIF->FIF_VLCOM 	:= Round( Val( SubStr(cCurrLine,128,15) ) / 100, nTamVLCOM )
											FIF->FIF_VLLIQ	:= IF(lTem035,Round( Val((cArqEEFI)->VLRORIG ) / 100, nTamVLBRUT ), FIF->FIF_VLBRUT - FIF->FIF_VLCOM)
											FIF->FIF_TXSERV	:= Round(( FIF->FIF_VLCOM / FIF->FIF_VLBRUT )  * 100, nTamTXSERV)
											FIF->FIF_TOTPAR := ""
											FIF->FIF_DTCRED := dDataDeb
											FIF->FIF_PARCEL := cParcela
											FIF->FIF_TPPROD := SubStr(cCurrLine,47,1)
											FIF->FIF_CAPTUR := ""
											FIF->FIF_CODRED := SubStr(cCurrLine,152,1)
											FIF->FIF_ARQPAG := aRede[nX][01]
											FIF->FIF_NSUARQ := cNSUARQ
											If __lAPixTpd
												FIF->FIF_MODPAG	:= '1' // 1-TEF / 2-Carteiras Digitais
											Endif	
											
											FIF->( MsUnlock() )
											
											cSeqFIF := Soma1( cSeqFIF )
										Else
											
											If !lCarEsp
												cDescLeg := STR0052 +"036"+ STR0054 // "Registro "  //" Já importado anteriormente."
											else
												cDescLeg := STR0066
												lCarEsp  := .F.
											Endif		
									
											F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,Iif(lNsutef,cNumCV,cNuComp),cDescLeg,STR0012) // Grava detalhes do Log

											nQtdNProc++
											nQdtImp++
											lNsuTef  := .F.
											lNuComp  := .F.
										Endif
										
										aBanco := {}
										//Ajuste a Débito
									ElseIf SubStr(cCurrLine,1,3) == '038'
										cCodEst	 := SubStr(cCurrLine,04,9)
										dDataTef := CtoD( SubStr( cCurrLine, 24, 2 ) + '/' + SubStr( cCurrLine, 26, 2 ) + '/' + SubStr( cCurrLine, 28, 04 ) )
										dDataDeb := CtoD( SubStr( cCurrLine, 243, 2 ) + '/' + SubStr( cCurrLine, 245, 2 ) + '/' + SubStr( cCurrLine, 247, 04 ) )
										cNumCV   := PADR("", nTamNsu - len(Alltrim(SubStr(cCurrLine,222,12))),"0") + Alltrim(SubStr(cCurrLine,222,12))
										cNSUARQ  := SubStr(cCurrLine,222,12)
										cParcela := PadL( '1', nTamParc, '0' )
										cNuComp  := PADR("", nTamNUCOMP - len(Alltrim(SubStr(cCurrLine,013,11))),'0') + Alltrim(SubStr(cCurrLine,013,11))
										
										aAdd( aBanco, SubStr(cCurrLine,048,003) ) // Banco
										aAdd( aBanco, SubStr(cCurrLine,051,006) ) // Agência
										aAdd( aBanco, SubStr(cCurrLine,057,011) ) // Conta
										
										// Valida inclusao
										DbSelectArea("FIF")
										FIF->(DbSetOrder(6)) //FIF_CODFIL, FIF_DTCRED, FIF_NSUTEF, FIF_PARCEL
										If FIF->(DbSeek(cCodFil + DtoS(dDataDeb) + cNumCV  + cParcela))
											lContinua := .F.
										EndIf
										
										// Validação para verificar caracter especial na composição dos campos FIF_NSUTEF e FIF_NUCOMP
										lCarEsp := FINCARCESP(cNumCV,cNuComp,@lNsuTef,@lNuComp)
											
										If lContinua .and. !lCarEsp

											nQtdReg++
											nQtdLida++
											RecLock( 'FIF', .T. )
											FIF->FIF_FILIAL	:= xFilial("FIF")
											FIF->FIF_TPREG	:= '3'
											FIF->FIF_INTRAN := '0'
											FIF->FIF_CODEST := cCodEst
											FIF->FIF_DTTEF	:= dDataTef
											FIF->FIF_NURESU	:= SubStr(cCurrLine,234,9)
											FIF->FIF_NUCOMP := cNuComp
											FIF->FIF_NSUTEF := cNumCV
											FIF->FIF_NUCART := SubStr(cCurrLine,130,16)
											FIF->FIF_VLBRUT := Round( Val( SubStr(cCurrLine,251,15) ) / 100, nTamVLBRUT )
											FIF->FIF_TOTPAR := ""
											FIF->FIF_VLLIQ	:= Round( Val( SubStr(cCurrLine,32,15) ) / 100, nTamVLBRUT )
											FIF->FIF_VLCOM 	:= FIF->FIF_VLBRUT - FIF->FIF_VLLIQ
											FIF->FIF_TXSERV	:= Round(( FIF->FIF_VLCOM / FIF->FIF_VLBRUT )  * 100, nTamTXSERV)
											FIF->FIF_DTCRED := dDataDeb
											FIF->FIF_PARCEL := cParcela
											FIF->FIF_TPPROD := "D"
											FIF->FIF_CAPTUR := ""
											FIF->FIF_CODRED := SubStr(cCurrLine,303,1)
											FIF->FIF_CODBCO := aBanco[1]
											FIF->FIF_CODAGE := aBanco[2]
											FIF->FIF_NUMCC	:= aBanco[3]
											FIF->FIF_SEQREG := PadL( Str( nQtdReg ), 6, '0' )
											FIF->FIF_DTIMP	:= dDataBase
											FIF->FIF_MSIMP	:= DtoS( dDataBase )
											FIF->FIF_CODFIL := cCodFil
											FIF->FIF_CODBAN := SubStr(cCurrLine,303,1)
											FIF->FIF_SEQFIF	:= cSeqFIF
											FIF->FIF_STATUS	:= '1' // Será apresentado tanto na venda quanto no pagamento
											FIF->FIF_STVEND	:= '1'
											FIF->FIF_CODADM	:= cCodRede
											FIF->FIF_CODMAJ := SubStr(cCurrLine,100,2)
											FIF->FIF_CODLOJ := cCodEst
											FIF->FIF_ARQPAG := aRede[nX][01]
											FIF->FIF_NSUARQ := cNSUARQ
											If __lAPixTpd
												FIF->FIF_MODPAG	:= '1' // 1-TEF / 2-Carteiras Digitais
											Endif	
											
											FIF->( MsUnlock() )
											
											cSeqFIF := Soma1( cSeqFIF )
										Else
											
											If !lCarEsp
												cDescLeg := STR0052 +"038"+ STR0054 // "Registro "  //" Já importado anteriormente."
											else
												cDescLeg := STR0066
												lCarEsp  := .F.
											Endif		
									
											F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,Iif(lNsutef,cNumCV,cNuComp),cDescLeg,STR0012) // Grava detalhes do Log
											
											nQtdNProc++
											nQdtImp++
											lNsuTef  := .F.
											lNuComp  := .F.	
										Endif
										
										aBanco := {}
										//Ajuste a Crédito
									ElseIf SubStr(cCurrLine,1,3) == '043'
										lTem035  := .F.
										cCodEst	 := SubStr(cCurrLine,04,9)
										dDataTef := CtoD( SubStr( cCurrLine, 33, 2 ) + '/' + SubStr( cCurrLine, 35, 2 ) + '/' + SubStr( cCurrLine, 37, 04 ) )
										dDataCre := CtoD( SubStr( cCurrLine, 41, 2 ) + '/' + SubStr( cCurrLine, 43, 2 ) + '/' + SubStr( cCurrLine, 45, 04 ) )
										cNuresu	 := SubStr(cCurrLine,13,9)
										cParcela := PadL( '1', nTamParc, '0' )
										cNuComp  := PADR("", nTamNUCOMP - len(Alltrim(SubStr(cCurrLine,022,11))),'0') + Alltrim(SubStr(cCurrLine,022,11))
										
										aAdd( aBanco, SubStr(cCurrLine,065,003) ) // Banco
										aAdd( aBanco, SubStr(cCurrLine,068,006) ) // Agência
										aAdd( aBanco, SubStr(cCurrLine,074,011) ) // Conta
										
										//Verifica se o registro 043 possui algum ajuste 035
										(cArqEEFI)->( DbGoTop() )
										
										If (cArqEEFI)->(DbSeek(cCodEst + Dtos(dDataCre) + cNuresu))
											lTem035 := .T.
											cNumCV  := (cArqEEFI)->NSUTEF
											cNSUARQ := (cArqEEFI)->NSUARQ
										Else
											cNumCV  := ''
											cNSUARQ := ''
										EndIf
										
										// Valida inclusao
										DbSelectArea("FIF")
										FIF->(DbSetOrder(6)) //FIF_CODFIL, FIF_DTCRED, FIF_NSUTEF, FIF_PARCEL
										If FIF->(DbSeek(cCodFil + DtoS(dDataDeb) + cNumCV  + cParcela))
											lContinua := .F.
										EndIf
										
										// Validação para verificar caracter especial na composição dos campos FIF_NSUTEF e FIF_NUCOMP
										lCarEsp := FINCARCESP(cNumCV,cNuComp,@lNsuTef,@lNuComp)
											
										If lContinua .And. !lCarEsp

											nQtdReg++
											nQtdLida++
											RecLock( 'FIF', .T. )
											FIF->FIF_FILIAL	:= xFilial("FIF")
											FIF->FIF_TPREG	:= '3'
											FIF->FIF_INTRAN := '0'
											FIF->FIF_CODEST := cCodEst
											FIF->FIF_DTTEF	:= dDataTef
											FIF->FIF_NURESU	:= SubStr(cCurrLine,13,9)
											FIF->FIF_NUCOMP := cNuComp
											FIF->FIF_NSUTEF := cNumCV
											FIF->FIF_NUCART := If(lTem035,(cArqEEFI)->NUCART,'')
											FIF->FIF_VLBRUT := IF(lTem035,Round( Val((cArqEEFI)->VLBRUT ) / 100, nTamVLBRUT ),Round( Val( SubStr(cCurrLine,49,15) ) / 100, nTamVLBRUT ))
											FIF->FIF_TOTPAR := ""
											FIF->FIF_VLLIQ	:= Round( Val((cArqEEFI)->VLRORIG ) / 100, nTamVLBRUT )
											FIF->FIF_VLCOM 	:= FIF->FIF_VLBRUT - FIF->FIF_VLLIQ
											FIF->FIF_TXSERV	:= Round(( FIF->FIF_VLCOM / FIF->FIF_VLBRUT )  * 100, nTamTXSERV)
											FIF->FIF_DTCRED := dDataCre
											FIF->FIF_PARCEL := cParcela
											FIF->FIF_TPPROD := "C"
											FIF->FIF_CAPTUR := ""
											FIF->FIF_CODRED := SubStr(cCurrLine,115,1)
											FIF->FIF_CODBCO := aBanco[1]
											FIF->FIF_CODAGE := aBanco[2]
											FIF->FIF_NUMCC	:= aBanco[3]
											FIF->FIF_SEQREG := PadL( Str( nQtdReg ), 6, '0' )
											FIF->FIF_DTIMP	:= dDataBase
											FIF->FIF_MSIMP	:= DtoS( dDataBase )
											FIF->FIF_CODFIL := cCodFil
											FIF->FIF_CODBAN := SubStr(cCurrLine,115,1)
											FIF->FIF_SEQFIF	:= cSeqFIF
											FIF->FIF_STATUS	:= '1' // Será apresentado tanto na venda quanto no pagamento
											FIF->FIF_STVEND	:= '1'
											FIF->FIF_CODADM	:= cCodRede
											FIF->FIF_CODMAJ := If(lTem035,(cArqEEFI)->MOTAJUST,'')
											FIF->FIF_CODLOJ := cCodEst
											FIF->FIF_ARQPAG := aRede[nX][01]
											FIF->FIF_NSUARQ := cNSUARQ
											If __lAPixTpd
												FIF->FIF_MODPAG	:= '1' // 1-TEF / 2-Carteiras Digitais
											Endif	
											
											FIF->( MsUnlock() )
											
											cSeqFIF := Soma1( cSeqFIF )
										Else
											
											If !lCarEsp
												cDescLeg := STR0052 +"043"+ STR0054 // "Registro "  //" Já importado anteriormente."
											else
												cDescLeg := STR0066
												lCarEsp  := .F.
											Endif		
									
											F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,Iif(lNsutef,cNumCV,cNuComp),cDescLeg,STR0012) // Grava detalhes do Log

											nQtdNProc++
											nQdtImp++
											lNsuTef  := .F.
											lNuComp  := .F.	
										Endif
										
										aBanco := {}
										//Consulta Serasa
									ElseIf SubStr(cCurrLine,1,3) == '040' .OR.  SubStr(cCurrLine,1,3) == '019'  // Consulta Serasa
										nRegNProc := AScan(aRegNProc, { |x| Upper(x[1]) == "REDE" .AND. x[2] == SubStr(cCurrLine,1,3) })
										
										If nRegNProc == 0
											cDescLeg  := STR0052 + SubStr(cCurrLine,1,3) + STR0053 // "Registro "  //" não é processado pelo conciliador."
											cCodEstab := ""
											cNuComp   := ""
										Else
											cDescLeg  := STR0052 + SubStr(cCurrLine,1,3) + " - "+Alltrim(aRegNProc[nRegNProc][5]) + STR0053 // "Registro "  //" não é processado pelo conciliador."
											cCodEstab := iIf(aRegNProc[nRegNProc][3] > 0,SubStr(cCurrLine,aRegNProc[nRegNProc][3],aRegNProc[nRegNProc][4]),"")
											cNuComp   := ""
										EndIf
										
										F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg)
										
										nQtdNProc++
										nQtdSerasa++
									ElseIf !(SubStr(cCurrLine,1,3) $ "037/050")
										nRegNProc := AScan(aRegNProc, { |x| Upper(x[1]) == "REDE" .AND. x[2] == SubStr(cCurrLine,1,3) })
										
										If nRegNProc == 0
											cDescLeg  :=  STR0052 + SubStr(cCurrLine,1,3)+ STR0053 // "Registro "  //" não é processado pelo conciliador."
											cCodEstab := ""
											cNuComp   := ""
										Else
											cDescLeg  := STR0052 + SubStr(cCurrLine,1,3)+" - "+Alltrim(aRegNProc[nRegNProc][5])+ STR0053 // "Registro "  //" não é processado pelo conciliador."
											cCodEstab := iIf(aRegNProc[nRegNProc][3] > 0,SubStr(cCurrLine,aRegNProc[nRegNProc][3],aRegNProc[nRegNProc][4]),"")
											cNuComp   := ""
										EndIf
										
										F914GrvLog('2',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg)
										
										nQtdNProc++
									Else
										nQtdLida++
									EndIf
								EndIf
							EndIf
						EndIf
						FT_FSKIP()
						cCurrLine	:= FT_FREADLN()
					EndDo

					END TRANSACTION
					
				Else // Rever correto é tipo de arquivo não importado
					//Erro na abertura do arquivo
					lErro 	 := .T.
					cStatus	 := "6" // 6="Arquivo não importado"
					cDescLeg :=  STR0049  //"Arquivo não importado"
				EndIf
				If cStatus <> "2"
					A914Status(@lErro, @cStatus, @cDescLeg, nQtdReg, nQtdNProc, nLinha, nQtdLida, nQdtImp, nQtdSerasa,nQtdAlt)
				EndIf
			Else
				//Erro na abertura do arquivo
				lErro    := .T.
				cStatus	 := "3" // 3="Falha na abertura do arquivo"
				cDescLeg := STR0029 //"Falha na abertura do arquivo"
			EndIf
			
			FT_FUSE()
		EndIf
		
		nLinTotal := nQtdNProc + nQtdLida
		// Gravação do Log Pai
		F914GrvLog('1',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg,'REDE',nQtdReg,nQtdNProc,cStatus,,,,cCodRede,cCodUser,nQtdLida,nLinTotal,nQtdAlt)
		
		// Guarda Log temporário
		F914LogFVR( FVR->(Recno()), nQtdAlt)
		
		//Copio o arquivo para o folder correspondente
		If lErro
			_CopyFile( aFolderC[01][02] + '\' + aRede[nX][01], aFolderC[01][04] + '\' + aRede[nX][01] )
		Else
			_CopyFile( aFolderC[01][02] + '\' + aRede[nX][01], aFolderC[01][03] + '\' + aRede[nX][01] )
		EndIf
		
		FERASE( aFolderC[01][02] + '\' + aRede[nX][01] )
		
		nQtdReg := 0
		
	Next nX
EndIf

//------------------------------------------------
// Processamento dos arquivos SOFTWARE EXPRESS
//------------------------------------------------
If !Empty( aSofEx ) .And. aExistFld[4]
	If !lAutomato
		oProcess:IncRegua1( STR0021 ) //"Processando arquivos do layout Software Express"
		
		oProcess:SetRegua2( Len( aSofEx ) )
	EndIf
	
	aBanco 	:= {}
	
	For nX := 1 To Len( aSofEx )
		
		cTime		:= Time()
		nQtdReg		:= 0
		nQtdNProc	:= 0
		nQtdFilOk	:= 0
		nQtdLida	:= 0
		nLinTotal	:= 0
		nQtdImp   	:= 0
		nQtdAlt		:= 0
		dDataIni 	:= dDataBase
		cHoraIni 	:= SubStr( cTime, 01, 08 )
		cStatus		:= ""
		cNomArq 	:= ""
		cCodEstab 	:= ""
		cNuComp 	:= ""
		cIdProc 	:= ""
		aArqLog 	:= {}
		aCodEst 	:= {}
		cLinLog 	:= ""
		cDescLeg 	:= ""
		lCarEsp 	:= .F.
		lNsutef     := .F.
		lNuComp		:= .F.
		
		If !lAutomato
			oProcess:IncRegua2( STR0018 + aSofEx[nX][01] ) //"Processando arquivo: "
		EndIf
		
		DbSelectArea("FVR")
		DbSetOrder(2) //FVR_NOMARQ+DTOS(FVR_DTPROC)+FVR_HRPROC
		
		cIdProc   := GetSxeNum("FVR","FVR_IDPROC")
		cCodSOFEX := aFolderD[01][05]
		cNomArq   := aSofEx[nX][01]
		
		If FVR->(DbSeek(SubStr(aSofEx[nX][01],1,__nTmNomAr)))
			lErro    := .T.
			cStatus	 := "1" // 1=Arquivo já importado
			cDescLeg := STR0027
		Else
			
			lErro := !A910VldArq( aFolderD[01][02] + '\' + aSofEx[nX][01], .F., @nQtdReg, @nQtdNProc, @nQtdFilOk, cCodSOFEX, cNomArq, @nQtdLida, @nLinTotal, @nQtdImp, @nQtdAlt, lAutomato, lOpt, @cDescLeg )
			
				If ( nQtdReg > 0 ) .And. nQtdNProc == 0 // Se não houve falhas, importado com sucesso
					cStatus	 := "0" // 0=Importado com sucesso
					cDescLeg := STR0026
				
				ElseIf ( nQtdReg > 0 ) .And. nQtdNProc > 0 //Se existir algum registro não processado
					cStatus	 := "4" // 4=Importado parcialmente
					cDescLeg := STR0030	

				ElseIf nQtdReg == 0 .And. nQtdFilOk == 0 .And. nQtdImp == 0
					lErro := .T.
					cStatus  := "6" // 6=Arquivo não Importado 
					
					If nQtdNProc == 0
						cDescLeg := STR0049 + STR0036 + STR0059 // Verifique o parametro | MV_EMPTEF'
					EndIf
														
				ElseIf nQtdReg == 0 .And. nQtdNProc > 0 .And. nQtdFilOk == 0 .And. nQtdImp > 0 // Arquivo já importado
					lErro := .T.
					cStatus	:= "1" // 1=Arquivo já importado
					cDescLeg := STR0027
				
				ElseIf nQtdReg == 0 .And. nQtdNProc > 0 .And. nQtdFilOk > 0
					lErro := .T.
					cStatus	:= "6" // 6="Arquivo não importado"

					If Empty(cDescLeg)
						cDescLeg := STR0049  //"Arquivo não importado"
					EndIf
				EndIf

		EndIf

		if nQtdAlt > 0
			nQtdReg -= nQtdAlt
		EndIf
		
		// Gravação do Log Pai
		F914GrvLog('1',cIdProc,cLinLog,cNomArq,dDataIni,cHoraIni,cCodEstab,cNuComp,cDescLeg,,nQtdReg,nQtdNProc,cStatus,,,,cCodSOFEX,cCodUser,nQtdLida,nLinTotal,nQtdAlt)
		
		// Guarda Log temporário
		F914LogFVR( FVR->(Recno()),nQtdAlt)
		
		//Copio o arquivo para o folder correspondente
		If lErro
			_CopyFile( aFolderD[01][02] + '\' + aSofEx[nX][01], aFolderD[01][04] + '\' + aSofEx[nX][01] )
		Else
			_CopyFile( aFolderD[01][02] + '\' + aSofEx[nX][01], aFolderD[01][03] + '\' + aSofEx[nX][01] )
		EndIf
		
		FERASE( aFolderD[01][02] + '\' + aSofEx[nX][01] )
		
		nQtdReg := 0
		
	Next nX
EndIf


Return

//--------------------------------------------------------------------------
/*{Protheus.doc} Fa914ChAll()
Marca/Desmarca todos

@author Pedro Pereira Lima
@since 20/12/2017
@version 12.1.17
*/
//--------------------------------------------------------------------------
Static Function Fa914ChAll( oCheckA As Object, oCheckB As Object, oCheckC As Object, oCheckD As Object, oCheckZ As Object )

If lCheckZ
	If lWhenA
		lCheckA := .T.
	EndIf
	
	If lWhenB
		lCheckB := .T.
	EndIf
	
	If lWhenC
		lCheckC := .T.
	EndIf
	
	If lWhenD
		lCheckD := .T.
	EndIf
	
	lCheckZ := .T.
Else
	If lWhenA
		lCheckA := .F.
	EndIf
	
	If lWhenB
		lCheckB := .F.
	EndIf
	
	If lWhenC
		lCheckC := .F.
	EndIf
	
	If lWhenD
		lCheckD := .F.
	EndIf
	
	lCheckZ := .F.
EndIf

oCheckA:CtrlRefresh()
oCheckB:CtrlRefresh()
oCheckC:CtrlRefresh()
oCheckD:CtrlRefresh()

oCheckA:SetFocus()
oCheckB:SetFocus()
oCheckC:SetFocus()
oCheckD:SetFocus()

oCheckZ:SetFocus()


Return

//--------------------------------------------------------------------------
/*{Protheus.doc} Fa914Focus()
Ajusto o foco dos checkboxes para habilitar/desabilitar o botão "Próximo"

@author Pedro Pereira Lima
@since 09/01/2018
@version 12.1.17
*/
//--------------------------------------------------------------------------
Static Function Fa914Focus( oCheckX As Object, oCheckZ As Object )

oCheckZ:SetFocus()
oCheckX:SetFocus()

Return

//--------------------------------------------------------------------------
/*{Protheus.doc} Fa914Hash
Carrega as filiais dos parametro MV_EMPTEF/MV_EMPTAME/MV_EMPTCIE/MV_EMPTRED
nos HashTables correspondentes

@author Pedro Pereira Lima
@since 23/05/2018
@version 12.1.17
*/
//--------------------------------------------------------------------------
Static Function Fa914Hash()

Local aArea		As Array
Local cFilTef	As Character
Local cFilAme	As Character
Local cFilCie	As Character
Local cFilRed	As Character


aArea		:= GetArea() //Variavel que armazenara WorkArea ativa
cFilTef		:= ''        //Variavel que armazenara o Filtro da SX6
cFilAme		:= ''        //Variavel que armazenara o Filtro da SX6
cFilCie		:= ''        //Variavel que armazenara o Filtro da SX6
cFilRed		:= ''        //Variavel que armazenara o Filtro da SX6

__oHashTef := LJCHashTable():New()
__oHashAme := LJCHashTable():New()
__oHashCie := LJCHashTable():New()
__oHashRed := LJCHashTable():New()

DbSelectArea("SX6")

cFilTef := "X6_VAR = 'MV_EMPTEF '"
cFilAme := "X6_VAR = 'MV_EMPTAME'"
cFilCie := "X6_VAR = 'MV_EMPTCIE'"
cFilRed := "X6_VAR = 'MV_EMPTRED'"

//-------------------------------------------------------------------------------------------------------
//Alimento o HashTable com os dados dos parâmetros da Software Express
//-------------------------------------------------------------------------------------------------------
SX6->( DbSetFilter( { || &cFilTef }, cFilTef ) )
SX6->( DbGoTop() )

While !SX6->( Eof() )
	
	__oHashTef:Add( UPPER( ALLTRIM( SuperGetMV("MV_EMPTEF",.F., "", SX6->X6_FIL) ) ), SX6->X6_FIL )
	
	SX6->( DbSkip() )
EndDo

SX6->( DbClearFilter() )

//-------------------------------------------------------------------------------------------------------
//Alimento o HashTable com os dados dos parâmetros da Amex
//-------------------------------------------------------------------------------------------------------
SX6->( DbSetFilter( { || &cFilAme }, cFilAme ) )
SX6->( DbGoTop() )

While !SX6->( Eof() )
		
	__oHashAme:Add( UPPER( ALLTRIM( SuperGetMV("MV_EMPTAME",.F., "", SX6->X6_FIL) ) ), SX6->X6_FIL )
	
	SX6->( DbSkip() )
EndDo

SX6->( DbClearFilter() )

//-------------------------------------------------------------------------------------------------------
//Alimento o HashTable com os dados dos parâmetros da Cielo
//-------------------------------------------------------------------------------------------------------
SX6->( DbSetFilter( { || &cFilCie }, cFilCie ) )
SX6->( DbGoTop() )

While !SX6->( Eof() )
	
	__oHashCie:Add( UPPER( ALLTRIM( SuperGetMV("MV_EMPTCIE",.F., "", SX6->X6_FIL) ) ), SX6->X6_FIL )
	
	SX6->( DbSkip() )
EndDo

SX6->( DbClearFilter() )

//-------------------------------------------------------------------------------------------------------
//Alimento o HashTable com os dados dos parâmetros da Rede
//-------------------------------------------------------------------------------------------------------
SX6->( DbSetFilter( { || &cFilRed }, cFilRed ) )
SX6->( DbGoTop() )

While !SX6->( Eof() )
	
	__oHashRed:Add( UPPER( ALLTRIM( SuperGetMV("MV_EMPTRED",.F., "", SX6->X6_FIL) ) ), SX6->X6_FIL )
	
	SX6->( DbSkip() )
EndDo

SX6->( DbClearFilter() )

RestArea(aArea)

Return

//--------------------------------------------------------------------------
/*{Protheus.doc} Fa914MsFil
Pega filial do parametro MV_EMPTEF/MV_EMPTAME/MV_EMPTCIE/MV_EMPTRED
mediante o código do estabelecimento recebido no arquivo das operadoras

@author Pedro Pereira Lima
@since 23/05/2018
@version 12.1.17
*/
//--------------------------------------------------------------------------
Function Fa914MsFil( cFifCodLoj As Character, cRede As Character ) As Character
Local aArea	    	As Array
Local cRetorno		As Character
Local nTAmCodFil	As Numeric

aArea	    := GetArea()
cRetorno	:= " "						//Variavel que armazenara o retorno da função
nTAmCodFil	:= TamSX3("FIF_CODFIL")[1]

If Upper( cRede ) == "SOFEX"
	
	If __oHashTef:Count() > 0
		If __oHashTef:Contains( UPPER( ALLTRIM( cFifCodLoj ) ) )
			cRetorno := __oHashTef:ElementKey( UPPER( ALLTRIM( cFifCodLoj ) ) )
		Else
			cRetorno := Space( nTAmCodFil )
		EndIf
	Else
		cRetorno := Space( nTAmCodFil )
	EndIf
	
ElseIf Upper( cRede ) == "AMEX"
	
	If __oHashAme:Count() > 0
		If __oHashAme:Contains( UPPER( ALLTRIM( cFifCodLoj ) ) )
			cRetorno := __oHashAme:ElementKey( UPPER( ALLTRIM( cFifCodLoj ) ) )
		Else
			cRetorno := Space( nTAmCodFil )
		EndIf
	Else
		cRetorno := Space( nTAmCodFil )
	EndIf
	
ElseIf Upper( cRede ) == "CIELO"
	
	If __oHashCie:Count() > 0
		If __oHashCie:Contains( UPPER( ALLTRIM( cFifCodLoj ) ) )
			cRetorno := __oHashCie:ElementKey( UPPER( ALLTRIM( cFifCodLoj ) ) )
		Else
			cRetorno := Space( nTAmCodFil )
		EndIf
	Else
		cRetorno := Space( nTAmCodFil )
	EndIf
	
ElseIf Upper( cRede ) == "REDE"
	
	If __oHashRed:Count() > 0
		If __oHashRed:Contains( UPPER( ALLTRIM( cFifCodLoj ) ) )
			cRetorno := __oHashRed:ElementKey( UPPER( ALLTRIM( cFifCodLoj ) ) )
		Else
			cRetorno := Space( nTAmCodFil )
		EndIf
	Else
		cRetorno := Space( nTAmCodFil )
	EndIf
	
EndIf

RestArea(aArea)

Return cRetorno

//--------------------------------------------------------------------------
/*{Protheus.doc} Fa914Fil
Função para armazenar filiais que serão consideradas na importação

@author Marcelo Ferreira
@since 23/05/2018
@version 12.1.17
*/
//--------------------------------------------------------------------------
Static Function Fa914Fil()

Local aArea		As Array
Local cAliasQry	As Character
Local cQuery	As Character

aArea		:= GetArea()
cAliasQry	:= GetNextAlias()
cQuery		:= ""

__oHshCFil := LJCHashTable():New()

cQuery := " SELECT R_E_C_N_O_ RECID FROM " + RetSqlName("FVZ") + " WHERE FVZ_FILIAL = '" + xFilial("FVZ") + "' AND D_E_L_E_T_ = ' ' "
dbUseArea( .T., "TOPCONN", TcGenQry(,,cQuery), cAliasQry )

(cAliasQry)->( Dbgotop() )
If (cAliasQry)->(!Eof())
	
	While !(cAliasQry)->( Eof() )
		FVZ->( dbGoTo( (cAliasQry)->RECID ) )
		__oHshCFil:Add(UPPER(ALLTRIM(FVZ->FVZ_FILCON)))
		(cAliasQry)->( dbSkip() )
	EndDo
	
EndIf
(cAliasQry)->( dbCloseArea() )

RestArea(aArea)

Return

//--------------------------------------------------------------------------
/*{Protheus.doc} Fa914ChkFil
Função para verificar se filiais serão consideradas na importação

@author Marcelo Ferreira
@since 23/05/2018
@version 12.1.17
*/
//--------------------------------------------------------------------------
Static Function Fa914ChkFil( cCodFil As Character ) As Logical

Local lRet	As Logical

lRet := .T.

If __oHshCFil:Count() > 0
	If !( __oHshCFil:Contains(UPPER(ALLTRIM(cCodFil))) ) // Se não estiver cadastrado FVZ, não importa
		lRet := .F.
	EndIf
EndIf

Return lRet


//--------------------------------------------------------------------------
/*{Protheus.doc} Fa914ChkFil
Função para validar importação

@author Marcelo Ferreira
@since 23/05/2018
@version 12.1.17
*/
//--------------------------------------------------------------------------
Function Fa914VldImp(cCodEst As Character, cRede As Character, cCodFil As Character ) As Logical

Local lRet As Logical

lRet := .T.

cCodFil	:= Fa914MsFil( cCodEst, cRede ) // Resgata codigo da filial através do parametro da rede - SX6
lRet 	:= ( !Empty(cCodFil) .And. Fa914ChkFil(cCodFil) )// Valida se filial poderá ser importada - FVZ

Return lRet


//--------------------------------------------------------------------------
/*{Protheus.doc} F914LogFVR
Guarda o log em array para exibir registros efetuados na transação

@author Marcelo Ferreira
@since 05/06/2018
@version 12.1.17
*/
//--------------------------------------------------------------------------
Static Function F914LogFVR(nReg as Numeric, nQtdAlt as Numeric)
Local nY    As Numeric
Local aArea As Array
Local aAux  As Array
Local nZ    As Numeric

Default nQtdAlt := 0

aArea	:= GetArea()
aAux  	:= {}
nZ      := 0

FVR->( dbGoTo( nReg ) )
For nY := 1 to Len(aHdrFVR)
	If !lQtdAlt .and. aHdrFVR[nY][2] == 'FVR_QTDALT'
		aAdd(aAux, nQtdAlt)
	Else
		aAdd(aAux, FVR->&(aHdrFVR[nY][2]))
	EndIf
Next nY

aAdd(aLogFVR, aClone(aAux))

RestArea(aArea)

Return
//--------------------------------------------------------------------------
/*{Protheus.doc} F914GrvLog
Gravação dos detalhes dos Log´s

@author Jose Gavetti
@since 05/04/2019
@version 12.1.23
*/
//--------------------------------------------------------------------------
Function F914GrvLog(cPai as Character,cIdProc as Character,cLinArq As Character, cNomArq As Character,dDtProc As Date,cHrProc As Character,cCodEst As Character,cNuComp As Character,cMotivo As Character,;
cNomOper As Character,nQtdReg As Numeric,nQtdNProc As Numeric,cStatus As Character,aCodEst As Array, lValidaFil As Logical, cCodfil As Character, cCodAdm As Character,cCodUser As Character,nQtdLida As Numeric,;
nLinTotal As Numeric, nQtdAlt As Numeric )

Local lAppend 	As Logical
Local nFil 		As Numeric
Local cNomFil 	As Character
Local cFilImp 	As Character
Local cParam  	As Character
Local lAPI		As Logical 
Local lQtdAlt   As Logical

Default cIdProc    := ""
Default cLinArq    := ""
Default cNomArq    := ""
Default dDtProc    := dDataBase
Default cHrProc    := ""
Default cCodEst    := ""
Default cNuComp    := ""
Default cMotivo    := ""
Default cNomOper   := ""
Default nQtdReg    := 0
Default nQtdNProc  := 0
Default cStatus    := ""
Default aCodEst    := {}
Default lValidaFil := .F.
Default cCodfil    := ""
Default cCodAdm    := ""
Default cCodUser   := ""
Default nQtdLida   := 0
Default nLinTotal  := 0
Default nQtdAlt    := 0
Default lQtdAlt	   := .F.


lAppend := .T.
nFil    := 0
cNomFil := ""
cFilImp := ""
cParam  := ""
lAPI    := (cNomOper == "FINA914a")
lQtdAlt	:= (nQtdAlt > 0)

If !lAPI
	If Upper(cNomOper) == "AMEX"
		cParam := STR0060
	ElseIf Upper(cNomOper) == "CIELO"
		cParam := STR0061
	ElseIf Upper(cNomOper) == "REDE"
		cParam := STR0062
	Else
		cParam := STR0059
	EndIf
EndIf

If cPai == '1'

	If !FVR->(DbSeek(xFilial('FVR')+cIdProc)) 
		If RecLock('FVR',.T.)
			ConfirmSx8(cIdProc)
			FVR->FVR_FILIAL := xFilial( 'FVR' )
			FVR->FVR_DTPROC := dDtProc
			FVR->FVR_HRPROC := cHrProc
			FVR->FVR_NOMARQ := cNomArq
			FVR->FVR_QTDPRO := nQtdReg
			FVR->FVR_QTDINC := nQtdNProc
			FVR->FVR_STATUS	:= cStatus
			FVR->FVR_DESCLE	:= cMotivo
			FVR->FVR_IDPROC	:= cIdProc
			FVR->FVR_CODADM := cCodAdm
			FVR->FVR_CODUSU := cCodUser
			FVR->FVR_QTDLIN := nQtdLida
			FVR->FVR_QTDTOT := nLinTotal
			If __lAPixTpd
				FVR->FVR_MODPAG := Iif(lAPI, '2', '1')
			Endif
			If lQtdAlt
				FVR->FVR_QTDALT := nQtdAlt
			EndIf
			FVR->(MsUnlock())
		Else
			RollbackSx8()
		Endif
	Else
		RecLock('FVR',.F.)
		FVR->FVR_QTDINC := nQtdNProc
		FVR->FVR_STATUS	:= cStatus
		FVR->FVR_DESCLE	:= cMotivo
		FVR->FVR_CODUSU := cCodUser
		FVR->FVR_QTDLIN := nQtdLida
		FVR->FVR_QTDTOT := nLinTotal
		If lQtdAlt
			FVR->FVR_QTDALT := nQtdAlt
		EndIf
		MsUnlock()
	EndIf
Else
	DbSelectArea('FV3')
	DbSetOrder(2)
	
	If lValidaFil
		nFil := AScan(aCodEst, { |x| x[1] == cCodEst })
		
		cNomFil := FWFilialName(SM0->M0_CODIGO,cCodfil,1)
		cFilImp := cCodfil + '\' + cNomFil
		
		If nFil > 0
			aCodEst[nFil][2]++
			
			Dbgoto(aCodEst[nFil][3])
			RecLock( 'FV3', .F. )
			If Alltrim(cCodfil) == ""
				FV3->FV3_MOTIVO := STR0055 +cParam+ STR0057 +Alltrim(Str(aCodEst[nFil][2]))+")"
			Else
				FV3->FV3_MOTIVO := STR0056 +cFilImp+ STR0058 + STR0057 +Alltrim(Str(aCodEst[nFil][2]))+")"
			Endif
			FV3->( MsUnlock() )
			
			lAppend := .F.
		Else
			lAppend := .T.
			If Alltrim(cCodfil) == ""
				cMotivo := STR0055 + cParam
			Else
				cMotivo := STR0056 + cFilImp + STR0058
			Endif
		EndIf
	EndIf
	
	If lAppend
		If !Empty(cIdProc)
			// Grava Detalhes do log de importação - FV3
			DbSetOrder(1)
			// Há cenários em que a Cielo envia mesma linha como ajuste e fazemos leitura para gravar a venda, qdo o arquivo é reprocessado da erro pois acha o arquivo nas duas situações.
			If FV3->(DbSeek(xFilial('FV3')+cIdProc+cLinArq))  
				If !Alltrim(cMotivo) $ Alltrim(FV3_MOTIVO) 
					RecLock('FV3',.F.)
					FV3->FV3_MOTIVO := Alltrim(FV3_MOTIVO) + "/" + cMotivo
					FV3->( MsUnlock() )
				EndIf
			Else
				If RecLock('FV3',.T.)
					ConfirmSx8(cIdProc)
					FV3->FV3_FILIAL := xFilial( 'FV3' )
					FV3->FV3_IDPROC := cIdProc
					FV3->FV3_LINARQ := cLinArq
					FV3->FV3_NOMARQ := cNomArq
					FV3->FV3_DTPROC := dDtProc
					FV3->FV3_HRPROC := cHrProc
					FV3->FV3_NUCOMP := cNuComp
					FV3->FV3_CODEST := cCodEst
					FV3->FV3_MOTIVO := cMotivo
					FV3->( MsUnlock() )
				Else
					RollbackSx8()
				Endif
			EndIf 
			If lValidaFil  .And. nFil = 0
				aAdd(aCodEst,{cCodEst,1,FV3->(Recno())})
			EndIf
		Endif
	Endif
Endif

Return


/*{Protheus.doc} TrataParc
Função para retornar a parcela de acordo com o padrão definido no parâmetro MV_1DUP

@param cParcela, Parcela a ser tratada de acordo com o padrão configurado
@param cTipoParc, Tipo de tratamento da parcela, obtido através do parâmetro MV_1DUP
@return cRet, Retorna a parcela de acordo com o padrão configurado no parâmetro

@author Pedro Alencar
@since 21/06/2018
@version P12.1.17
*/
Static Function TrataParc( cParcela As Char, cTipoParc As Char ) As Char
Local cRet As Char
Default cParcela := ""
Default cTipoParc := SuperGetMV( "MV_1DUP", .F., "1" )

//Se estiver no padrão de sequêncial alfa-numérico, então converte a parcela informada (pois nos padrões Amex, Rede e Cielo, vem no padrão numérico), do contrário, retorna a mesma parcela informada
If !Empty( cParcela ) .And. Left( cTipoParc, 1 ) == "A" .And. Val(cParcela) > 0
	cRet := Chr( 64 + Val(cParcela) )
Else
	cRet := cParcela
Endif
Return cRet

/*{Protheus.doc} TrataParc
Função para atualizar os valores para preenchimento do cabeçalho do log.

@Param - lErro - Recebe o flag e preenche conforme as definições
@Param - cStatus as Character - Recebe e preenche o Status conforme as definições
@Param - cDescLeg as Character - Recebe e preenche a descrição da legenda conforme as definições
@Param - nQtdReg as Numeric - Quantidade de linhas processados que viram FIF
@Param - nQtdNProc as Numeric - Quantidade de linhas não processados
@Param - nLinha as Numeric - Quantidade total de linhas no arquivo
@Param - nQtdLida as Numeric - Quantidade de linhas lidas
@Param - nQdtImp as Numeric - Quantidade de linhas que já existem na FIF e não foram atualizadas
@Param - nQtdSerasa as Numeric - Quantidade de linhas que possuem registros referentes ao SERASA
@Param - nQtdAlt as Numeric - Quantidad de registros alterados. 

@author Fernando Navarro
@since 26/04/2019
@version P12.1.23
*/

Function A914Status(lErro as Logical,cStatus as Character,cDescLeg as Character,nQtdReg as Numeric,nQtdNProc as Numeric, nLinha as Numeric,;
nQtdLida as Numeric,nQdtImp as Numeric,nQtdSerasa as Numeric, nQtdAlt as Numeric)

If nQtdSerasa > 0 .and. nQtdSerasa == nQtdNProc .and. nQtdNProc + nQtdLida == nLinha
	cStatus	 := "5" // 5="Arquivo Inconsistente Serasa"
	cDescLeg := STR0037 // "Arquivo Inconsistente | SERASA"
	lErro    := .T.
	
ElseIf nQtdReg + nQtdAlt == 0 .and. nQdtImp > 0 .and. nQtdLida + nQdtImp  = nLinha
	lErro    := .T.
	cStatus	 := "1" // 1=Arquivo já importado
	cDescLeg := STR0027  // "Arquivo já importado"
	
ElseIf (nQtdReg + nQtdAlt) == 0 .and. nQtdLida + nQtdNProc = nLinha
	lErro    := .T.
	cStatus	 := "6" // 6="Arquivo Inconsistente"
	cDescLeg :=  STR0049  //"Arquivo não importado"
	
Elseif (nQtdReg+nQtdAlt > 0 .And. nQtdNProc > 0)
	cStatus	 := "4" // 4=Importado parcialmente
	cDescLeg := STR0030 // "Importado parcialmente. "
	
Elseif nQtdLida = nLinha .and. nQtdReg > 0 .and. nQdtImp == 0
	cStatus	 := "0" // 0=Importado com sucesso
	cDescLeg := STR0026  // "Importado com sucesso"
Else
	lErro    := .T.
	cStatus	 := "6" // 6="Arquivo Inconsistente"
	cDescLeg :=  STR0049  //"Arquivo não importado"
EndIf

Return

//-------------------------------------------------------------------
/*/{Protheus.doc} FINCARCESP
Função para validar se os campos NSUTEF e NUCOMP possuem caracteres
especiais. 
@type Function
@author Jose Gavetti
@since 19/07/20201
@version 11.80
/*/
//-------------------------------------------------------------------
Function FINCARCESP( cNsutef As Character,cDoctef As Character,lNsuTef As Logical,lNuComp As Logical) As Logical

Local nI 		 As Numeric
Local nTamNSUTEF As Numeric
Local nTamNUCOMP As Numeric
Local lRet 		 As Logical 

Default cNsutef := ""
Default cDoctef	:= ""
Default lNsuTef := .F.
Default lNuComp := .F.

lRet 	   := .F.
nTamNSUTEF := TAMSX3("FIF_NSUTEF")[1]
nTamNUCOMP := TAMSX3("FIF_NUCOMP")[1]

// Validação de caracteres especiais campo FIF_NSUTEF
For nI:= 1 to nTamNSUTEF
	If (ASC(Substr(cNsuTef,nI,1)) >= 33 .And. ASC(Substr(cNsuTef,nI,1)) <= 47) .Or.;
				(ASC(Substr(cNsuTef,nI,1)) >= 58 .And. ASC(Substr(cNsuTef,nI,1)) <= 64) .Or.;
				(ASC(Substr(cNsuTef,nI,1)) >= 91 .And. ASC(Substr(cNsuTef,nI,1)) <= 96) .Or.;
				(ASC(Substr(cNsuTef,nI,1)) >= 123 .And. ASC(Substr(cNsuTef,nI,1)) <= 126)
		lNsuTef := .T.
		lRet 	:= .T.
		Exit
	EndIf
Next nI 

nI := 0

If !lRet // Validação de caracteres especiais campo FIF_NUCOMP caso não tenha encontrado no campo FIF_NSUTEF
	For nI:= 1 to nTamNUCOMP
		If (ASC(Substr(cDoctef,nI,1)) >= 33 .And. ASC(Substr(cDoctef,nI,1)) <= 47) .Or.;
					(ASC(Substr(cDoctef,nI,1)) >= 58 .And. ASC(Substr(cDoctef,nI,1)) <= 64) .Or.;
					(ASC(Substr(cDoctef,nI,1)) >= 91 .And. ASC(Substr(cDoctef,nI,1)) <= 96) .Or.;
					(ASC(Substr(cDoctef,nI,1)) >= 123 .And. ASC(Substr(cDoctef,nI,1)) <= 126)
			lNuComp := .T.
			lRet 	:= .T.
			Exit
		EndIf
	Next nI 
Endif 	

Return lRet 
