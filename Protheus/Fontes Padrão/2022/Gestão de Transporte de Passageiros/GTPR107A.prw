#Include 'Protheus.ch'
#Include 'FWMVCDef.ch'
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "RPTDEF.CH"
#INCLUDE 'gtpa107.CH'

//------------------------------------------------------------------------------
/*/{Protheus.doc} GTPR107A

@type Function
@author 
@since 02/10/2020
@version 1.0
@param , character, (Descrição do parâmetro)
@return , return_description
@example
(examples)
@see (links_or_references)
/*/
//------------------------------------------------------------------------------
Function GTPR107A()
Local aDados 		:= {}

If GQG->(Recno()) > 0
	cCodCidade:= Posicione('GI6',1,xFilial('GI6') +  GQG->GQG_AGENCI,"GI6_LOCALI")
	AADD(aDados, Posicione('GYG',1,xFilial('GYG') + GQG->GQG_COLABO,"GYG_NOME")	            ) // Nome do Colaborador
	AADD(aDados, FWEmpName(cEmpAnt)                                                         ) // Nome da Empresa
	AADD(aDados, POSICIONE('GI1',1,xFilial('GI1') + cCodCidade,'GI1_DESCRI')                ) // Nome da Cidade
	AADD(aDados, GQG->GQG_AGENCI                                                            ) // Código da Agência
	AADD(aDados, Posicione('GI6',1,xFilial('GI6') + GQG->GQG_AGENCI,"GI6_DESCRI")	        ) // Descrição da Agência
	AADD(aDados, POSICIONE('GYA',1,XFILIAL('GYA')+GQG->GQG_TIPO,'GYA_DESCRI')	            ) // Tipo de Documento
	AADD(aDados, IIF(GQG->GQG_COMPLE != '2', 'PE(Passagem Estrada)', 'PA(Passagem Agencia)')) // Complemento - 1=PE(Passagem Estrada); 2=PA(Passagem Agencia)
	AADD(aDados, IIF(GQG->GQG_TIPPAS != '2', 'Motorista', 'Cobrador')                       ) // Tipo de Passagem - 1=Motorista;2=Cobrador
	AADD(aDados, GQG->GQG_SERIE	 	                                                        ) // Série
	AADD(aDados, GQG->GQG_SUBSER	                                                        ) // Subsérie
	AADD(aDados, GQG->GQG_NUMINI 	                                                        ) // Número Inicial
	AADD(aDados, GQG->GQG_NUMFIM 	                                                        ) // Número Final
	AADD(aDados, GQG->GQG_QUANT	                                                            ) // Quantidade de Documentos
	AADD(aDados, GQG->GQG_LOTE		                                                        ) // Lote do Protocolo
EndIf

If Len(aDados) > 0
	Processa( {|| StartPrint(aDados) }, STR0049, STR0050,.F.)//Aguarde... Imprimindo Protocolo Controle de Documentos...
EndIf
	
Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} StartPrint
Função para criar o protocolo

@sample	StartPrint(aDados)
@param		aDados - Dados para geração do formulario
@return   	Nenhum

@author		Inovação
@since		07/03/2017
@version	P12
/*/
//-------------------------------------------------------------------                            
Static Function StartPrint(aDados)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Declaracao de variaveis                                      ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local oFnt14  := TFont():New( "Times New Roman" ,,14,,.F.,,,,,.F. )
Local oFnt14B := TFont():New( "Times New Roman" ,,14,,.T.,,,,,.F. )
Local oFnt16  := TFont():New( "Times New Roman" ,,16,,.F.,,,,,.F. )
 
Local lAdjustToLegacy := .T.
Local lDisableSetup := .T.

Local cFilePrint,oPrn
Local nLinIni	:= 0200
Local nColIni	:= 0050
Local nColFim	:= 2300

cFilePrint := "Protocolo_Controle_Documentos"
oPrn := FWMSPrinter():New(cFilePrint,IMP_PDF, lAdjustToLegacy, ,lDisableSetup,,,,,.F.,,.T.,2) 
oPrn:SetPortrait()
oPrn:SetPaperSize(DMPAPER_A4) 
oPrn:SetMargin(05,05,05,05) // nEsquerda, nSuperior, nDireita, nInferior 
oPrn:cPathPDF := AllTrim(GetTempPath())
oPrn:lPDFasPNG := .F. 

oPrn:StartPage()

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//?Cabecalho do relatorio            ?
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

oPrn:Line (nLinIni+010,nColIni,nLinIni+010,nColFim)

oPrn:SayBitmap(nLinIni+050,nColIni,"lgrlt1.bmp",0400,0125)    // LOGO Tem que estar abaixo do RootPath 
oPrn:Say(nLinini+100,nColIni+450,STR0051,oFnt16)//"Protocolo de Envio de Documentos"
oPrn:Say(nLinIni+200,nColIni+450,STR0052 + aDados[14] + " " + DToC( Date() ) + "  " + Time()  ,oFnt16) // Número Protocolo

oPrn:Line(nLinIni+250,nColIni,nLinIni+250,nColFim)

nLinIni += 100

oPrn:Say(nLinIni+350,nColIni+0200,STR0053+ AllTrim( aDados[5] ) +STR0054,oFnt16) //Nome Resposavel (Agencia ou Colaborador)
oPrn:Say(nLinIni+400,nColIni+0200,STR0055,oFnt16)

nLinIni += 175

oPrn:Say(nLinini+450,nColIni+0200, STR0056   , oFnt14B) 
oPrn:Say(nLinini+450,nColIni+0500, aDados[3]     , oFnt14) // Localidade

oPrn:Say(nLinini+500,nColIni+0200, STR0057      , oFnt14B) 
oPrn:Say(nLinini+500,nColIni+0500, aDados[4] + STR0083 + aDados[5]     , oFnt14) // Código da Agência - Nome da Agência

oPrn:Say(nLinini+550,nColIni+0200, STR0058 , oFnt14B) 
oPrn:Say(nLinini+550,nColIni+0500, aDados[6]		   , oFnt14) // Tipo de Documento

oPrn:Say(nLinini+600,nColIni+0200,	STR0059   , oFnt14B)  
oPrn:Say(nLinini+600,nColIni+0500, aDados[7]      , oFnt14) // Complemento
 
oPrn:Say(nLinini+650,nColIni+0200,	STR0060 , oFnt14B) 
oPrn:Say(nLinini+650,nColIni+0500, aDados[8]      , oFnt14) // Tipo de Passagem

oPrn:Say(nLinini+700,nColIni+0200,	STR0061         , oFnt14B) 
oPrn:Say(nLinini+700,nColIni+0500, aDados[9]      , oFnt14) // Série

oPrn:Say(nLinini+750,nColIni+0200,	STR0062        , oFnt14B) 
oPrn:Say(nLinini+750,nColIni+0500, aDados[10]     , oFnt14) // Subsérie

oPrn:Say(nLinini+800,nColIni+0200,	STR0063, oFnt14B) 
oPrn:Say(nLinini+800,nColIni+0500, aDados[11]     , oFnt14) // Número Inicial

oPrn:Say(nLinini+850,nColIni+0200,	STR0064  , oFnt14B) 
oPrn:Say(nLinini+850,nColIni+0500, aDados[12]     , oFnt14) // Número Final

oPrn:Say(nLinini+900,nColIni+0200,	STR0065    , oFnt14B) 
oPrn:Say(nLinini+900,nColIni+0500, cValToChar(aDados[13])     , oFnt14) // Quantidade

oPrn:Say(nLinini+1000,nColIni+0200,STR0066 + ; 
								   STR0067,oFnt14) //"Nessa data, por vossa solicitacao, prestamos os servicos relatorios aos itens abaixo"
oPrn:Say(nLinini+1050,nColIni+0200,STR0068+ aDados[2] +STR0069	,oFnt14) // NOME DA EMPRESSA

oPrn:Say(nLinini+1200,nColIni+0200,STR0070                               ,oFnt14B) //"Data"  
oPrn:Say(nLinini+1200,nColIni+0750,STR0071 + DTOC(dDatabase) + " " + Time()                  ,oFnt14B) //"Data de envio"

oPrn:Say(nLinini+1300,nColIni+0200,STR0072,oFnt14B) //"Assinatura"

oPrn:Say(nLinini+1400,nColIni+0350,STR0073,oFnt14B) //"DEVOLVER A PRIMEIRA VIA AO CONTROLE DE ARRECADAÇÃO: "                                                                                                                                                                                                                                                                                                                                                                                                                                                              

oPrn:EndPage()
oPrn:Preview()

Return       
