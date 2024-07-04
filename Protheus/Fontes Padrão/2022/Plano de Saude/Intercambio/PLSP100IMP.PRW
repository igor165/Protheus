#include "fileIO.ch"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"
#include "PLSMGER.CH"
#include "COLORS.CH"
#include "TCBROWSE.CH"
#include "JPEG.CH"



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSP100IMP
Importação PTU A100 XML

@author    Totvres
@since     02/09/2019
/*/
//------------------------------------------------------------------------------------------
Function PLSP100IMP()
local oBrowse as object

DbSelectArea("BX0")
BX0->(DbSetOrder(1))

oBrowse := FWMBrowse():New()
oBrowse:SetAlias("BX0")
oBrowse:SetDescription("Importação PTU A100 XML")

// Definiï¿½ï¿½o da legenda 
oBrowse:AddLegend( "BX0_STATUS <> '1'"   , "GREEN ",  "Aguardando Importação"  ) 
oBrowse:AddLegend( "BX0_STATUS == '1' "  , "RED"   ,  "Importado"  ) 


oBrowse:Activate()
return oBrowse


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSP100IMP
Importação PTU A100 XML MENUDEF

@author    Totvres
@since     02/09/2019
/*/
//------------------------------------------------------------------------------------------

Static Function MenuDef()
Local aRotina := {}

ADD OPTION aRotina Title 'Visualizar' Action 'VIEWDEF.PLSP100IMP' OPERATION 2 ACCESS 0
ADD OPTION aRotina Title 'Importar A100'    Action 'PLSPIMP100(3)' OPERATION 3 ACCESS 0
ADD OPTION aRotina Title 'Importar Manual'    Action 'PLSPIMP100(4)' OPERATION 3 ACCESS 0

Return aRotina


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSP100IMP
Importação PTU A100 XML MODELDEF

@author    Totvres
@since     02/09/2019
/*/
//------------------------------------------------------------------------------------------

Static Function ModelDef()

// Cria a estrutura a ser usada no Modelo de Dados
Local oStruBX0 := FWFormStruct( 1, 'BX0' ) 

// Modelo de dados que serï¿½ construï¿½do
Local oModel 

// Cria o objeto do Modelo de Dados
oModel := MPFormModel():New('PLSP100IMP' )

// Adiciona ao modelo um componente de formulï¿½rio
oModel:AddFields( 'BX0MASTER', /*cOwner*/, oStruBX0)

// Adiciona a descriï¿½ï¿½o do Modelo de Dados
oModel:SetDescription( 'Importação do PTU A100 XML' )

// Adiciona a descriï¿½ï¿½o do Componente do Modelo de Dados
oModel:GetModel( 'BX0MASTER' ):SetDescription( 'Importação do PTU A100 XML')

// Retorna o Modelo de dados

Return oModel


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSP100IMP
Importação PTU A100 XML VIEWDEF

@author    Totvres
@since     02/09/2019
/*/
//------------------------------------------------------------------------------------------

Static Function ViewDef()
// Cria um objeto de Modelo de dados baseado no ModelDef() do fonte informado
Local oModel := FWLoadModel( 'PLSP100IMP' )

// Cria a estrutura a ser usada na View
Local oStruBX0 := FWFormStruct( 2, 'BX0' )


// Interface de visualizaï¿½ï¿½o construï¿½da
Local oView // Cria o objeto de View
oView := FWFormView():New()

// Define qual o Modelo de dados serï¿½ utilizado na View
oView:SetModel( oModel )

// Adiciona no nosso View um controle do tipo formulï¿½rio // (antiga Enchoice)
oView:AddField( 'VIEW_BX0', oStruBX0, 'BX0MASTER' )

// Criar um "box" horizontal para receber algum elemento da view
oView:CreateHorizontalBox( 'TELA' , 100 )

// Relaciona o identificador (ID) da View com o "box" para exibiï¿½ï¿½o
oView:SetOwnerView( 'VIEW_BX0', 'TELA' )// Retorna o objeto de View criado
Return oView



//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSP100IMP
Importação PTU A100 XML

@author    Totvres
@since     08/03/2019
/*/
//------------------------------------------------------------------------------------------
Function PLSPIMP100(nOpc)
	Local cErro 	   := ""
	Local cAviso 	   := ""
	Local cPerg	       := "PLU100"	
	Local cArq 		   := ""	
	Local lArqOk       := .F.
	Local cCodLay      := ""	
	Local lVemWebServ  := .F.
	Local ARQUIVO_PTUA100 := "ptua100_imp.log"
	
	Private nTotInc    := 0
	Private nTot202    := 0
	Private nTotAlt    := 0
	Private nTotExc    := 0
	Private nTotRec	   := 0
	Private aCritica   := {}
	Private aCritGeral := {}
	Private cNomeArq    := ""
	Private cDirArq    := ""


	If nOpc == 4
		If !Pergunte(cPerg, (nOpc == 4))
			Return
		Endif
	else
		Pergunte(cPerg, (nOpc == 4))	
	Endif

    cCodLay   := mv_par01 //Layout   
	cArq      := If(nOpc==3,BX0->BX0_ARQUIV,mv_par02  )//Nome do Arquivo
	lVemWebServ := (nOpc == 3)
	cNomeArq  := AllTrim(SubStr(cArq, rAt("\", cArq) + 1, len(cArq) - rAt("\", cArq)))
	cDirArq   := AllTrim(SubStr(cArq, 1, rAt("\", cArq)))

	If BX0->BX0_STATUS == '1'  .and. lVemWebServ
		MsgInfo('Item já Importado!')
		Return
	endIf

	Do Case 
		Case Empty(cCodLay)
			MsgInfo('LayOut Inválido!')
			Return
		Case Empty(cArq)
			MsgInfo('Arquivo Inválido!')
			Return	
		OtherWise 

		valPathImp( @cErro) //Verifico se os diretï¿½rios existem e os crio se necessï¿½rio

		If !Empty(cErro)				
			MsgAlert(cErro)
			Return
		Else
			lArqOk :=  valXmlA100(cArq,,,lVemWebServ ) // Valido o arquivo selecionado com base no Schema
			If lArqOk
				PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] Inicio PLSP100IMP",ARQUIVO_PTUA100)
				Processa( {||PlProA100(cArq,lVemWebServ,nOpc) }, "Aguarde...", "Importando Arquivo ...",.F.)
				PlsLogFil("[" + DTOS(Date()) + " " + Time() + "] FIM PLSP100IMP",ARQUIVO_PTUA100)
			EndIf
		EndIf   		
	EndCase	

    //EndIF

Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} PLSP100IMP
Processa o arquivo PTU A100 XML

@author    PLS TEAM
@since     08/03/2019
/*/
//------------------------------------------------------------------------------------------
Static Function PlProA100(cArq,lVemWebServ,nOpc )
Local nTotReg			:= 0
Local nX				:= 0
Local nY				:= 0
Local nTot				:= 0
Local nTotOut			:= 0

Local cError			:= ""
Local cWarning			:= ""
Local cName				:= ''
Local cNameSpace		:= If(lVemWebServ,"_PTU_PTUA100_POS_UB","_PTUA100_POS_UB")
Local cPath 			:= "\PLSPTU\"
Local cNameArq			:= AllTrim(SubStr(cArq, rAt("\", cArq) + 1, len(cArq) - rAt("\", cArq)))
Local cArqTmp			:= ""
Local cCodUOrg  		:= "" //Cï¿½digo da Unimed origem do envio de arquivo
Local cCodUDes  		:= "" //Cï¿½digo da Unimed destino para envio de arquivo
Local cHash     		:= "" //Hash
Local aDados    		:= {}
Local cValue			:= ""
Local cText     		:= ""

Local lUnico			:= .F.
Local bBen     		 	:= {||Iif(lUnico,"","["+cValtoChar(nX)+"]")}
Local aTela     		:= {}
Local aDadTela  		:= {}
Local aDadInter 		:= {}
Local lExisteTag		:=.F.
Local lExiteBenProp		:=.F.
Local lExiteBenOutros	:=.F.
Local cLayoutPTU		:= GetNewPar("MV_PLTPARQ","A100")
Local nXZ				:=1
Local cPath		:= GetNewPar("MV_PLDRARQ","\plsptu\a100\entradas\")
Local nTotBen			:= 0
Local lsomenteUm 		:= .F.
Local cCompTag			:=If(lVemWebServ,"_PTU","")


static nBtnBrw 			:= 1 //Controla cor do botao no browse
Default lVemWebServ 	:= .F.

oObjXml	:= nil

B5C->(dbSetOrder(1)) // B5C_FILIAL+B5C_CODIGO
B5D->(dbSetOrder(1)) // B5D_FILIAL+B5D_CODIGO+B5D_CODINT+B5D_MATRIC
		
If !lVemWebServ
	cArqTmp := cPath + substr( cArq,rat( "\",cArq ) + 1 )	
Else	
	cArqTmp := cArq	
EndIf

If !P100ChecB5F(cNameArq)//Verifico se o arquivo ja foi importado na B5F
	iF !MsgYesNo("Arquivo já importado, deseja continuar!!")
		return()
	Endif	
EndIF




oObjXml := XmlParserFile( cArqTmp, "", @cError, @cWarning )
If !Empty(cError)
	MsgAlert(cError)
	Return
EndIf

//Beneficiarios Proprios
	
If  Type("oObjXml:"+cCompTag+"_PTUA100_POS_UB:"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS") <> "U"

 	lUnico := .F.
	lExisteTag := .T.
	

	If Type("oObjXml:"+cCompTag+"_PTUA100_POS_UB:"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO") == "A"
		nTot += len(&("oObjXml:"+cCompTag+"_PTUA100_POS_UB:"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO"))
	Else
		If Type("oObjXml:"+cCompTag+"_PTUA100_POS_UB:"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS") == "A"
			nTot += len(&("oObjXml:"+cCompTag+"_PTUA100_POS_UB:"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS"))
			lExiteBenProp:=.T. // define que o XML esta sendo quebrado por beneficiarios proprios 
			//Exemplo
			/*
			OOBJXML:_PTUA100_POS_UB:_ARQUIVOA100:_COMPART_POS:_BENEFICIARIOS_PROPRIOS:{size=157}
					OOBJXML:_PTUA100_POS_UB:_ARQUIVOA100:_COMPART_POS:_BENEFICIARIOS_PROPRIOS[1]:...
					OOBJXML:_PTUA100_POS_UB:_ARQUIVOA100:_COMPART_POS:_BENEFICIARIOS_PROPRIOS[2]:...
					OOBJXML:_PTUA100_POS_UB:_ARQUIVOA100:_COMPART_POS:_BENEFICIARIOS_PROPRIOS[3]:...
					OOBJXML:_PTUA100_POS_UB:_ARQUIVOA100:_COMPART_POS:_BENEFICIARIOS_PROPRIOS[4]:...
					OOBJXML:_PTUA100_POS_UB:_ARQUIVOA100:_COMPART_POS:_BENEFICIARIOS_PROPRIOS[5]:...
			*/

		Else
			nTot +=1
		Endif	
	Endif	
Endif

//Outros Beneficiarios

If  Type("oObjXml:"+cCompTag+"_PTUA100_POS_UB:"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS") <> "U"

	lUnico := .F.
	lExisteTag := .T.
	

	If Type("oObjXml:"+cCompTag+"_PTUA100_POS_UB:"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS:"+cCompTag+"_BENEFICIARIO") == "A"
		nTotOut += len(&("oObjXml:"+cCompTag+"_PTUA100_POS_UB:"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS:"+cCompTag+"_BENEFICIARIO"))
	Else
		If Type("oObjXml:"+cCompTag+"_PTUA100_POS_UB:"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS") == "A"
			nTotOut += len(&("oObjXml:"+cCompTag+"_PTUA100_POS_UB:"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS"))		
			lExiteBenOutros:=.T.
		else
			nTotOut +=1 
		Endif 	
	EndIF	
Endif


If  lExisteTag
	
	
	ProcRegua(nTot+nTotOut)
	
  	aadd( aTela, { 'Empresa'    			, "@!" , 32.2 } )
	aadd( aTela, { 'Contrato/Versao '		, "@!" , 69.0 } )
	aadd( aTela, { 'SubContrato/Versao '	, "@!" , 82.8 } )
   	aadd( aTela, { 'Produto ' 				, "@!" , 62.5 } )
   	aadd( aTela, { 'Matricula '				, "@!" , 59.8 } )	
	aadd( aTela, { 'Nome do Beneficiario '	, "@!" , 59.8 } )
	aadd( aTela, { 'Tipo'					, "@!" , 50.0 } )
    
	For nX := 1 to nTot		 
		//TAG BENEFICIARIOS PROPRIOS	
		If nTot > 1       

			
			//Para Len(aDados)pendentes menores de 18 anos sem CPF, deve ser informado o nome da mï¿½e ou PIS/PASEP
			If lExiteBenProp
								
				If Type("oObjXml:"+cCompTag+"_PTUA100_POS_UB:"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO") ="O"
					// Somente um beneficiario na TAG
					nTotBen:= 1
					lsomenteUm := .T.
				Else
					nTotBen:= len(&("oObjXml:"+cCompTag+"_PTUA100_POS_UB:"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO"))
					lsomenteUm := .F.
				Endif
				
				for nY:=1 to  nTotBen
					aadd(aDados,Array(17))
					aadd(aDadTela,Array(7))
					//Cabeï¿½alho             	    
					aDados[Len(aDados)][01] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_DT_GERACAO")
					aDados[Len(aDados)][02] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_DT_GERACAO")
					aDados[Len(aDados)][03] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_DT_GERACAO")
					aDados[Len(aDados)][04] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_NRVERTRA")
					//aDados[Len(aDados)][05] := strzero(val(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_UNIMED:"+cCompTag+"_CD_UNI_DESTINO")),4)
					aDados[Len(aDados)][05] := strzero(val(PLRetTag100(oObjXml,            cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS"+ Eval(bBen) +":"+cCompTag+"_CD_UNI_DESTINO")),4)
					aDados[Len(aDados)][06] := strzero(val(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_UNIMED:"+cCompTag+"_CD_UNI_ORIGEM" )),4)
					  
					// DadoLen(aDados)Pessoais		
					aDados[Len(aDados)][07] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO"+ If(!lsomenteUm,"["+CVALTOCHAR(nY)+"]",'') +":"+cCompTag+"_IDENTIFICACAOBENEF:"+cCompTag+"_ID_BENEF")
					aDados[Len(aDados)][08] := strzero(val(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO"+ If(!lsomenteUm,"["+CVALTOCHAR(nY)+"]",'') +":"+cCompTag+"_IDENTIFICACAOBENEF:"+cCompTag+"_CD_UNIMED")),4)


					aDados[Len(aDados)][09] := PLRetTag100(oObjXml,            cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO"+ If(!lsomenteUm,"["+CVALTOCHAR(nY)+"]",'') +":"+cCompTag+"_CD_CPF")    
					aDados[Len(aDados)][10] := PLRetTag100(oObjXml,            cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO"+ If(!lsomenteUm,"["+CVALTOCHAR(nY)+"]",'') +":"+cCompTag+"_DT_NASC")
					aDados[Len(aDados)][11] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO"+ If(!lsomenteUm,"["+CVALTOCHAR(nY)+"]",'') +":"+cCompTag+"_DT_INI_COMP_RISCO")
					aDados[Len(aDados)][12] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO"+ If(!lsomenteUm,"["+CVALTOCHAR(nY)+"]",'') +":"+cCompTag+"_DT_FIM_COMP_RISCO")
					aDados[Len(aDados)][13] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO"+ If(!lsomenteUm,"["+CVALTOCHAR(nY)+"]",'') +":"+cCompTag+"_NM_COMPL_BENEF")
					aDados[Len(aDados)][14] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO"+ If(!lsomenteUm,"["+CVALTOCHAR(nY)+"]",'') +":"+cCompTag+"_TP_CONTR_LOCAL")
					//RodapLen(aDados)ï¿½
					aDados[Len(aDados)][15] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CARIMBOCMB\"+cCompTag+"_DT_POSTAGEM")
					aDados[Len(aDados)][16] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CARIMBOCMB\"+cCompTag+"_NR_PROTOCOLO") 
					aDados[Len(aDados)][17] := "P"

					aDadInter := PLSUSRIEVE(aDados[Len(aDados)][6]+aDados[Len(aDados)][7],"1",dDataBase)  
			
					If aDadInter[1] == "1" 
						aDadTela[Len(aDados)][1] := aDadInter[4] //Empresa Intercambio
						aDadTela[Len(aDados)][2] := aDadInter[5]+aDadInter[6] //Contrato
						aDadTela[Len(aDados)][3] := aDadInter[7]+aDadInter[8]  //SubContrato
						aDadTela[Len(aDados)][4] := " " //Produto            
						aDadTela[Len(aDados)][5] := aDados[Len(aDados)][7] //Matricula
						aDadTela[Len(aDados)][6] := aDados[Len(aDados)][13] //Nome
						aDadTela[Len(aDados)][7] := "Proprio" 
					EndIf

				Next nY	
			else

				aadd(aDados,Array(17))
				aadd(aDadTela,Array(7))
				//Cabeï¿½alho             	    
				aDados[Len(aDados)][01] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_DT_GERACAO")
				aDados[Len(aDados)][02] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_DT_GERACAO")
				aDados[Len(aDados)][03] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_DT_GERACAO")
				aDados[Len(aDados)][04] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_NRVERTRA")
				aDados[Len(aDados)][05] := strzero(val(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_CD_UNI_DESTINO")),4)
				aDados[Len(aDados)][06] := strzero(val(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_UNIMED:"+cCompTag+"_CD_UNI_ORIGEM" )),4)

				// DadoLen(aDados)Pessoais		
				aDados[Len(aDados)][07] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO"+ Eval(bBen) +":"+cCompTag+"_IDENTIFICACAOBENEF:"+cCompTag+"_ID_BENEF")
				aDados[Len(aDados)][08] := strzero(val(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO"+ Eval(bBen) +":_IDENTIFICACAOBENEF:"+cCompTag+"_CD_UNIMED")),4)


				aDados[Len(aDados)][09] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO"+ Eval(bBen) +":"+cCompTag+"_CD_CPF")    
				aDados[Len(aDados)][10] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO"+ Eval(bBen) +":"+cCompTag+"_DT_NASC")
				aDados[Len(aDados)][11] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO"+ Eval(bBen) +":"+cCompTag+"_DT_INI_COMP_RISCO")
				aDados[Len(aDados)][12] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO"+ Eval(bBen) +":"+cCompTag+"_DT_FIM_COMP_RISCO")
				aDados[Len(aDados)][13] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO"+ Eval(bBen) +":"+cCompTag+"_NM_COMPL_BENEF")
				aDados[Len(aDados)][14] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO"+ Eval(bBen) +":"+cCompTag+"_TP_CONTR_LOCAL")

				//RodapLen(aDados)ï¿½
				aDados[Len(aDados)][15] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CARIMBOCMB\"+cCompTag+"_DT_POSTAGEM")
				aDados[Len(aDados)][16] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CARIMBOCMB\"+cCompTag+"_NR_PROTOCOLO") 
				aDados[Len(aDados)][17] := "P"

				aDadInter := PLSUSRIEVE(aDados[Len(aDados)][6]+aDados[Len(aDados)][7],"1",dDataBase)  
			
				If aDadInter[1] == "1" 
					aDadTela[Len(aDados)][1] := aDadInter[4] //Empresa Intercambio
					aDadTela[Len(aDados)][2] := aDadInter[5]+aDadInter[6] //Contrato
					aDadTela[Len(aDados)][3] := aDadInter[7]+aDadInter[8]  //SubContrato
					aDadTela[Len(aDados)][4] := " " //Produto            
					aDadTela[Len(aDados)][5] := aDados[Len(aDados)][7] //Matricula
					aDadTela[Len(aDados)][6] := aDados[Len(aDados)][13] //Nome
					aDadTela[Len(aDados)][7] := "Proprio" 
				EndIf

				
			Endif	

		Else
			aadd(aDados,Array(17))
			aadd(aDadTela,Array(7))
			  
			aDados[Len(aDados)][1] := Stod(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_DT_GERACAO"))
			aDados[Len(aDados)][2] := Stod(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_DT_GERACAO"))
			aDados[Len(aDados)][3] := Stod(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_DT_GERACAO"))
			aDados[Len(aDados)][4] := PLRetTag100(oObjXml,cNameSpace,"\"+"_CABECALHO:_NRVERTRA")

			aDados[Len(aDados)][5] := strzero(val(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_UNIMED:"+cCompTag+"_CD_UNI_DESTINO")),4)
			aDados[Len(aDados)][6] := strzero(val(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_UNIMED:"+cCompTag+"_CD_UNI_ORIGEM")),4)

			// DadoLen(aDados)Pessoais		
			aDados[Len(aDados)][7] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO:"+cCompTag+"_IDENTIFICACAOBENEF:"+cCompTag+"_ID_BENEF")
			aDados[Len(aDados)][8] := strzero(val(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO:"+cCompTag+"_IDENTIFICACAOBENEF:"+cCompTag+"_CD_UNIMED")),4)
			
				// Len(aDados)dos Pessoais		
			aDados[Len(aDados)][07] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO:"+cCompTag+"_IDENTIFICACAOBENEF:"+cCompTag+"_ID_BENEF")
			aDados[Len(aDados)][08] := strzero(val(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO:"+cCompTag+"_IDENTIFICACAOBENEF:"+cCompTag+"_CD_UNIMED")),4)

			//Para Len(aDados)pendentes menores de 18 anos sem CPF, deve ser informado o nome da mï¿½e ou PIS/PASEP
			aDados[Len(aDados)][09] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO:"+cCompTag+"_CD_CPF")    
			aDados[Len(aDados)][10] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO:"+cCompTag+"_DT_NASC")
			aDados[Len(aDados)][11] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO:"+cCompTag+"_DT_INI_COMP_RISCO")
			aDados[Len(aDados)][12] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO:"+cCompTag+"_DT_FIM_COMP_RISCO")
			aDados[Len(aDados)][13] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO:"+cCompTag+"_NM_COMPL_BENEF")
			aDados[Len(aDados)][14] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_PROPRIOS:"+cCompTag+"_BENEFICIARIO:"+cCompTag+"_TP_CONTR_LOCAL")

			//RodapLen(aDados)ï¿½
			aDados[Len(aDados)][15] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CARIMBOCMB\"+cCompTag+"_DT_POSTAGEM")
			aDados[Len(aDados)][16] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CARIMBOCMB\"+cCompTag+"_NR_PROTOCOLO") 
			aDados[Len(aDados)][17] := "P"

			aDadInter := PLSUSRIEVE(aDados[Len(aDados)][6]+aDados[Len(aDados)][7],"1",dDataBase)  
				
			If aDadInter[1] == "1" 
				aDadTela[Len(aDados)][1] := aDadInter[4] //Empresa Intercambio
				aDadTela[Len(aDados)][2] := aDadInter[5]+aDadInter[6] //Contrato
				aDadTela[Len(aDados)][3] := aDadInter[7]+aDadInter[8]  //SubContrato
				aDadTela[Len(aDados)][4] := " " //Produto            
				aDadTela[Len(aDados)][5] := aDados[Len(aDados)][7] //Matricula
				aDadTela[Len(aDados)][6] := aDados[Len(aDados)][13] //Nome
				aDadTela[Len(aDados)][7] := "Proprio" 
			EndIf

		EndIF   
		
		IncProc()

	Next   


	For nX := 1 to (nTotOut)		 
	 	//TAG BENEFICIARIOS OUTROS
		If nTotOut > 1       

	
			//Para Len(aDados)pendentes menores de 18 anos sem CPF, deve ser informado o nome da mï¿½e ou PIS/PASEP
			If lExiteBenOutros

				If Type("oObjXml:"+cCompTag+"_PTUA100_POS_UB:"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO") ="O"
					// Somente um beneficiario na TAG
					nTotBen:= 1
					lsomenteUm:=.T.
				Else
					nTotBen:= len(&("oObjXml:"+cCompTag+"_PTUA100_POS_UB:"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO"))
					lsomenteUm:=.F.
				Endif

				for nY:=1 to  nTotBen
					aadd(aDados,Array(17))
					aadd(aDadTela,Array(7))
					//Cabeï¿½alho             	    
					aDados[Len(aDados)][01] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:_DT_GERACAO")
					aDados[Len(aDados)][02] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:_DT_GERACAO")
					aDados[Len(aDados)][03] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:_DT_GERACAO")
					aDados[Len(aDados)][04] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:_NRVERTRA")
					aDados[Len(aDados)][05] := strzero(val(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_UNIMED:"+cCompTag+"_CD_UNI_DESTINO")),4)
					aDados[Len(aDados)][06] := strzero(val(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_UNIMED:"+cCompTag+"_CD_UNI_ORIGEM" )),4)

					// DadoLen(aDados)Pessoais		
					aDados[Len(aDados)][07] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO"+ If(!lsomenteUm,"["+CVALTOCHAR(nY)+"]",'') +":"+cCompTag+"_IDENTIFICACAOBENEF:"+cCompTag+"_ID_BENEF")
					aDados[Len(aDados)][08] := strzero(val(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO"+ If(!lsomenteUm,"["+CVALTOCHAR(nY)+"]",'') +":"+cCompTag+"_IDENTIFICACAOBENEF:"+cCompTag+"_CD_UNIMED")),4)

					
					aDados[Len(aDados)][09] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO"+ If(!lsomenteUm,"["+CVALTOCHAR(nY)+"]",'') +":"+cCompTag+"_CD_CPF")    
					aDados[Len(aDados)][10] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO"+ If(!lsomenteUm,"["+CVALTOCHAR(nY)+"]",'') +":"+cCompTag+"_DT_NASC")
					aDados[Len(aDados)][11] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO"+ If(!lsomenteUm,"["+CVALTOCHAR(nY)+"]",'') +":"+cCompTag+"_DT_INI_COMP_RISCO")
					aDados[Len(aDados)][12] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO"+ If(!lsomenteUm,"["+CVALTOCHAR(nY)+"]",'') +":"+cCompTag+"_DT_FIM_COMP_RISCO")
					aDados[Len(aDados)][13] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO"+ If(!lsomenteUm,"["+CVALTOCHAR(nY)+"]",'') +":"+cCompTag+"_NM_COMPL_BENEF")
					aDados[Len(aDados)][14] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS"+ Eval(bBen) +":"+cCompTag+"_BENEFICIARIO"+ If(!lsomenteUm,"["+CVALTOCHAR(nY)+"]",'') +":"+cCompTag+"_TP_CONTR_LOCAL")

					//RodapLen(aDados)ï¿½
					aDados[Len(aDados)][15] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CARIMBOCMB\"+cCompTag+"_DT_POSTAGEM")
					aDados[Len(aDados)][16] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CARIMBOCMB\"+cCompTag+"_NR_PROTOCOLO") 
					aDados[Len(aDados)][17] := "O"

					aDadInter := PLSUSRIEVE(aDados[Len(aDados)][6]+aDados[Len(aDados)][7],"1",dDataBase)  
			
					If aDadInter[1] == "1" 
						aDadTela[Len(aDados)][1] := aDadInter[4] //Empresa Intercambio
						aDadTela[Len(aDados)][2] := aDadInter[5]+aDadInter[6] //Contrato
						aDadTela[Len(aDados)][3] := aDadInter[7]+aDadInter[8]  //SubContrato
						aDadTela[Len(aDados)][4] := " " //Produto            
						aDadTela[Len(aDados)][5] := aDados[Len(aDados)][7] //Matricula
						aDadTela[Len(aDados)][6] := aDados[Len(aDados)][13] //Nome
						aDadTela[Len(aDados)][7] := "Outros " 
					EndIf
				Next nY	
			Else	
	
				aadd(aDados,Array(17))
				aadd(aDadTela,Array(7))
				//Cabeï¿½alho             	    
				aDados[Len(aDados)][01] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:_DT_GERACAO")
				aDados[Len(aDados)][02] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:_DT_GERACAO")
				aDados[Len(aDados)][03] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:_DT_GERACAO")
				aDados[Len(aDados)][04] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:_NRVERTRA")
				aDados[Len(aDados)][05] := strzero(val(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:_UNIMED:_CD_UNI_DESTINO")),4)
				aDados[Len(aDados)][06] := strzero(val(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:_UNIMED:_CD_UNI_ORIGEM" )),4)

				// DadoLen(aDados)Pessoais		
				aDados[Len(aDados)][07] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:_COMPART_POS:_BENEFICIARIOS_OUTROS:_BENEFICIARIO"+ Eval(bBen) +":_IDENTIFICACAOBENEF:_ID_BENEF")
				aDados[Len(aDados)][08] := strzero(val(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:_COMPART_POS:_BENEFICIARIOS_OUTROS:_BENEFICIARIO"+ Eval(bBen) +":_IDENTIFICACAOBENEF:_CD_UNIMED")),4)

				aDados[Len(aDados)][09] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS:"+cCompTag+"_BENEFICIARIO"+ Eval(bBen) +":"+cCompTag+"_CD_CPF")    
				aDados[Len(aDados)][10] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS:"+cCompTag+"_BENEFICIARIO"+ Eval(bBen) +":"+cCompTag+"_DT_NASC")
				aDados[Len(aDados)][11] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS:"+cCompTag+"_BENEFICIARIO"+ Eval(bBen) +":"+cCompTag+"_DT_INI_COMP_RISCO")
				aDados[Len(aDados)][12] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS:"+cCompTag+"_BENEFICIARIO"+ Eval(bBen) +":"+cCompTag+"_DT_FIM_COMP_RISCO")
				aDados[Len(aDados)][13] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS:"+cCompTag+"_BENEFICIARIO"+ Eval(bBen) +":"+cCompTag+"_NM_COMPL_BENEF")
				aDados[Len(aDados)][14] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS:"+cCompTag+"_BENEFICIARIO"+ Eval(bBen) +":"+cCompTag+"_TP_CONTR_LOCAL")
		
				//RodapLen(aDados)ï¿½
				aDados[Len(aDados)][15] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CARIMBOCMB\"+cCompTag+"_DT_POSTAGEM")
				aDados[Len(aDados)][16] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CARIMBOCMB\"+cCompTag+"_NR_PROTOCOLO") 
				aDados[Len(aDados)][17] := "O"

				aDadInter := PLSUSRIEVE(aDados[Len(aDados)][6]+aDados[Len(aDados)][7],"1",dDataBase)  
				
				If aDadInter[1] == "1" 
					aDadTela[Len(aDados)][1] := aDadInter[4] //Empresa Intercambio
					aDadTela[Len(aDados)][2] := aDadInter[5]+aDadInter[6] //Contrato
					aDadTela[Len(aDados)][3] := aDadInter[7]+aDadInter[8]  //SubContrato
					aDadTela[Len(aDados)][4] := " " //Produto            
					aDadTela[Len(aDados)][5] := aDados[Len(aDados)][7] //Matricula
					aDadTela[Len(aDados)][6] := aDados[Len(aDados)][13] //Nome
					aDadTela[Len(aDados)][7] := "Outros " 
				EndIf
	

			Endif 	

			 
		Else
			aadd(aDados,Array(17))
			aadd(aDadTela,Array(7))
			
			aDados[Len(aDados)][1] := Stod(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_DT_GERACAO"))
			aDados[Len(aDados)][2] := Stod(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_DT_GERACAO"))
			aDados[Len(aDados)][3] := Stod(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_DT_GERACAO"))
			aDados[Len(aDados)][4] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_NRVERTRA")

			aDados[Len(aDados)][5] := strzero(val(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_UNIMED:"+cCompTag+"_CD_UNI_DESTINO")),4)
			aDados[Len(aDados)][6] := strzero(val(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CABECALHO:"+cCompTag+"_UNIMED:"+cCompTag+"_CD_UNI_ORIGEM")),4)

			// DadoLen(aDados)Pessoais		
			aDados[Len(aDados)][7] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS:"+cCompTag+"_BENEFICIARIO:"+cCompTag+"_IDENTIFICACAOBENEF:"+cCompTag+"_ID_BENEF")
			aDados[Len(aDados)][8] := strzero(val(PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS:"+cCompTag+"_BENEFICIARIO:"+cCompTag+"_IDENTIFICACAOBENEF:"+cCompTag+"_CD_UNIMED")),4)
			
			//Para Len(aDados)pendentes menores de 18 anos sem CPF, deve ser informado o nome da mï¿½e ou PIS/PASEP
			aDados[Len(aDados)][9]  := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS:"+cCompTag+"_BENEFICIARIO:"+cCompTag+"_CD_CPF")    
			aDados[Len(aDados)][10] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS:"+cCompTag+"_BENEFICIARIO:"+cCompTag+"_DT_NASC")
			aDados[Len(aDados)][11] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS:"+cCompTag+"_BENEFICIARIO:"+cCompTag+"_DT_INI_COMP_RISCO")
			aDados[Len(aDados)][12] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS:"+cCompTag+"_BENEFICIARIO:"+cCompTag+"_DT_FIM_COMP_RISCO")
			aDados[Len(aDados)][13] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS:"+cCompTag+"_BENEFICIARIO:"+cCompTag+"_NM_COMPL_BENEF")
			aDados[Len(aDados)][14] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_ARQUIVOA100:"+cCompTag+"_COMPART_POS:"+cCompTag+"_BENEFICIARIOS_OUTROS:"+cCompTag+"_BENEFICIARIO:"+cCompTag+"_TP_CONTR_LOCAL")

			//RodapLen(aDados)ï¿½
			aDados[Len(aDados)][15] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CARIMBOCMB\"+cCompTag+"_DT_POSTAGEM")
			aDados[Len(aDados)][16] := PLRetTag100(oObjXml,cNameSpace,"\"+cCompTag+"_CARIMBOCMB\"+cCompTag+"_NR_PROTOCOLO") 	  
			aDados[Len(aDados)][17] := "O"

			aDadInter := PLSUSRIEVE(aDados[Len(aDados)][6]+aDados[Len(aDados)][7],"1",dDataBase)  
					
			If aDadInter[1] == "1" 
				aDadTela[Len(aDados)][1] := aDadInter[4] //Empresa Intercambio
				aDadTela[Len(aDados)][2] := aDadInter[5]+aDadInter[6] //Contrato
				aDadTela[Len(aDados)][3] := aDadInter[7]+aDadInter[8]  //SubContrato
				aDadTela[Len(aDados)][4] := " " //Produto            
				aDadTela[Len(aDados)][5] := aDados[Len(aDados)][7] //Matricula
				aDadTela[Len(aDados)][6] := aDados[Len(aDados)][13] //Nome
				aDadTela[Len(aDados)][7] := "Outros " 
			EndIf
		EndIF   
	
		IncProc()

		
	Next   


    If !Empty(aDados)            
		cCodUOrg 	:= aDados[1][6]    
        cCodUDes := aDados[1][5]
        cText    := "Operadora Origem -> " + cCodUOrg  +  " Operadora Destino -> " + cCodUDes
		ProcXML100(aDadTela,aDados,cNameArq,cArqTmp,nOpc)
    EndIF
Else

	MsgInfo("Estrutura do arquivo com problema! Verifique e importe novamente!")
	
EndIf

Return


//------------------------------------------------------------------------------------------
/*/{Protheus.doc} valPathImp
Valida Estrutura de Pastas \plsptu\A100\schemas

@author    Totvres
@since     11/03/2019
/*/
//------------------------------------------------------------------------------------------
static Function valPathImp(cErro)
	local cRootPath  := ""
	If !ExistDir( "\plsptu")
		If MakeDir( "\plsptu") != 0  
			cErro := "Não foi possivel criar o diretorio " + "\plsptu"     
		EndIf
	EndIf    
	If !ExistDir( "\plsptu\A100")
		If MakeDir( "\plsptu\A100") != 0  
			cErro := "Não foi possivel criar o diretorio " + "\plsptu\A1350"     
		EndIf
	EndIf 
	If !ExistDir( "\plsptu\A100\schemas")  
		If MakeDir("\plsptu\A100\schemas") != 0  
			cErro := "Não foi possivel criar o diretorio " + "\plsptu\A100\schemas"     
		EndIf
	EndIf 
	If !ExistDir( "\plsptu\A100\entradas")  
		If MakeDir("\plsptu\A100\entradas") != 0  
			cErro := "Nï¿½o foi possivel criar o diretorio " + "\plsptu\A100\entradas"     
		EndIf
	EndIf 
Return

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} valXmlA100
Valida schema do arquivo XML A100

@author    PLS TEAM
@since     08/03/2019
/*/
//------------------------------------------------------------------------------------------
static Function valXmlA100(cFilePath, cErro, cAviso,lVemWebServ)
local cPath100 	:= "\plsptu\A100\schemas\"
local cXml 		:= ""
local cSchemaPTU 	:= "ptu_A100_Pos_UB.xsd"
local cSchemaSim 	:= "ptu_SimpleTypes-V1_0" + ".xsd"
local cSchemaCom 	:= "ptu_ComplexTypes-V1_0" + ".xsd"
local cNomArq 	:= AllTrim(substr(cFilePath, rAt("\", cFilePath) + 1))
local cPath		:= GetNewPar("MV_PLDRARQ","\plsptu\a100\entradas\")
local cArqTemp	:= If(lVemWebServ,cPath + cNomArq,cFilePath)
local lRet			:= .T.

local lArqCopiado	:=.F.

Default cAviso     	:= ""
Default lVemWebServ := .F.

cErro := "Arquivo de schema não encontrado: "

Do Case
	Case !File(cPath100 + cSchemaPTU, 0, .T.)
		cErro := cErro + cSchemaPTU
	Case !File(cPath100 + cSchemaSim, 0, .T.)
		cErro := cErro + cSchemaSim
	Case !File(cPath100 + cSchemaCom, 0, .T.)
		cErro := cErro + cSchemaCom
	OtherWise
		cErro := ""
EndCase

If Empty(cErro)
	If !lVemWebServ 

		nHandle := fopen(cFilePath)

		If nHandle <= 0
			MsgAlert("Arquivo não existe no caminho indicado, ou corrompido  ")
			Return .F.
		EndIf
		aInfoFile := Directory(cFilePath)
		nSize := aInfoFile[1, 2]
		cXML:=''

		
		FREAD(nHandle,@cXML,nSize)


		nPosIni	:= at("ptuA100_Pos_UB",cXml)
		cNewXml	:= Substr(cXml,nPosIni	,nSize)
		
		fclose(nHandle)
		
		nArq := fCreate( cPath+cNomArq )

		if nArq > 0 
			fWrite( nArq,cXml )
    		fClose( nArq )
		Endif	

		lArqCopiado :=.T.
	Endif
		
	If lVemWebServ .and. lArqCopiado //Copio o arquivo para o Servidor.

		If !P100CheImp(cNomArq)//Verifico se o arquivo ja foi importado
			MsgAlert("Arquivo já importado")
			lRet := .F.
		ElseIf (!XmlFVldSch( If(lVemWebServ,cArqTemp,cPath+cNomArq), cPath100 + cSchemaPTU, @cErro,@cAviso))
			if( msgYesNo( "Existem erros na validações do arquivo XML. Deseja salvar o arquivo de LOG?" ) )
				aErrors := strTokArr( cErro,CRLF )
				gLogErroI( cErro )
			endIf
			lRet := .F.
		Endif	
	EndIf
	If( !lVemWebServ .and. fErase( cArqTemp ) == -1 )
		FWLogMsg('WARN',, 'SIGAPLS', funName(), '', '01', "[ERRO]: PLSP100IMP - falha na exclusao do arquivo temporario: '" + cArqTemp + "'"   , 0, 0, {})
		lRet := .F.
	EndIf
	
Else
	lRet := .F.
	MsgAlert(cErro)
EndIf
Return lRet

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} gLogErroI
Grava arquivo de log

@author    PLS TEAM
@version   1.xx
@since     08/03/2019
@param     cError = lista de erros encontrados
/*/
//------------------------------------------------------------------------------------------
static function gLogErroI( cError )
	local cMascara	:= "Arquivos .LOG | *.log"
	local cTitulo	:= "Selecione o local"
	local nMascpad	:= 0
	local cRootPath	:= ""
	local lSalvar	:= .F.	//.F. = Salva || .T. = Abre
	local nOpcoes	:= nOR( GETF_LOCALHARD,GETF_ONLYSERVER,GETF_RETDIRECTORY )
	local l3Server	:= .T.	//.T. = apresenta a arvore do servidor || .F. = nï¿½o apresenta
	local cAnoComp	:= allTrim( str( year( dDataBase ) ) )
	local cMesComp	:= allTrim( strZero( month( dDataBase ),2 ) )
	local cNomeArq	:= cAnoComp + cMesComp + strTran( allTrim( time() ),":","_" ) + ".log"
	local cPathLOG	:= ""

	cPathLOG	:= cGetFile( cMascara,cTitulo,nMascpad,cRootPath,lSalvar,nOpcoes,l3Server )
		If !Empty(cPathLOG)
			nArqLog		:= fCreate( cPathLOG+cNomeArq,FC_NORMAL )	
			fWrite( nArqLog,cError )
			fClose( nArqLog )	
			MsgAlert( "Arquivo de log gerado com sucesso. (" + cNomeArq + ")" )
		EndIF
return
/**/

//-------------------------------------------------------------------
/*/{Protheus.doc} PLRetTagWB
Funcao para retornar um elemento de um Objeto baseado em um XML

Parametros:    
	cNameSpace -> Namespace padrao da estrutura
	cPai       -> Tag da estrutura principal
	cTree      -> Estrutura de tags a partir da pai que se deseja obeter a informacao

@author  PLS TEAM
@version P11
@since   21/07/16
/*/
//------------------------------------------------------------------- 
Function PLRetTag100(oObjXml,cNameSpace,cTree,cTpDado,nCompZero)
Local cString := ""
Local xRet    := ""
Local nX      := 0
Local aAux    := {}

Default cNameSpace := ""
Default cTpDado    := "C"
Default nCompZero  := 0

aAux := StrTokArr( cTree,"\")
cString := "oObjXml:" + cNameSpace + ":"

For nX := 1 to len(aAux)    
    cString += aAux[nX]+":"    	        
Next

If Type(Substr(cString,1,len(cString)-1)) == "O"     
	xRet := &(Upper(cString+"TEXT"))
	
	If cTpDado == "D"
		xRet := Replace(xRet,"-","")	
	EndIf          
//Casos onde pode repetir a tag, mas foi enviado somente uma (codigos de glosa por exemplo) 	
ElseIf Substr(cString,len(cString)-3,4) == "[1]:"
	cString := Substr(cString,1,len(cString)-4)+":"  
	If Type(Substr(cString,1,len(cString)-1)) == "O"     
		xRet := &(Upper(cString+"TEXT"))
		
		If cTpDado == "D"
			xRet := Stod(Replace(xRet,"-",""))	
		EndIf    
	EndIf			
EndIf

If nCompZero > 0
	xRet := Strzero(Val(xRet),nCompZero)  
EndIf

Return xRet

//-------------------------------------------------------------------
/*/{Protheus.doc} ProcXML100
Realiza a importaï¿½ï¿½o dos dados do XML

@author    Totvres
@version P12
@since   13/03/2019
/*/
//-------------------------------------------------------------------
Function ProcXML100(aLinha,aDadosP,cNameArq,cArqTmp,nOpc)
	Local nLen    		:= len(aDadosP)
	Local nX   	  		:= 0
	Local cCPF 	  		:= ""
	Local cPathProc  		:= GetNewPar("MV_PLWBPRC","\plsptu\A100\processados\") // CAMINHO DOS ARQUIVOS JA PROCESSADOS
	Local lRet          := .F.
	Private cMatOri  		:= ""
 	Private cCodOpeOri	:= ""
	//Private cCodEmpOri	:= ""
	Private cCodMatOri	:= ""
	Private cCodMat	 	:= ""	 	
	Private cAcao	  		:= ""
	Private aDados	  	:= {}
	Private cOpeOri   	:= ""


	For nX := 1 to nLen
		//MsProcTxt('Validando e Importando...: '+StrZero(nX,5))
		//ProcessMessage()

		cMatOri 		:= aDadosP[nX][8]+aDadosP[nX][7]
		cCodMatOri  	:= SubStr(cMatOri,4,6)
		cCpf    		:= aDadosP[nX][9]
		cCodOpeOri		:= aDadosP[nX][8] //cd_Unimed -EXEMPLO ARQUIVO ENVIADO PARA SUL CAPIXABA NA TAG PROOUTROS ESTARÁ 176 E NA TAG 
		cCodOpeHab  	:= aDadosP[nX][5]
		dVigIniRis  	:= aDadosP[nX][11]
		dVigFimRis  	:= aDadosP[nX][12]
		cTpCont     	:= aDadosP[nX][14]	
			
 
		//Se usuario repassado em Custo Operacional, verifico se ele ja existe na BA1
		//se existir, vou registrar somente o envio habitual/risco
		If aDadosP[nX][17] = "P"
			BA1->( DbSetOrder(2) )	
			
		Else
			BA1->( DbSetOrder(5) )	
		
		Endif
		
		If !Empty(cMatOri) .and. BA1->( MsSeek( xFilial("BA1")+cMatOri ) )			
								   		
			lRet:=PLSPGRVXML(cCodOpeOri,BA1->(BA1_CODINT+BA1_CODEMP+BA1_MATRIC+BA1_TIPREG+BA1_DIGITO),dVigIniRis,dVigFimRis,cMatOri,cTpCont,"", "", "",cNameArq,cCodOpeHab)
			
			If lRet
				aAdd( aCritGeral,{(aDadosP[nX][8]+aDadosP[nX][7]+space(5)),(Substr(aDadosP[nX][13],1,25)+space(5)),(aDadosP[nX][9]+space(10)),If(aDadosP[nX][17]="P","PROPRIO","OUTROS"),"Beneficiário incluído"} ) //"Guia processado com sucesso na Operadora de Origem !!!"
			Else
				aAdd( aCritGeral,{(aDadosP[nX][8]+aDadosP[nX][7]+space(5)),(Substr(aDadosP[nX][13],1,25)+space(5)),(aDadosP[nX][9]+space(10)),If(aDadosP[nX][17]="P","PROPRIO","OUTROS"),"Beneficiário atualizado"} ) //"Guia processado com sucesso na Operadora de Origem !!!"
			Endif 	
			Loop
		Else

			aAdd( aCritGeral,{(aDadosP[nX][8]+aDadosP[nX][7]+space(5)),(Substr(aDadosP[nX][13],1,25)+space(5)),(aDadosP[nX][9]+space(10)),If(aDadosP[nX][17]="P","PROPRIO","OUTROS"),"Beneficiario não encontrado"} ) //"Guia processado com sucesso na Operadora de Origem !!!"
			
			
		EndIF


	Next
	If len(aCritGeral) > 0
    	PLSCRIGEN(aCritGeral,{ {"Matricula ","@!",40}, {"Beneficiário ","@!",60}, {"CPF ","@!",30} , {"Tipo ","@!",40}, {"Status ","@!",20}  }  ,"Ocorrencias do processamento ",Nil,Nil)
    EndIF  		  

	If nOpc <> 4
		// Atualizando Status
		BX0->(RecLock("BX0",.F.))
		BX0->BX0_STATUS = "1"
		BX0->(MsUnLock())
	Endif	



	//Copiando arquivos para backup
	If ExistDir(cPathProc)
		__CopyFile(cArqTmp , cPathProc + cNameArq )
	Endif
	aCritGeral		:={}

Return(.T.)

//-------------------------------------------------------------------
/*/{Protheus.doc} PLSPGRVXML
Grava registro habitual B5F

@author  PLS TEAM
@version P12
@since   13/03/2019
/*/
//-------------------------------------------------------------------
Static Function PLSPGRVXML(cOpeOri,cMatric,dVigIni,dVigFim,cMatAnt,cTpCont,cIdPlan, cProdAns, cPlaInt,cNomArq,cOpeHab)

	Local lRet 		:= .F.
	Local cCodInt   := Substr(cMatric,1,4)  // Operadora 
	Local cCodEmp   := Substr(cMatric,5,4)  // Empresa 				
	Local cMat	  	:= Substr(cMatric,9,6)  // Matricula 
	Local cTipRg  	:= Substr(cMatric,15,2) // Tipo Registro
	Local cDigito 	:= Substr(cMatric,17,1) // Digito
	Local cQuery	
	Local dDtVigFim := StoD(dVigIni) - 1 // Caso tenha registro sem vigencia final será a vigencia inicial da proxima menos um

	// Verifica se existem registro com data de vigencia final em aberto, caso sim atualiza
	cQuery := "SELECT B5F_VIGINI, B5F_VIGFIM, R_E_C_N_O_ Recno FROM " + RetSqlName("B5F") + " B5F "
	cQuery += "WHERE B5F_FILIAL = '"+xFilial("B5F")+"' AND "
	cQuery += "B5F_OPEHAB = '"+cOpeHab+"' AND "
	cQuery += "B5F_OPEORI = '"+cOpeOri+"' AND "
	cQuery += "B5F_CODINT = '"+cCodInt+"' AND "
	cQuery += "B5F_CODEMP = '"+cCodEmp+"' AND "
	cQuery += "B5F_MATRIC = '"+cMat+   "' AND "
	cQuery += "B5F_TIPREG = '"+cTipRg+ "' AND "
	cQuery += "B5F_DIGITO = '"+cDigito+"' AND "
	cQuery += "B5F_VIGFIM = ' ' AND B5F.D_E_L_E_T_ = ' ' "
	cQuery += "ORDER BY B5F_VIGINI DESC "

	dbUseArea(.T.,"TOPCONN",TCGENQRY(,,cQuery),"TRbB5F",.F.,.T.)

	If !TRbB5F->(Eof())
		While !TRbB5F->(Eof())

			B5F->(DbGoTo(TRbB5F->Recno)) // Posiciona na B5F
			B5F->(RecLock("B5F",.F.))
				B5F->B5F_VIGFIM := dDtVigFim // Atualiza a data de vigencia final com a data inicial da proxima menos um
			B5F->(MsUnLock())

			dDtVigFim := B5F->B5F_VIGINI - 1 // Altera a data da vigencia para a proxima data de vigencia final menos um
			TRbB5F->(DbSkip())	

		EndDo
	EndIf

	TRbB5F->(dbCloseArea())
	
	B5F->(DbSetOrder(2))//B5F_FILIAL+B5F_OPEHAB+B5F_OPEORI+B5F_CODINT+B5F_CODEMP+B5F_MATRIC+B5F_TIPREG+B5F_DIGITO+DTOS(B5F_VIGINI)                                                        
	If !B5F->(MsSeek(xFilial("B5F")+cOpeHab+cOpeOri+cMatric+dVigIni)) 
		B5F->(RecLock("B5F",.T.))
		B5F->B5F_FILIAL := xFilial('B5F')
		B5F->B5F_OPEORI := cOpeOri
		B5F->B5F_OPEHAB := cOpeHab
		B5F->B5F_CODINT := BA1->BA1_CODINT
		B5F->B5F_CODEMP := BA1->BA1_CODEMP
		B5F->B5F_MATRIC := BA1->BA1_MATRIC
		B5F->B5F_TIPREG := BA1->BA1_TIPREG
		B5F->B5F_DIGITO := BA1->BA1_DIGITO
		B5F->B5F_VIGINI := STOD(dVigIni)
		B5F->B5F_VIGFIM := STOD(dVigFim)
		B5F->B5F_MATANT := cMatAnt
		B5F->B5F_STATUS := "3"//acatado
		B5F->B5F_ARQEDI := cNomArq
		B5F->B5F_NOMUSR := BA1->BA1_NOMUSR
		If B5F->(FieldPos("B5F_TPCONT")) > 0
			B5F->B5F_TPCONT := cTpCont
		EndIf	
		B5F->(MsUnLock())    
		lRet := .T.
	Else
		B5F->(RecLock("B5F",.F.))
		B5F->B5F_VIGINI := STOD(dVigIni)
		B5F->B5F_VIGFIM := STOD(dVigFim)
		B5F->B5F_ARQEDI := cNomArq
		If B5F->(FieldPos("B5F_TPCONT")) > 0
			B5F->B5F_TPCONT := cTpCont
		EndIf	
		
		B5F->(MsUnLock())
		lRet := .F.
	
	EndIf

Return lRet 

//------------------------------------------------------------------------------------------
/*/{Protheus.doc} P100CheImp
Checa se arquivo ja foi importado

@author    PLS TEAM
@since     13/04/2005
/*/
//------------------------------------------------------------------------------------------
Function P100ChecB5F(cNomArq)
   Local cSql := ""
   Local lRet := .T.

   cSql := " SELECT 1 FROM "+RetSQLName("B5F")
   cSql += " WHERE B5F_FILIAL = '"+xFilial("B5F")+"'"
   cSql += " AND B5F_ARQEDI = '"+cNomArq+"'"
   cSql += " AND D_E_L_E_T_ = ' ' "
   //Executa a Query 
   PLSQuery(cSql,"QBF5")
   If !QBF5->(Eof())
       lRet := .F.
   EndIf
   
   QBF5->(DbCloseArea())      


Return(lRet)
