#Include "AVERAGE.CH"
#Include "EEC.CH"
#Include "Protheus.CH"

Function EasyXSLView()
Return Nil


/*
Classe    : EasyXSLView()
Objetivos : Ler arquivos XSL e adicionar a defini��o nos arquivos XML e apresentar no Browse.
Parametros:                                     
Retorno   : -
Autor     : Allan Oliveira Monteiro
Data      : 23/02/2011 
*/

*------------------------------*
Class EasyXSLView From AvObject
*------------------------------*
	Data cXML       //Conteudo XML
	Data cXMLFile   //Arquivo XML
	Data cXSL       //Conteudo XSL
	Data cXSLName   //Nome do fonte APH XSL
	Data cDirTemp   //Diret�rio para c�pia dos Arquivos XML e XSL
	
	Method New(cXML, cXSLName, lFile) //Inicializador dos atribudos e chamada para os outro metodos
	Method SetDirTemp(cDir)           //Indica o diret�rio que ser� copiado os arquivos XML e XSL
	Method View()                     //Visualiza��o
	Method RetXML()                   //Retorna String XML
	Method RetXSL()                   //Retorna String XSL
	Method AdicReferencia()           //Adiciona a Referencia do XSL no arquivo XML
	Method CriaArquivos()             //Cria os arquivos XML e XSL no diret�rio informado
	Method CallBrowser()              //Inicializa o Browse de visualiza��o 
	Method ApagaTemp()                //Apaga os arquivos do diret�rio informado
	Method CarregaXML()               //Carrega dados do Arquivo XML
	

End Class 



*---------------------------------------------------*
Method New(cXML, cXSLName, lFile) Class EasyXSLView
*---------------------------------------------------*
Default lFile := .T.
   
   //Heran�a dos metodos do AvObject
   _Super:New()
   Self:setClassName("EasyXSLView")

   //Valida os par�metros verificando se o XML � um arquivo ou conteudo 
   If lFile
      //Arquivo
      Self:cXMLFile := cXML
   Else
      //Conteudo XML
      Self:cXML := cXML
   EndIf
   
   //Adicionando o nome do XSL
   Self:cXSLName := cXSLName  
   
   //Indicando o diret�rio que ser copiado os arquivos
   Self:SetDirTemp(GetTempPath())
   
      
   //Visualiza��o dos arquivos
   Self:View()


Return Self 



*----------------------------------------*
Method SetDirTemp(cDir) Class EasyXSLView
*----------------------------------------*   
   /*Adiciona o diret�rio cuja os arquivos XSL e XML 
   ser�o criados para leitura do Browse*/
   If ValType(cDir) == "C"
      Self:cDirTemp := cDir
   EndIf

Return Nil



*------------------------------*
Method View() Class EasyXSLView
*------------------------------*   

Begin Sequence
   
   //Apaga os temporarios
   Self:ApagaTemp()
   
   //Busca a string do XML
   If !Self:RetXML()
      Break
   EndIf
   
   //Busca a string do XSL
   If !Self:RetXSL()
      Break
   EndIf
   
   //Altera o XML adicionando a refer�ncia do XSL
   Self:AdicReferencia()
   
   //Cria os arquivos
   If !Self:CriaArquivos()
      Break
   EndIf
   
   //Exibe o arquivo
   Self:CallBrowser()
     
End Sequence 

//Apresentam os erros se forem encontrados.
If Self:lError 
   Self:ShowErrors()
EndIf

Return



*--------------------------------*
Method RetXML() Class EasyXSLView
*--------------------------------* 
Local lRet := .F.  
   /*Se o parametro informado no XML for o caminho do arquivo efetua
    leitura do XML atrav�s da fun��o "CarregaXML()" */
   If ValType(Self:cXML) <> "C"
      lRet := Self:CarregaXML()
   EndIf

Return lRet 



*--------------------------------*
Method RetXSL() Class EasyXSLView
*--------------------------------*
Local lRet := .T.

   If ValType(Self:cXSL) <> "C"
      //Busca no Fonte do formato APH o conteudo XSL
      Self:cXSL := &("H_" + Self:cXSLName + "()")
   EndIf
   
   If ValType(Self:cXSL) == "C" .And. Empty(Self:cXSL)
      Self:Error("N�o foi possivel carregar o aquivo, pois o arquivo XSL nao est� sendo encontrado ou est� vazio.")
      lRet := .F.
   EndIf

Return lRet 



*------------------------------------*
Method CarregaXML() Class EasyXSLView  
*------------------------------------*
Local lRet := .T.
   
   //Efetua a leitura no arquivo XML
   Self:cXML := MemoRead(Self:cXMLFile)
   
   If ValType(Self:cXML) == "C" .And. Empty(Self:cXML)
      Self:Error("N�o foi possivel efetuar a leitura do aquivo XML.")
      lRet := .F.
   EndIf

Return lRet



*----------------------------------------*
Method AdicReferencia() Class EasyXSLView
*----------------------------------------*
Local cXML
   
   //Adiciona defini��o do arquivo XSL ao arquivo XML
   //AOM - 12/02/2012 - Adicionar a referencia abaixo a versao xml
   cXML := '<?xml version="1.0" encoding= "ISO-8859-1"?>' 
   cXML += '<?xml-stylesheet type="text/xsl" href="' + Self:cXSLName + '.xsl"?>' + ENTER
   cXML := StrTran ( Self:cXML, '<?xml version="1.0" encoding= "ISO-8859-1"?>' , cXML,, ) 
   Self:cXML := cXML

Return 



*--------------------------------------*
Method CriaArquivos() Class EasyXSLView
*--------------------------------------* 
Local lRet := .T. 
  
   //Cria o arquivo XSL no diret�rio informado, por padrao "Temporario"
   If !MemoWrite(Self:cDirTemp + Self:cXSLName + ".xsl" , Self:cXSL)
      Self:Error("Erro na abertura do arquivo XSL.")
      lRet := .F.
   EndIf
   //Cria o arquivo XML com o mesmo nome do XSL no diret�rio informado, por padrao "Temporario"
   If !MemoWrite(Self:cDirTemp + Self:cXSLName + ".xml" , Self:cXML)
      Self:Error("Erro na abertura do arquivo XML.")
      lRet := .F.
   EndIf


Return lRet
 


*-------------------------------------*
Method CallBrowser() Class EasyXSLView
*-------------------------------------*
Local nRet, lRet := .T. 

//Executa o arquivo XML com o layout ja definido e abre o Browse.     
nRet := ShellExecute("open",Self:cDirTemp + Self:cXSLName + ".xml" ,"","", 1)
If nRet <= 32
   Self:Error("Erro na exibi��o do arquivo.")
   lRet := .F.
EndIf 

Return lRet



*-----------------------------------*
Method ApagaTemp() Class EasyXSLView
*-----------------------------------*  
  //Verifica se o arquivo existe no diret�rio e apaga
  If File(Self:cDirTemp + Self:cXSLName + ".xml")
     FERASE(Self:cDirTemp + Self:cXSLName + ".xml")
  EndIf
  
  //Verifica se o arquivo existe no diret�rio e apaga
  If File(Self:cDirTemp + Self:cXSLName + ".xsl")
     FERASE(Self:cDirTemp + Self:cXSLName + ".xsl")
  EndIf
  
Return
