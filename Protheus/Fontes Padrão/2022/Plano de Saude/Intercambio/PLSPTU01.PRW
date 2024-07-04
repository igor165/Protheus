#INCLUDE "PROTHEUS.CH"
#INCLUDE "FILEIO.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "PLSMGER.CH"

STATIC cPathIn    := 'c:\olentrada\'    		  // Path dos arquivos de entrada
STATIC cFileLog	  := "\LOGPLS\"+DtoS(Date())+"\plsptu.log"


//-------------------------------------------------------------------
/*/{Protheus.doc} PLsPtuLog
Grava o Log com a descricao do HELP.   

cLogErro - Texto a ser gravado no arquivo.
o ARQUIVO DEFAULT E DE USO EXCLUSIVO DO PTU ONLINE

@author  Eduardo Motta
@version P12
@since   12/03/1998
/*/
//-------------------------------------------------------------------
Function PlsPtuLog(cLogErro,cArqlog)    
DEFAULT cArqlog := "plsptu.log"

// Vai gerar arquivos conforme a database e a thread
If AllTrim(cArqlog) == "plsptu.log"
	PlsLogFil(cLogErro,"plsptutra",,.T.)
EndIf	

// Este log nao pode mudar o nome do arquivo pq este arquivo e exibido na apl
PlsLogFil(cLogErro,cArqlog)

Return


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsPtuOln
Programa para tratamento de PTU online (ENVIO)

@author  Eduardo Motta
@version P12
@since   08.03.04
/*/
//-------------------------------------------------------------------
Function PlsPtuOln(aCab,aIte,cNomArq,lWaitRet,lWeb,aGrvTraPTU,aQuimio,aRadio,cMsgXsdErr,aAuto)
LOCAL cUniDom
LOCAL cLineRet   := ""
LOCAL cNameFile  := ""
LOCAL cCodLay    := GetMV("MV_LAYPTU",,'900000')
LOCAL nHOut      := 0
LOCAL cFileIn    := ""
LOCAL nTamFileIn := 0
LOCAL cBufferIn  := ""
LOCAL cLinha     := ""
LOCAL nHIn       := 0
LOCAL aRet       := {}
LOCAL nCont      := 0
LOCAL cMsg       := ""
LOCAL lMsg   	 := .T.
LOCAL nSegundos  := GetNewPar("MV_PTUTIME",60) * 10
LOCAL lWebServ   := (GetNewPar("MV_PTUVEON","50") >= "60")
PRIVATE nContW   := 100
PRIVATE nContT   := 0
PRIVATE lEnvio   := .F.
PRIVATE lRetorno := .F.
PRIVATE lInterc  := .T.
PRIVATE aDados   := aCab
PRIVATE aItens   := aIte
PRIVATE aCabDE1  := {}
PRIVATE aDadDE1  := {}
PRIVATE aTrabDE1 := {}
PRIVATE aCabDE0  := {}
PRIVATE aDadDE0  := {}
PRIVATE aTrabDE0 := {}
PRIVATE cDelimit := ""   
PRIVATE lAnexo   := .F.
DEFAULT lWaitRet := .T.                           
DEFAULT lWeb	 := .T.
DEFAULT aGrvTraPTU := {} 
DEFAULT cMsgXsdErr := ""
DEFAULT aAuto := {.F.,""}
// Verifica se tem anexo
If PlsPtuGet("CD_TRANS",aCab) $ "00600/00605"
	For nCont :=1 to len(aIte) 
		If PlsPtuGet("TP_ANEXO",aIte[nCont]) $ "1,2,3"
			lAnexo := .T.
			Exit	
		EndIf	
	Next
EndIf

// Msg
If !lWeb .And. !aAuto[1]
	MsProcTxt( 'Iniciando...' )
EndIf	
ProcessMessages()

// Ajusta itens solicitados verificando se ha caracteres nao permitidos
AjusCarEsp(@aCab)
If Valtype(aIte) == 'A'
	For nCont :=1 to len(aIte)   
		AjusCarEsp(@aIte[nCont])	
	Next
EndIf

//Grava arquivo B0T														   
// **** verificar a necessidade de gravar novamente os dados da transacao ****
If Len(aGrvTraPTU) > 0          
    PLPTGRVREN(aCab,;              // Cabecalho
               aIte,;              // Itens
               aGrvTraPTU[1],;     // Cod da Transacao
               aGrvTraPTU[2],;     // Tipo 
               aGrvTraPTU[3],;     // Cod Unimed Solicitante    
               aGrvTraPTU[4],;     // Cod Unimed Destino
               "1",;               // 1-Envio /2 - Recebimento
               aGrvTraPTU[5],;      // Nome Usuario 
               iif(len(aGrvTraPTU)>5,aGrvTraPTU[6],nil) ,; //aQuimio
               iif(len(aGrvTraPTU)>6,aGrvTraPTU[7],nil) )  //aRadio
Endif     

// Chama funcao para WebService PTU Online ou superior	 
aRet := PLPTUONCOM(aCab,aIte,aQuimio,aRadio,cNomArq,@cMsgXsdErr,aAuto)

Return aRet


//-------------------------------------------------------------------
/*/{Protheus.doc} PlsPTUGet
Le um campo de uma matriz

@author  Eduardo Motta
@version P12
@since   12/03/98
/*/
//-------------------------------------------------------------------
Function PlsPTUGet(cVar,aDad)
LOCAL cVal:=""
LOCAL nPos
LOCAL aDadBase := {}
If aDad # NIL
   aDadBase := aClone(aDad)
Else
   If Type("aDadosPOS")=="A"
      aDadBase := aClone(aDadosPOS)
   EndIf
EndIf
nPos := aScan(aDadBase,{|x|AllTrim(x[1])==AllTrim(cVar)})
If nPos > 0
   cVal := aDadBase[nPos,2]
EndIf
Return cVal



//-------------------------------------------------------------------
/*/{Protheus.doc} PlsPTUPut
Coloca um valor em um campo da matriz

@author  Eduardo Motta
@version P12
@since   12/03/98
/*/
//-------------------------------------------------------------------
Function PlsPTUPut(cVar,uVal,aDadBase)
LOCAL cVal:=""
LOCAL nPos
nPos := aScan(aDadBase,{|x|AllTrim(x[1])==AllTrim(cVar)})
If nPos > 0
   aDadBase[nPos,2] := uVal
Else
   aadd(aDadBase,{cVar,uVal})
EndIf
Return


//-------------------------------------------------------------------
/*/{Protheus.doc} AjusCarEsp
Remove caracteres invalidos no envio do PTU Online

@author  Microsiga
@version P12
@since   04/12/13
/*/
//-------------------------------------------------------------------               
Static Function AjusCarEsp(aDados) 
Local nI   
Local nF
Local cCar    := ""
Local cString := ""

// Retira caracteres invalidos 
For nF:=1 to len (aDados)
	cString := aDados[nF][2]
	If !Empty(cString) .And. ValType(cString) == "C"
		For nI:=1 To Len(cString) 
		    cCar := SubStr(cString,nI,1)
		    If !Upper(cCar) $ " ABCDEFGHIJKLMNOPQRSTUVXYWZ1234567890!@#$%&*()-+={}[]<>:?,.;/\'_|"
				cString := StrTran( cString,cCar,Space(1)) 
			EndIf	
		Next
        aDados[nF][2] := cString
    EndIf     	        
Next

Return