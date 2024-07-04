#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDEF.ch'
#INCLUDE 'TOPConn.ch' 
#INCLUDE 'TMSAE85.ch'
#INCLUDE "FILEIO.CH"

//-----------------------------------------------------
/*	Monitor de Notas Fiscais não importadas ao EDI
{Protheus.doc} TMSAE85
@author  	Leandro Paulino
@version 	P11 R1.7
@build		7.00.111010P
@since 		15/06/2012
@return 	Nil	  												  */
//------------------------------------------------------
                                     
Function TMSAE85()

Private oMark
Private cCadastro := STR0001 //--"Notas Fiscais não importadas ao EDI"

If IsSrvUnix()
	Private DIRXML   := "XMLNFE/"
	Private DIRALER  := "NEW/"
	Private DIRLIDO  := "OLD/"
	Private DIRERRO  := "ERR/" 
Else
	Private DIRXML   := "XMLNFE\"
	Private DIRALER  := "NEW\"
	Private DIRLIDO  := "OLD\"
	Private DIRERRO  := "ERR\" 
EndIf

If !ExistDir(DIRXML)
	MakeDir(DIRXML)
	MakeDir(DIRXML +DIRALER)
	MakeDir(DIRXML +DIRLIDO)
	MakeDir(DIRXML +DIRERRO)
EndIf

// Instanciamento do classe
oMark := FWMarkBrowse():New()

// Definição da tabela a ser utilizada
oMark:SetAlias('DEV')

// Define se utiliza controle de marcação exclusiva do
oMark:SetSemaphore(.T.)

// Define a titulo do browse de marcacao
oMark:SetDescription(STR0002) //--'NFes não Importadas para o EDI'

// Define o campo que sera utilizado para a marcação
oMark:SetFieldMark( 'DEV_OK' ) 

// Definição do filtro de aplicacao
oMark:SetFilterDefault( "DEV_STATUS=='1'" )

// Ativacao da classe
oMark:Activate()

Return NIL    

//-------------------------------------------------------------------
Static Function MenuDef()

Local aRotina 	:= {}        

	ADD OPTION aRotina TITLE STR0003	ACTION 'TMSE85PRC()'								OPERATION 2 ACCESS 0    //Reprocessar
	ADD OPTION aRotina TITLE STR0005	ACTION 'TMSAE85Vis(Recno())'						OPERATION 2 ACCESS 0 	//Mais Informações
	ADD OPTION aRotina TITLE STR0006	ACTION 'TMSE85VXML(Recno())'						OPERATION 2 ACCESS 0    //"Visualiza XML"

Return aRotina

//-----------------------------------------------------
/*	Visualiza o detalhe do Erro na Importacao da Nf-e
{Protheus.doc} TMSAE85Vis
@author  	Leandro Paulino
@version 	P11 R1.7
@build		7.00.111010P
@since 		15/06/2012
@return 		Nil										  */
//------------------------------------------------------
Function TMSAE85Vis(nRecno)
Local aVisualiza  := {}
Local aFldDEV 	:= {}
Local nX		:= 0

Default nRecno := 0

aFldDEV := ApBuildHeader("DEV", {"DEV_OK","DEV_STATUS"})
For nX := 1 To Len(aFldDEV)
	aAdd(aVisualiza, aFldDEV[nX][2])
Next

aSize(aFldDEV, 0)
aFldDEV := Nil

AxVisual("DEV",Recno(),2,aVisualiza)

Return (Nil)

//-----------------------------------------------------
/*	Reprocessa o XML com Erro na Nf-e
{Protheus.doc} TMSAE85Prc
@author  	Leandro Paulino
@version 	P11 R1.7
@build		7.00.111010P
@since 		15/06/2012
@return 	Nil 			  			                        */
//------------------------------------------------------
Function TMSE85Prc()

Local aArea := GetArea()
Local cMarca := oMark:Mark()
Local aDoctos:= {}            
Local nDocto := 0
Local lUsaColab	:= Findfunction("ColUsaColab") .And. ColUsaColab('6') 
Local cFlag		:= 2

If lUsaColab .And. AllTrim(SuperGetMv("MV_TCIMP",,"0")) == "1" //0 = Importação Colab / 1 = Importação SIGATMS 
	lUsaColab := .F.
EndIf 

If lUsaColab

	DEV->(dbSetOrder(2))   
	DEV->(dbSeek(xFilial('DEV')+'1'))
	While !DEV->(Eof()) .And. DEV->DEV_STATUS == '1'	
		If oMark:IsMark(cMarca)
			Aadd(aDoctos,{DEV->(Recno()), DEV->DEV_ARQUIV})
		EndIf	
		DEV->(dbSkip())	
	EndDo
	For nDocto:= 1 To Len(aDoctos)			

		lAviso 			:= .T. //Exibe o Aviso se pelo menos um arquivo for selecionado
		oColab 			:= ColaboracaoDocumentos():New()
		oColab:cQueue 	:= SubStr(aDoctos[nDocto,2],1,3)
		oColab:cModelo 	:= ""
		oColab:cTipoMov := '2'
		oColab:cFlag 	:= cFlag
		oColab:cNomeArq := aDoctos[nDocto,2]
		oColab:Consultar()
		oColab:cFlag 	:= '0'
		oColab:FlegaDocumento()

		DEV->(DbGoTo(aDoctos[nDocto,1]))	
		RecLock("DEV",.F.)	
		DEV->(DbDelete())
		MsUnLock()            
		
	Next nDocto	

Else
	DEV->(dbSetOrder(2))   
	DEV->(dbSeek(xFilial('DEV')+'1'))
	While !DEV->(Eof()) .And. DEV->DEV_STATUS == '1'	
		If oMark:IsMark(cMarca)
			Aadd(aDoctos,{DEV->(Recno())})
		EndIf	
		DEV->(dbSkip())	
	EndDo
	For nDocto:= 1 To Len(aDoctos)			
		DEV->(DbGoTo(aDoctos[nDocto,1]))	
		RecLock("DEV",.F.)	
		//-- Move arquivo para pasta new
		Copy File &(DIRXML+DIRERRO+DEV->DEV_ARQUIV) To &(DIRXML+DIRALER+DEV->DEV_ARQUIV)
		FErase(DIRXML+DIRERRO+DEV->DEV_ARQUIV)
		DEV->DEV_STATUS := '3'
		MsUnLock()            
	Next nDocto	
EndIf

RestArea( aArea )

oMark:Refresh()
	
Return ( Nil )


//-----------------------------------------------------
/*	Visualiza o XML
{Protheus.doc} TMSE85VXML
@author  	Daniel Leme
@version 	P12.1.17
@since 		18/07/2017
@return 		Nil										  */
//------------------------------------------------------
Function TMSE85VXML(nRecno)
Local cDirArq

Default nRecno := 0

If !Empty(nRecno)
	If DEV->DEV_STATUS == "1"     //-- 1= Não importado para o EDI
		cDirArq := DIRXML+DIRERRO
	ElseIf DEV->DEV_STATUS == "2" //-- 2= Importado para o EDI 
		cDirArq := DIRXML+DIRLIDO
	ElseIf DEV->DEV_STATUS == "3" //-- 3= Reprocessado
		cDirArq := DIRXML+DIRALER
	EndIf
	VisualizaXML(DEV->DEV_ARQUIV,cDirArq)
EndIf
Return Nil

/*/{Protheus.doc} VisualizaXML
	
@author Daniel Leme
@since 17/07/2017
@version 1.0		

@return sem retorno

@description

Visualiza um arquivo XML

/*/
Static Function VisualizaXML(cArqXML, cDirArq)
Local lRet      := .T.
Local cDestTemp := GetTempPath() + DIRXML
Local cNewXML   := cDestTemp + cArqXML
Local cXml 		:= ""
Local aDirectory := {}
Local i

//Verifica se ja existe o diretorio na pasta Temp, caso exista limpa o diretorio.
If !lIsDir(cDestTemp)
	nRet := MakeDir(cDestTemp)
	If nRet < 0
		Help('',1,'TMSAE8501') //-- "Erro na criação do diretório na pasta Temp."
		lRet := .F.
	EndIf
Else 
	//Apaga os arquivos do diretorio na pasta temp.
	aDirectory := DIRECTORY(cDestTemp + "*.*",)
	For i:=1 to len(aDirectory)
		FERASE(cDestTemp + aDirectory[i][1])
	Next i
EndIf

//Faz a leitura do arquivo XML.
If lRet
	cXml := RetXml(cDirArq + cArqXML)
	If cXml == ""
		Help('',1,'TMSAE8502') //-- "Erro de leitura de arquivo." 
		lRet := .F.
	EndIf                                          
EndIf

If lRet
	Begin Sequence
		//Cria o XML na pasta temp 
		If !MemoWrite(cNewXML, cXml)
			Help('',1,'TMSAE8503') //-- "Erro na gravação do arquivo."
			lRet := .F.
			Break
		EndIf
						
		//Executa o arquivo XML com o layout ja definido.     
		nRet := ShellExecute("open",cNewXML,"","", 1)
		If nRet <= 32
			Help('',1,'TMSAE8504') //-- "Erro na exibição do arquivo."
			lRet := .F.
			Break
		EndIf
	Recover
		lRet := .F.
	End Sequence
EndIf
         
Return lRet

/*/{Protheus.doc} RetXml
	
@author Daniel Leme
@since 18/07/2017
@version 1.0		

@return cXML, string contendo os dados lidos no arquivo XML.

@description

Faz a leitura de um arquivo XML e retorna a string validada.

/*/
Static Function RetXml(cFile)
Local cXML := ""
Local cXMLOri := ""

nHandle := FOpen(cFile)
nLength := FSeek(nHandle,0,FS_END)
FSeek(nHandle,0)
If nHandle > 0
	FRead(nHandle, cXMLOri, nLength)
	FClose(nHandle)
	If !Empty(cXMLOri)
		If SubStr(cXMLOri,1,1) != "<"
			nPosPesq := At("<",cXMLOri)
			cXMLOri  := SubStr(cXMLOri,nPosPesq,Len(cXMLOri))		// Remove caracteres estranhos antes da abertura da tag inicial do arquivo
		EndIf
	EndIf
	cXML := EncodeUtf8(cXMLOri)

	// Verifica se o encode ocorreu com sucesso, pois alguns caracteres especiais provocam erro na funcao de encode, neste caso e feito o tratamento pela funcao A140IRemASC
	If Empty(cXML)
		cStrXML := cXMLOri
		cXMLOri := A140IRemASC(cStrXML)
		cXML    := EncodeUtf8(cXMLOri)  
	EndIf
	If Empty(cXML)
		cXML := cXMLOri
	EndIf
EndIf

Return cXML
