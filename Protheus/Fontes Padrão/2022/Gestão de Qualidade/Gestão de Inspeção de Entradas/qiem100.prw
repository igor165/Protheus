#INCLUDE "PROTHEUS.CH" 
#Include "QIEM100.ch" 
#Include "Colors.ch" 
#include "font.ch"  

/*
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
���������������������������������������������������������������������������Ŀ��
���Fun��o	 �QIEM100   � Autor � Cleber Souza          � data � 18/05/04   ���
���������������������������������������������������������������������������Ĵ��
��� DESCRICAO� Rotina de Administracao do arquivo TXT de importacao.	    ���
���������������������������������������������������������������������������Ĵ��
��� USO      � SIGAQIE                                                      ���
���������������������������������������������������������������������������Ĵ��
��� ATUALIZACOES SOFRIDAS DESDE A CONSTRUCAO INICIAL.                       ���
���������������������������������������������������������������������������Ĵ��
��� PROGRAMADOR  � DATA   � BOPS �  MOTIVO DA ALTERACAO                     ���
���������������������������������������������������������������������������Ĵ��
���              �        �      �											���
����������������������������������������������������������������������������ٱ�
�������������������������������������������������������������������������������
�������������������������������������������������������������������������������
*/    
Function QIEM100() 

Local oGroup1  
Local oGroup2
Local oFont1
Local oFont2

Local aCpoTxt   := {}
Local nHandle   := 0
Local cString   := ""
Local nOpcA     := 0

Local aColsAux := {}
Local aHeadAux := {} 
               
Private oNomSal
Private oCheck                             
Private oGetApr

Private cArqImp := GetMv("MV_QTXTIMP") 
Private cNomSal := Space(40)
Private lCheck  := .F.

Private hOk     := LoadBitmap(GetResources(),"LBOK")  //OK
Private hNo     := LoadBitmap(GetResources(),"LBNO")  //Nao OK  

Private nPosCpo := 0
Private nPosIni := 0
Private nPosFim := 0  
Private nPosTam := 0  
Private nPosTit := 0 
Private nPosTip := 0 
Private nPosDec := 0 
Private nPosBrc := 0 

//Verifica o caminho para gravacao do layout padrao,caso o mesmo nao exista
If !File(cArqImp)

	//layout padrao para o arquivo de Importacao
	Aadd(aCpoTxt,"00010006QEP_FORNEC")
	Aadd(aCpoTxt,"00070008QEP_LOJFOR")
	Aadd(aCpoTxt,"00090023QEP_PRODUT")
	Aadd(aCpoTxt,"00240031QEP_DTENTR")
	Aadd(aCpoTxt,"00320036QEP_HRENTR")
	Aadd(aCpoTxt,"00370052QEP_LOTE  ")
	Aadd(aCpoTxt,"00530068QEP_DOCENT")
	Aadd(aCpoTxt,"00690076QEP_TAMLOT")
	Aadd(aCpoTxt,"00770084QEP_TAMAMO") 
	Aadd(aCpoTxt,"00850094QEP_PEDIDO")
	Aadd(aCpoTxt,"00950100QEP_NTFISC")
	Aadd(aCpoTxt,"01010103QEP_SERINF")
	Aadd(aCpoTxt,"01040111QEP_DTNFIS")
	Aadd(aCpoTxt,"01120117QEP_TIPDOC")
	Aadd(aCpoTxt,"01180129QEP_CERFOR")  
	Aadd(aCpoTxt,"01300133QEP_DIASAT")
	Aadd(aCpoTxt,"01340143QEP_SOLIC ")
	Aadd(aCpoTxt,"01440155QEP_PRECO ")
	Aadd(aCpoTxt,"01560156QEP_EXCLUI")  

	nHandle := fCreate(cArqImp)
	Aeval(aCpoTxt,{|x|cString:=x+Chr(13)+Chr(10),fWrite(nHandle,cString)})
	fClose(nHandle)

EndIf	

QE100Load(@aColsAux,@aHeadAux)

//Sugere salvar como nome padrao
cNomSal := cArqImp

DEFINE MSDIALOG oDlg TITLE STR0001 From 020,000 To 560,600 OF oMainWnd Pixel  //"Administra��o TXT de Importa��o"	  	
DEFINE FONT oFont1 NAME "Arial" SIZE 0,-11 BOLD
DEFINE FONT oFont2 NAME "Arial" SIZE 0,-11 

@ 015,003 GROUP oGroup1 TO 237,298	LABEL "" OF oDlg PIXEL  
oGroup1:oFont:= oFont1

@ 240,003 GROUP oGroup2 TO 268,298	LABEL "" OF oDlg PIXEL  
oGroup2:oFont:= oFont1 

oGetApr := MsNewGetDados():New(19,5,235,296,GD_UPDATE,,,"",,,,,,,oDlg,aHeadAux,aColsAux)
oGetApr:AddAction("OK1",{||QE100ACEOK()})

//For�a apenas a visualiza��o dos campos.
oGetApr:aInfo[nPosTam,5]:='V'
oGetApr:aInfo[nPosCpo,5]:='V'
oGetApr:aInfo[nPosTit,5]:='V'
oGetApr:aInfo[nPosTip,5]:='V'
oGetApr:aInfo[nPosDec,5]:='V'
oGetApr:aInfo[nPosBrc,5]:='V'
 
@ 250,008 SAY  OemToAnsi(STR0002)    Of oDlg PIXEL FONT oFont2 //"Salvar como : "  
@ 250,050 MSGET oNomSal    VAR cNomSal SIZE 080,8 PIXEL Of oDlg
@ 250,180 CHECKBOX oCheck  VAR lCheck PROMPT OemToAnsi(STR0003) OF oDlg SIZE 95,11 PIXEL  //"Deseja Substituir arquivo existente." 

ACTIVATE MSDIALOG oDlg ON INIT EnchoiceBar(oDlg,{||IIF(QE100TUDOK(),(nOpcA:=1,oDlg:End()),.F.)},{||nOpcA:=0,oDlg:End()}) CENTERED 

If nOpcA==1
	QE100GRVALL()
endIF	

Return(NIL) 

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 � QE100Load � Autor �Cleber L. Souza 		� Data �18/05/2004���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Monta aHeader e aCols com os campos para escolha           ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QE100Load(EXPA1,EXPA2)		     						  ��� 
�������������������������������������������������������������������������Ĵ��
���Parametros� EXPA1 - Array com os Itens (aCols)						  ���
���          � EXPA2 - Array com as Colunas (aHeader)					  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � NENHUM													  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIEM100													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Static Function QE100Load(aCols,aHeader)

Local bHeadMed
Local cAlias
Local cQuery
Local cIndex
Local nHandle
Local nTamArq := 0
Local nTamLin := 0
Local nBytes  := 0                  
Local xBuffer
Local nY      := 0
Local nX
Local aStrut

//Monta aHeader 
Aadd(aHeader,{"OK"   ,"OK1"   ,"@BMP",03,0,""  			  ,""               ,"C","","","",""})
Aadd(aHeader,{STR0004,"CAMPO" ,"@!"  ,15,0,""			      ,"���������������","C","","","",""}) //"Campo"     
Aadd(aHeader,{STR0005,"TITULO","@!"  ,25,0,""                ,"���������������","C","","","",""}) //"Titulo"  
Aadd(aHeader,{STR0006,"INIC"  ,"@!"  ,04,0,"QE100VALPOS('I')",""               ,"C","","","",""}) //"Inicio"  
Aadd(aHeader,{STR0007,"FIM"   ,"@!"  ,04,0,"QE100VALPOS('F')",""               ,"C","","","",""}) //"Fim"  
Aadd(aHeader,{STR0008,"TAM"   ,"@999",03,0,""			      ,"���������������","N","","","",""}) //"Tamanho"    
Aadd(aHeader,{STR0009,"TIPO"  ,"@!"  ,01,0,""				  ,"���������������","C","","","",""}) //"Tipo"     
Aadd(aHeader,{STR0010,"DEC"   ,"@9"  ,01,0,""				  ,"���������������","N","","","",""}) //"Decimal"  
Aadd(aHeader,{""     ,"BRC"   ,"@!"  ,01,0,""				  ,"���������������","C","","","",""})  

aStrut := FWFormStruct(3,"QEP",,.F.)[3]
For nX := 1 to Len(aStrut)
	aadd(aCols,Array(Len(aHeader)+1))
	aCols[Len(aCols),1] := hNo
	aCols[Len(aCols),2] := aStrut[nX,1] 
	aCols[Len(aCols),3] := QAGetX3Tit(aStrut[nX,1])
	aCols[Len(aCols),4] := "9999" 
	aCols[Len(aCols),5] := "9999"
	aCols[Len(aCols),6] := GetSx3Cache(aStrut[nX,1],"X3_TAMANHO") 
	aCols[Len(aCols),7] := GetSx3Cache(aStrut[nX,1],"X3_TIPO") 
	aCols[Len(aCols),8] := GetSx3Cache(aStrut[nX,1],"X3_DECIMAL") 
	aCols[Len(aCols),Len(aHeader)+1] := .F. 
Next nX

//Pesquisa posicao das Colunas na aCols
nPosCpo := Ascan(aHeader,{|x|Alltrim(x[2])=="CAMPO"}) 
nPosIni := Ascan(aHeader,{|x|Alltrim(x[2])=="INIC"}) 
nPosFim := Ascan(aHeader,{|x|Alltrim(x[2])=="FIM"})   
nPosTam := Ascan(aHeader,{|x|Alltrim(x[2])=="TAM"})
nPosTit := Ascan(aHeader,{|x|Alltrim(x[2])=="TITULO"}) 
nPosTip := Ascan(aHeader,{|x|Alltrim(x[2])=="TIPO"}) 
nPosDec := Ascan(aHeader,{|x|Alltrim(x[2])=="DEC"}) 
nPosBrc := Ascan(aHeader,{|x|Alltrim(x[2])=="BRC"})    

//Pesquisa campos do TXT
nHandle := fOpen(cArqImp,2+64)

//Posiciona no arquivo
nTamArq := fSeek(nHandle,0,2)
nTamLin := 20
fSeek(nHandle,0,0)

While nBytes < nTamArq
	xBuffer := Space(nTamLin)
	fRead(nHandle,@xBuffer,nTamLin)

	nPosCp := Ascan(aCols,{|x|Alltrim(x[2])==AllTrim(SubStr(xBuffer,9,10))}) 
	If nPosCp>0
		aCols[nPosCp,1] := hOK
		aCols[nPosCp,nPosIni] := SubStr(xBuffer,1,4) 
   		aCols[nPosCp,nPosFim] := SubStr(xBuffer,5,4)
	EndIF	    

	nBytes+=nTamLin
EndDo

//Fecha o arquivo de configuracao
fClose(nHandle)

//Organiza array na tela em ordem de campo para verifica��o do usu�rio.
ASORT(aCols,,,{|x,y| x[4]+x[5] < y[4]+y[5] }) 
Aeval(aCols,{|x,y|aCols[y,nPosIni]:=IIF(aCols[y,nPosIni]=="9999",Space(4),aCols[y,nPosIni])})
Aeval(aCols,{|x,y|aCols[y,nPosFim]:=IIF(aCols[y,nPosFim]=="9999",Space(4),aCols[y,nPosFim])})

Return   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �QE100ACEOK � Autor �Cleber L. Souza 		� Data �18/05/2004���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Atualiza os BMPs de marcado e desmarcado.				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QE100ACEOK					     						  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� NENHUM													  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � NIL														  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIEM100													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QE100ACEOK() 
   
If oGetApr:aCols[oGetApr:nAT,1] == hOk
	oGetApr:aCols[oGetApr:nAT,1] := hNo
Else
	oGetApr:aCols[oGetApr:nAT,1] := hOk
EndIf	

oGetApr:Refresh()                                       

Return(Nil)  

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �QE100TUDOK � Autor �Cleber L. Souza 		� Data �18/05/2004���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Atualiza os BMPs de marcado e desmarcado.				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QE100TUDOK					     						  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� NENHUM													  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � EXPL1 - Retorno da Valida��o das Infos digitadas.		  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIEM100													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QE100TUDOK()
            
Local lRet  := .T.
Local aCols := oGetApr:aCols	
Local nY    := 0

For nY:=1 to Len(aCols)

	If aCols[nY,1] == hOK .and. (  Empty(aCols[nY,nPosIni]) .or. Empty(aCols[nY,nPosFim]) )
		Help("  ",1,"QIEM10001") //"Existem campos selecionados sem Posi��o Inicial ou Final"
		lRet := .F.                                                         
		Exit
	Endif	
		       
	If aCols[nY,1] == hNO .and. ( !Empty(aCols[nY,nPosIni]) .or. !Empty(aCols[nY,nPosFim]) )
		Help("  ",1,"QIEM10002") //"Existem campos com posi��o Inicial/Final preenchidos que n�o foram selecionados."
		lRet := .F.                                                         
		Exit
	EndIf

Next nY	   

If lRet
	If Empty(cNomSal)
		Help("  ",1,"QIEM10003") //"� obrigat�rio a digita��o do nome do arquivo TXT."
		lRet := .F.  
    EndIF
EndIf                                                                                      

If lRet
	If File(cNomSal) .and. !lCheck
		Help("  ",1,"QIEM10004") //"O arquivo informado j� existe, para substitui-lo, favor informar na tela de administra��o do TXT."
		lRet := .F.  
	EndIF
EndIf

Return(lRet)   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �QE100GRVALL� Autor �Cleber L. Souza 		� Data �18/05/2004���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Atualiza os BMPs de marcado e desmarcado.				  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QE100GRVALL					     						  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� NENHUM													  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � NIL														  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIEM100													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QE100GRVALL()
                
Local aCpoTxt := {}
Local nY      := 0
Local aCols   := oGetApr:aCols  

If File(cNomSal) .and. lCheck
	If !FileDelete( cNomSal )
		Help("  ",1,"QIEM10005") //Nao foi possivel criar novo arquivo TXT pois o antigo n�o foi pode ser deletado.
		Return(NIL)
	EndIf	
EndIf    

For nY:=1 to Len(aCols)
	If aCols[nY,1]==hOK
		Aadd(aCpoTxt,StrZero(Val(aCols[nY,nPosIni]),4)+StrZero(Val(aCols[nY,nPosFim]),4)+PadR(Alltrim(aCols[nY,nPosCpo]),10))
	EndIF
Next nY
	
nHandle := fCreate(cNomSal)
Aeval(aCpoTxt,{|x|cString:=x+Chr(13)+Chr(10),fWrite(nHandle,cString)})
fClose(nHandle)

Return(NIL)   

/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Fun�ao	 �QE100VALPOS� Autor �Cleber L. Souza 		� Data �18/05/2004���
�������������������������������������������������������������������������Ĵ��
���Descri�ao � Valida os campos de posi��o Inicial e Final dos campos.	  ���
�������������������������������������������������������������������������Ĵ��
���Sintaxe	 � QE100VALPOS					     						  ���
�������������������������������������������������������������������������Ĵ��
���Parametros� EXPC1 - Indica se e campo Inicio (I) ou Final (F)		  ���
�������������������������������������������������������������������������Ĵ��
���Retorno	 � EXPL1 - Retorno logico com a valida��o do campo.			  ���
�������������������������������������������������������������������������Ĵ��
��� Uso		 � QIEM100													  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/
Function QE100VALPOS(cCpo)

Local lRet := .T.
Local nAT  := oGetApr:nAT

If cCpo=="I"
	oGetApr:aCols[nAT,nPosFim] := StrZero(Val(&(ReadVar())) + oGetApr:aCols[nAT,nPosTam] - 1,4)	           
	oGetApr:Refresh()
Else 
	If &(ReadVar()) < oGetApr:aCols[nAT,nPosIni]
		lRet := .F.
	EndIF			
EndIF

Return(lRet)