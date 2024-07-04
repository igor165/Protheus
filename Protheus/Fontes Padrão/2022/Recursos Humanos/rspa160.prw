#include "Protheus.ch"
#include "font.ch"
#include "colors.ch"
#include "Rspa160.ch"      
#include "xmlxfun.ch"    

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rspa160   ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 17/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Leitura de Curriculo atraves de arquivo XML.                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Rspa160                                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.             ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Programador ³ Data   ³ BOPS ³  Motivo da Alteracao                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Cecilia Car.³29/07/14³TQENN4³Incluido o fonte da 11 para a 12 e efetua-³±±
±±³            ³        ³      ³da a limpeza.                             ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function RSPA160()
Local cAlias 		:= "SQH"
Local nReg			:= 1
Local nOpcx         := 1
Local nI			:= 0

Private cCadastro	:= STR0001 		// " Relacionamento de Campos "  
Private aRotina 	:= {}	

For nI := 1 to 3
	Aadd(aRotina,{"","",0,6})
Next nI

Rs160Conf(cAlias,nReg,nOpcx)

dbSelectArea("SQH")
dbSetOrder(1)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs160Conf ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 17/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Rotina Principal de Configuracao de Campos.				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Rspa160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs160Conf(cAlias,nReg,nOpcx)

Local cLbx      := ""    
Local nOpca		:= 0
Local oDlgMain
Local aLstArq	:= {}
Local aCampos1	:= {}

Local oGroup
Local oFont
Local oRadio	
Local nRadio 	:= 1
Local bBlock 	:= { || }
Local bClick 	:= { || }

Local bSet15	:= {||}
Local bSet24	:= {||}
Local aButtons	:= {}

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}
	
Private aCampos := {}      
Private cCopy
Private oCopy
Private oCola
						
// Private da Getdados
Private aCols  	:= {}
Private aHeader	:= {}
Private aColsRec:= {}
Private aSvCols	:= {}
Private oGet	:= {}

Private aArqMain:= {}
Private aCmpXml	:= {}
Private oLbx
Private oTree
Private oNo		:= LoadBitmap( GetResources(), "LBNO" )
Private oOk		:= LoadBitmap( GetResources(), "LBTIK" )

Private nEstou	:= 1
Private nIndo	:= 1
                               	
dbSelectArea("SQH")
dbSetorder(1)

// Monta os dados dos ListBox 
If !Rs160Camp(@aLstArq)          
	Return Nil
EndIf	

Rs160Get(aLstArq[1])	// Monta GetDados

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 90	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 80	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*75), (((aObjSize[1,4])/100)*85) }	//1,3 Vertical /1,4 Horizontal

DEFINE FONT oFont  NAME "Arial" SIZE 0,-11 BOLD//6.5,0 TO 28,80
DEFINE MSDIALOG oDlgMain FROM	aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cCadastro OF oMainWnd PIXEL

	//ListBox XML
   	@ aGdCoord[1],aGdCoord[2] LISTBOX oLbx VAR cLbx FIELDS;
			HEADER 		"",;					//""
						OemtoAnsi(STR0004),; 	//"Campo XML"
						OemtoAnsi(STR0002);		//"Exemplo de Conteudo"
			SIZE (aGdCoord[4]/2)-5,((aObjSize[1,3])/100)*35 OF oDlgMain PIXEL ON DBLCLICK (Rs160Clk())         
			
	oLbx:nFreeze	:= 1
	oLbx:SetArray(aCmpXml)
	oLbx:bLine		:= {||{If(	aCmpXml[oLbx:nAt][1] == 2, oOk, oNo),;
								aCmpXml[oLbx:nAt][2],;
								aCmpXml[oLbx:nAt][3]}}
                
	// Radio de Arquivos             
	@ (((aObjSize[1,3])/100)*35)+15, aGdCoord[2] GROUP oGroup TO aGdCoord[3],(aGdCoord[4]/2)-5 LABEL OemToAnsi(STR0014) OF oDlgMain PIXEL	// "Arquivos"
	oGroup:oFont:= oFont
	bBlock	:= { |x| If(ValType(x)=='U', nRadio , nRadio := x ) }
	bClick 	:= { || nIndo := nRadio, Rs160AtuGt(aLstArq[nRadio]) }

	oRadio	:= TRadMenu():New( (((aObjSize[1,3])/100)*35)+25, aGdCoord[2]+5, aLstArq, bBlock, oDlgMain,,bClick,,,,,,80,8 )	
	nRadio	:= oRadio:nOption

	// GetDados Configuracao campos
	oGet:= MSGetDados():New(aGdCoord[1],(aGdCoord[4]/2)+5,aGdCoord[3],aGdCoord[4],nOpcx,"Rs160Lok","Rs160Tok",,.T.,,,,300,,,,,oDlgMain) 			
    oGet:oBrowse:nRowPos	:= oGet:oBrowse:nAt
    oGet:oBrowse:bEditCol 	:= {||oGet:oBrowse:GoLeft()}
    oGet:AddAction("QH_XML",{||Rs160F3()})
    Rs160AtuGt(aLstArq[nRadio])
      
    bSet15		:= {|| nOpca := 1,oDlgMain:End()}
	bSet24		:= {|| nOpca := 2,oDlgMain:End()}
	//aButtons	:= {{"RPMFUNC",{||Rs160Func()},OeMToAnsi(STR0011)}} //"Incluir Funcao"   
	aButtons	:= {{"RPMFUNC",{||Rs160Func()},STR0011,STR0012}} //"Incluir Funcao"#"Funcao"

ACTIVATE MSDIALOG oDlgMain ON INIT EnchoiceBar( oDlgMain , bSet15 , bSet24 , NIL , aButtons ) CENTERED

If nOpca == 1

	// Salva aCols anterior
	aSvCols[nEstou][2] := Aclone(aCols) //Salva aCols Anterior

	Rs160Grava()
EndIf

DeleteObject(oOk)
DeleteObject(oNo)

dbSelectArea("SQH")
dbSetOrder(1)
Return(Nil)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs160Camp ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 17/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Monta arquivo com os campos do Curriculo(XML).			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Rspa160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs160Camp(aLstArq)

Local oXML
Local aXml		:= {}
Local lXml		:= .T.
Local nA		:= 0
Local nB		:= 0
Local nI 		:= 0
Local nX		:= 0
Local lRet 		:= .T.
Local cFile		:= "" 
Local cDir		:= GETMV("MV_RSPDCUR")
Local cErro		:= ""
Local lOk 		:= .F.
Local aObj_Xml	:= {}
Local aArq		:= {}
Local cArq		:= ""
Local nPos		:= 0
Local nPos1		:= 0
Local nPos2		:= 0

nPos1 := AT("\",cDir)+1		//Padrao
nPos2 := AT("/",cDir)+1		//Linux

nPos := Max(nPos1,nPos2)

If nPos < 4
	cDir := Subs(cDir,nPos,Len(cDir))
EndIf
                                                    
cFile := cGetFile("*.XML |*.XML",OemToAnsi(STR0007),0,"SERVIDOR\"+cDir,.T.,GETF_OVERWRITEPROMPT) //"Selecione um arquivo"
If Empty(cFile)
	Return .F.
EndIf
aXml := Directory(cFile)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se ha XML a processar                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If (nXml := FOpen(cFile,16)) < 0
	lXml := .F.
Else
	lXml := .T.
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verifica se ha XML a processar                                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

If lXml
	cXml := FReadStr(nXml,aXml[1][2])
	oXML := XmlParser( cXml,"_",@cErro,"" )
	               
	FClose(nXml)
	If !Empty(cErro)
		Aviso( STR0008, STR0005 + cErro, {"OK"},,aXml[1][1])		//"Atencao"###"Erro: "
		Return .F.
	EndIf
Else
	If Len(aXml) > 0
		Aviso( STR0008, STR0009, {"OK"},,aXml[1][1])	//"Atencao"###"Nao foi possivel abrir arquivo"
		Return .F.
	Else  //Selecione o Arquivo para Configuracao
	   	Aviso( STR0008,OemToAnsi(STR0013), {"OK"})		//"Atencao"###"Selecione o arquivo para configuração de campos, no padrão XML, para a importação de currículos."
		Return .F.		
	EndIf
EndIf

//Verifica estrutura do arquivo XML
aObj_Xml:= ClassDataArr(oXml)
If Ascan(aObj_Xml,{|x| Upper(x[1]) == "_MODULEDATA" }) > 0
	aObj_Xml := ClassDataArr(oXml:_Moduledata)
	If Ascan(aObj_Xml,{|x| Upper(x[1]) == "_ENTITY" }) > 0
		aObj_Xml := ClassDataArr(oXml:_Moduledata:_entity)
		If Ascan(aObj_Xml,{|x| Upper(x[1]) == "_SIGAFILES" }) > 0
	 		lOk := .T.
        EndIf
	EndIf
EndIf
aObj_Xml := {}
	
If !lOk 
 	Aviso( STR0008, STR0010, {"Ok"}, , aXml[1][1] )	//"Atencao"###'O arquivo XML deve possuir estrutura "MODULEDATA", "ENTITY" e "SIGAFILES".'
	Return .F.
EndIf
				
aArqMain := {}                      

If ValType(oXML:_MODULEDATA:_ENTITY:_SIGAFILES) == "O"	//Objeto

	cArq := oXML:_MODULEDATA:_ENTITY:_SIGAFILES:_TEXT:TEXT
	
	If ValType(oXML:_MODULEDATA:_ENTITY:_SIGAFILES:_DADOS) == "O"	//Objeto
		aCampos := {}
		aArq := {}
		For nI := 1 to Len(oXML:_MODULEDATA:_ENTITY:_SIGAFILES:_DADOS:_ATTRIBUTE)	//Array dos Dados
			Aadd(aCampos, {Upper(	oXML:_MODULEDATA:_ENTITY:_SIGAFILES:_DADOS:_ATTRIBUTE[nI]:_DOMAINNAME:TEXT),;// Nome Campo 
									oXML:_MODULEDATA:_ENTITY:_SIGAFILES:_DADOS:_ATTRIBUTE[nI]:TEXT})             // Conteudo	 
		Next nI							
		Asort(aCampos,,,{|x,y| x[1] < y[1] })
		Aadd(aArq, aCampos)
	Else																//Array
		aArq := {}
		For nB := 1 To Len(	oXML:_MODULEDATA:_ENTITY:_SIGAFILES:_DADOS )
			aCampos := {}
			For nI := 1 to Len(oXML:_MODULEDATA:_ENTITY:_SIGAFILES:_DADOS[nB]:_ATTRIBUTE)	//Array dos Dados
				Aadd(aCampos, {Upper(	oXML:_MODULEDATA:_ENTITY:_SIGAFILES:_DADOS[nB]:_ATTRIBUTE[nI]:_DOMAINNAME:TEXT),;	// Nome Campo
										oXML:_MODULEDATA:_ENTITY:_SIGAFILES:_DADOS[nB]:_ATTRIBUTE[nI]:TEXT}) 	         	// Conteudo
			Next nI 
			Asort(aCampos,,,{|x,y| x[1] < y[1] })    
			Aadd(aArq, aCampos)
		Next nB
			
	EndIf
	Aadd(aArqMain, {cArq, aArq})

Else 

	For nA := 1 To Len(oXML:_MODULEDATA:_ENTITY:_SIGAFILES) 	//Array dos Arquivos
		cArq := oXML:_MODULEDATA:_ENTITY:_SIGAFILES[nA]:_TEXT:TEXT
		
		If ValType(oXML:_MODULEDATA:_ENTITY:_SIGAFILES[nA]:_DADOS) == "O"	//Objeto
			aCampos := {}
			aArq := {}
			For nI := 1 to Len(oXML:_MODULEDATA:_ENTITY:_SIGAFILES[nA]:_DADOS:_ATTRIBUTE)	//Array dos Dados
				Aadd(aCampos, {Upper(	oXML:_MODULEDATA:_ENTITY:_SIGAFILES[nA]:_DADOS:_ATTRIBUTE[nI]:_DOMAINNAME:TEXT),;	// Nome Campo  1
										oXML:_MODULEDATA:_ENTITY:_SIGAFILES[nA]:_DADOS:_ATTRIBUTE[nI]:TEXT})            	// Conteudo	 
			Next nI							
			Asort(aCampos,,,{|x,y| x[1] < y[1] })
			Aadd(aArq, aCampos)
		Else																//Array
			aArq := {}
			For nB := 1 To Len(	oXML:_MODULEDATA:_ENTITY:_SIGAFILES[nA]:_DADOS )
				aCampos := {}
				For nI := 1 to Len(oXML:_MODULEDATA:_ENTITY:_SIGAFILES[nA]:_DADOS[nB]:_ATTRIBUTE)	//Array dos Dados
					Aadd(aCampos, {Upper(	oXML:_MODULEDATA:_ENTITY:_SIGAFILES[nA]:_DADOS[nB]:_ATTRIBUTE[nI]:_DOMAINNAME:TEXT),;	// Nome Campo
											oXML:_MODULEDATA:_ENTITY:_SIGAFILES[nA]:_DADOS[nB]:_ATTRIBUTE[nI]:TEXT}) 	         	// Conteudo
				Next nI 
				Asort(aCampos,,,{|x,y| x[1] < y[1] })    
				Aadd(aArq, aCampos)
			Next nB
				
		EndIf
		Aadd(aArqMain, {cArq, aArq})
	Next nA
	
EndIf
	             
aLstArq := {}       
For nX := 1 To Len(aArqMain)
	Aadd(aLstArq,aArqMain[nX][1])
Next nX
                
Rs160Cols(aLstArq)

aCampos := Aclone(aArqMain[1][2][1])  // Array do Primeiro Arquivo
If Len(aCampos) > 0
	Rs160Lst(aCampos)
	lRet := .T.
Else
	lRet := .F.
EndIf

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs160Grava³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 17/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Grava os registros referente ao treinamentos                ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ 					                                          ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs160Grava()

Local cCampo
Local xConteudo
Local nx		:= 0
Local ny        := 0
Local nI		:= 0
                
For nI := 1 To Len(aSvCols)
    aCols 	:= Aclone(aSvCols[nI][2])
    aColsRec:= Aclone(aSvCols[nI][3])
    
	dbSelectArea("SQH")
	For nx := 1 to Len(aCols)
		If nx <= Len(aColsRec)               		// Altera Linha existente
			dbGoto(aColsRec[nx])
			RecLock("SQH",.F.,.T.)
			//--Verifica se esta deletado
			If aCols[nx][Len(aCols[nx])] 
				dbDelete()
				MsUnlock()
				Loop
			EndIf
		Else                                  	 	// Nova Linha da GetDados
			//--Verifica se Nao esta Deletado no aCols
			If !aCols[nx][Len(aCols[nx])]  
				RecLock("SQH",.T.)
				SQH->QH_FILIAL 		:= xFilial("SQH")
			Else
				Loop
			EndIf
		EndIf
		 
		For ny := 1 To Len(aHeader)
			If aHeader[ny][10] # "V"
				cCampo    := Trim(aHeader[ny][2])  
				xConteudo := aCols[nx][ny]
				If Alltrim(xConteudo) != Alltrim(STR0003)
					&cCampo   := xConteudo
				EndIf
			EndIf	
		Next ny
		MsUnlock()
	Next nx
Next nI

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs160Clk  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 25/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Funcao executada no ON CLICK do ListBox.	                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                           				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs160Clk()

Local nPosXml 	:= GdFieldPos("QH_XML")
Local nPos		:= 0

aCmpXml[oLbx:nAt][1] := Iif(aCmpXml[oLbx:nAt][1] == 1, 2, 1)

nPos := Ascan(aCols,{|x| Alltrim(x[nPosXml]) == Alltrim(aCmpXml[oLbx:nAt][2]) })

If nPos > 0 .And. aCmpXml[oLbx:nAt][1] == 1 	// Desmarcado
	aCols[nPos][nPosXml] := ""
Else 											// Marcado
	aCols[n][nPosXml] := aCmpXml[oLbx:nAt][2]
EndIf

oGet:oBrowse:Refresh()

Return .T.

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs160Lok  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 03/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Linha da GetDados.									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                           				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs160Lok()

Local lRet := .T.

If Empty(aCols[n][2]) .And. !aCols[n][Len(aCols[n])] 
	Help("",1,"RS160BRANC")	// Linha em Branco
	lRet := .F.
EndIf

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs160Tok  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 03/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Valida Toda GetDados.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                           				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs160Tok()
Return Rs160Lok()

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs160F3   ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 26/04/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Abre janela de Consulta Padrao (Teclar ENTER no "Campo XML")³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                           				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs160F3()
                
Local nPosXml	:= GdFieldPos("QH_XML")
Local nPosCmp	:= GdFieldPos("QH_CAMPO")
Local cArqF3 	:= "" 
Local cField	:= ""
Local cCampo 	:= Alltrim(aCols[n][nPosCmp])
Local lRet		:= .T.
Local cPesq		:= ""

dbSelectArea("SQH")
dbSetOrder(1)
If dbSeek(xFilial("SQH")+cCampo)

	cArqF3 := Alltrim(SQH->QH_F3)
    If !Empty(cArqF3)  
    	dbSelectarea("SXB")
		dbSetOrder(1)   
		cPesq := cArqF3+(Space(len(XB_ALIAS)-len(cArqF3))+"6")
		If Len(cArqF3) == 2 .Or. !dbSeek(cPesq)
           	lRet := Conpad1(,,,cArqF3,,,.F.)
	   	    If lRet  
	   	    	If Len(cArqF3) == 2 						// SX5
	   	    		aCols[n][nPosXml] := SX5->X5_CHAVE	
	   	    	Else										// Outros Alias
			   	    dbSelectArea(cArqF3)  
			   	    cField := FieldName(2)
					aCols[n][nPosXml] :=  &cField
				EndIf
			EndIf
		EndIf
	EndIf	
EndIf     
Return(aCols[n][nPosXml])

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs160Enter³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 03/05/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Identifica os campos que necessitam "ENTER" para Consulta.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                           				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Rs160Enter()

Local nPosCmp	:= GdFieldPos("QH_CAMPO")
Local nPosXml	:= GdFieldPos("QH_XML")
Local cArqF3 	:= "" 
Local cCampo	:= "" 	
Local nI		:= 0
Local cPesq		:= ""

dbSelectArea("SQH")
dbSetOrder(1)
For nI := 1 to Len(aCols)                     
	cCampo := Alltrim(aCols[nI][nPosCmp])
	If dbSeek(xFilial("SQH")+cCampo)
		cArqF3 := Alltrim(SQH->QH_F3)
	    If !Empty(cArqF3) .And. Empty(aCols[nI][nPosXml])
	    	dbSelectarea("SXB")
			dbSetOrder(1)
			cPesq := cArqF3+(Space(len(XB_ALIAS)-len(cArqF3))+"6")
			If Len(cArqF3) == 2 .Or. !dbSeek(cPesq)
				aCols[nI][nPosXml] := STR0003 // "Tecle <Enter>"	     	
			EndIf	
	    EndIf
	EndIf    
Next nI

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs160AtuGt³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 16/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza GetDados com campos do arquivo selecionado.	  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cArq   = Alias do arquivo                    				  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs160AtuGt(cArq)

Local aCampos 	:= {}
Local nI		:= Ascan( aArqMain, {|x| Alltrim(x[1]) == cArq } )

Rs160Get(cArq)

If nI > 0
	aCampos := Aclone(aArqMain[nI][2][1])  // Array referente Arquivo
	Rs160Lst(aCampos)
EndIf

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs160Lst  ³ Autor ³ Emerson Grassi Rocha  ³ Data ³ 16/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza ListBox com campos XML do arquivo selecionado.	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aCampos = Array com campos do Arquivo selecionado.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs160Lst(aCampos) 

Local nI		:= 0
Local nPosXml	:= GdFieldPos("QH_XML")

aCmpXml := {}
For nI := 1 to Len(aCampos)
  
		Aadd( aCmpXml, {1, aCampos[nI][1], aCampos[nI][2]} )  
		
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Marcar campos ja selecionados na ListBox ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If nPosXml > 0
			If Ascan(aCols,{|x| Alltrim(x[nPosXml]) == Alltrim(aCampos[nI][1]) }) > 0
				aCmpXml[nI][1] := 2
			EndIf
		EndIf	
		
	MsUnlock()	
Next nI

If ValType(oLbx) == "O" 
	oLbx:SetArray(aCmpXml)
	oLbx:bLine		:= {||{If(	aCmpXml[oLbx:nAt][1] == 2, oOk, oNo),;
								aCmpXml[oLbx:nAt][2],;
								aCmpXml[oLbx:nAt][3]}}
	oLbx:nAt := 1								
	oLbx:Refresh(.T.)
EndIf

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³Rs160CriaQH³Autor ³ Emerson Grassi Rocha  ³ Data ³ 16/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preenche arquivo SQH com campos do alias selecionado.		  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cArq = Arquivo selecionado								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs160CriaQH(cArq)

Local aSaveArea	:= {}
Local cChave	:= ""

If Left(cArq,1) == "S"
	cChave := Subst(cArq,2,2)
Else 
	cChave := cArq
EndIf

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o arquivo estiver vazio, carrega com campos do cArq			³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX3")
aSaveArea := GetArea()

dbSetOrder(1)                           
dbSeek(cArq)
While ! Eof() .And. X3_ARQUIVO == cArq
    
   	dbSelectArea("SQH")
	dbSetOrder(1)
	
	If !dbSeek(xFilial("SQH")+SX3->X3_CAMPO)  
		If  SX3->X3_CONTEXT != "V" .And. !("FILIAL" $ SX3->X3_CAMPO) .And.;
				!( ("CURRIC" $ SX3->X3_CAMPO) .And. cArq != "SQG" )
								
			dbSelectArea("SQH")
			RecLock("SQH",.T.,.T.)
			SQH->QH_FILIAL 		:= xFilial("SQH")
			SQH->QH_TITULO		:= SX3->X3_TITULO
		    SQH->QH_CAMPO 		:= SX3->X3_CAMPO
		    SQH->QH_TIPO		:= SX3->X3_TIPO
		    SQH->QH_F3			:= SX3->X3_F3  
			MsUnlock()         
		EndIf	
	EndIf
		
	dbSelectArea("SX3")
	dbSkip()
EndDo	
RestArea(aSaveArea)

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs160Get  ³Autor ³ Emerson Grassi Rocha  ³ Data ³ 16/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Atualiza GetDados.										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³cAlias = Arquivo selecionado								  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs160Get(cAlias)
 
aSvCols[nEstou][2] := Aclone(aCols) //Salva aCols Anterior
	
aCols := aClone(aSvCols[nIndo][2])	//Restaura aCols 

If ValType(oGet) == "O"
	Rs160Enter()
	n := 1
	oGet:oBrowse:Refresh(.T.)
	oGet:Refresh(.T.)
EndIf

nEstou := nIndo

Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs160Cols ³Autor ³ Emerson Grassi Rocha  ³ Data ³ 17/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Cria Grupo de aCols										  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³aLstArq = array dos Alias									  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs160Cols(aLstArq)
 
Local aAuxCols	:= {}
Local aAuxHeader:= {}
Local aColsRec	:= {}
Local aFields 	:= {"QH_TIPO","QH_F3"}
Local cChave 	:= ""
Local cCond 	:= "QH_FILIAL+Left(QH_CAMPO,3)"   
Local cAlias	:= ""
Local nI		:= 0

// Monta o Header		                                         
TrmHeader(@aAuxHeader,aFields,"SQH")

For nI := 1 To Len(aLstArq)
	aColsRec:= {}
	aCols	:= {}
	cAlias	:= aLstArq[nI]
	
	Rs160CriaQH(cAlias)	//Verifica se existe campos	
	
	If Left(cAlias,1) == "S"
		cChave := xFilial("SQH")+Subst(cAlias,2,2)+"_"
	Else 
		cChave := xFilial("SQH")+cAlias
	EndIf
	
	// Monta o aCols									                       
	TrmCols(@aAuxCols,aFields,1,@aColsRec,"SQH",cCond,cChave,aAuxHeader)
	aCampos1 := {aColsRec,aAuxHeader,aAuxCols}
                     
	aColsRec	:= aClone(aCampos1[1])
	aHeader		:= aClone(aCampos1[2])
	aCols	 	:= aClone(aCampos1[3]) 
	
	Aadd(aSvCols, {cAlias, aCols, aColsRec})
	
Next nI

aCols := aClone(aSvCols[1][2])
	
Return Nil

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ Rs160Func ³Autor ³ Emerson Grassi Rocha  ³ Data ³ 23/09/03 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Inclui uma funcao para preenchimento do campo selecionado.  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³															  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³RSPA160                                                     ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function Rs160Func()

Local oDlg1    
Local nPosXml 	:= GdFieldPos("QH_XML")
Local cFunc	  	:= ""
Local nOpca		:= 0
Local nTam		:= TamSX3("QH_XML")[1]

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Declaração de arrays para dimensionar tela		                         ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local aGDCoord		:= {}

/*
ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
³ Monta as Dimensoes dos Objetos         					   ³
ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ*/
aAdvSize		:= MsAdvSize()
aAdvSize[5]	:=	(aAdvSize[5]/100) * 60	//horizontal
aAdvSize[6]	:=  (aAdvSize[6]/100) * 60	//Vertical
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 0 , 0 }					 
aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
aGdCoord	:= { (aObjSize[1,1]+3), (aObjSize[1,2]+5), (((aObjSize[1,3])/100)*50), (((aObjSize[1,4])/100)*55) }	//1,3 Vertical /1,4 Horizontal

cFunc := Iif(nPosXml > 0, aCols[n][nPosXml]+Space(nTam-Len(aCols[n][nPosXml])), Space(nTam))
 
SETAPILHA()
DEFINE MSDIALOG oDlg1  FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE OemToAnsi(STR0011)OF oMainWnd PIXEL//"Incluir Funcao"
	
	@ aGdCoord[1]+15,aGdCoord[2]+5 SAY STR0012 + ": " PIXEL		//"Funcao: "
	@ aGdCoord[1]+15,aGdCoord[2]+50 MSGET cFunc PIXEL SIZE 100,7

ACTIVATE MSDIALOG oDlg1 ON INIT (EnchoiceBar(oDlg1, {|| nOpca:= 1,oDlg1:End() },{||nOpca:=2,oDlg1:End()})) CENTERED
SETAPILHA()

If nOpca == 1
	aCols[n][nPosXml] := "#"+cFunc
EndIf

Return Nil
