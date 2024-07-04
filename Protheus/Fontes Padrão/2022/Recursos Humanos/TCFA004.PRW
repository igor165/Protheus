#INCLUDE "PROTHEUS.CH"
#INCLUDE "TCFA004.CH"
#INCLUDE "FILEIO.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณ TCFA004  ณ Autor ณ Marcelo Faria                     ณ Data:ณ 03.04.2012 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Controle de acesso aos dados do funcionario (Baseado GPEA260)            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ Generico                                                                 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ         ATUALIZACOES SOFRIDAS DESDE A CONSTRU€AO INICIAL.                           ณฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณAnalista     ณ Data     ณ FNC / Tarefa   ณ  Motivo da Alteracao                      ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤณฑฑ
ฑฑณCecilia Car. ณ24/07/2014ณTQEA22          ณIncluido o fonte da 11 para a 12 e efetuadaณฑฑ
ฑฑณ             ณ          ณ                ณa limpeza.                                 ณฑฑ
ฑฑณFlavio Correaณ01/06/2015ณPCDEF-36017     ณAjustes na ordena็ใo dos campos            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function TCFA004()

//--Monta o Array com os Campos do sx3 e quando usado marca com x
Private aDicio   := {}          
Private aDicioT  := {}		//Array contendo os campos do SX3
Private aDicioW	:= {} 		//Array auxiliar do aDicioT
Private aDicioA	:= {} 		//Array auxiliar do aAgrup
Private aAgrup	:= {}		//Array contendo os agrupamentos cadastrados no TcfPortal
Private nAgrup	:= 01
Private nCampo	:= 0

//--Funcao para atualizar a configuracao da ficha
Tcf004FhcConf()
//--Funcao para configurar o dicionario
Tcf004Dic()

Return( NIL )


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณTcf004FhcConf ณAutorณMarcelo Faria        ณ Data ณ03/04/2012ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Verifica se Existe o Arquivo e Configura o array do Sx3    ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ TCFA004                                                    ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function Tcf004FhcConf()

Local cFile  	:= "TcfPortal.fch"
Local aDicFch 	:= {}
Local aAGrup		:= {}
Local n,nTamArq ,nBuffer 
Local cBuffer, nPos

dbSelectArea("SX3")
dbSetOrder(1)
dbSeek("SRA")
While ! Eof() .And. SX3->X3_ARQUIVO = 'SRA'
	uCampo := SX3->X3_CAMPO
	If (__lPyme	.and. SX3->X3_PYME="N" ) 
		SX3->(dbSkip())
		loop
	Endif

   	IF 	SX3->X3_CONTEXT == 'V'
		SX3->(dbSkip())
		loop
   	EndIf

	nCampo := nCampo + 1 
    If cPaisLoc == "BRA"
		Aadd(aDicioT, X3Titulo()+Space(14)+CHR(179)+"["+If (X3USO(x3_usado),"X"," ")+"]"+Space(5)+SX3->X3_CAMPO+Space(3)+STRZERO(SX3->X3_tamanho,3)+STRZERO(SX3->X3_DECIMAL,2)+ strzero(nAgrup,2)+ Strzero(nCampo,3) )
	Else
		If X3USO(SX3->X3_USADO)
			Aadd(aDicioT, X3Titulo()+Space(14)+CHR(179)+"["+If (X3USO(x3_usado),"X"," ")+"]"+Space(5)+SX3->X3_CAMPO+Space(3)+STRZERO(SX3->X3_tamanho,3)+STRZERO(SX3->X3_DECIMAL,2)+ strzero(nAgrup,2)+ Strzero(nCampo,3) )
		Endif
	EndIf
	dbSkip()
Enddo

If File("TcfPortal.fch")

	//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	//ณ Le arquivo texto - Nro total de linhas     ณ
	//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
	nHdl    := Fopen(cfile,2+64)	//Abertura e gravacao e compartilhamento
	If nHdl <= 0
		return .f. 
	EndIf
	
	cString	:= FReadStr(nHdl,60)
	nBuffer	:= 60
	nTamArq 	:= fSeek(nHdl,0,2)

	fSeek(nHdl,0,0)
	nFor 	:= nTamArq / nBuffer
	cBuffer	:= space(nBuffer)
	FRead(nHdl,@cBuffer,nBuffer)
	
	For n=1 to nFor
		If left(cBuffer,5)="Agrup" 
			aAdd(aAgrup,cBuffer)
		Else
			Aadd(aDicFch,cBuffer)
		Endif	
		cBuffer	:= space(nBuffer)
		FRead(nHdl,@cBuffer,nBuffer)
	Next n
        
	For n:= 1 to Len(aDicioT)
		nPos := Ascan(aDicFch,{ |x| Subs(x,36,10)=Subs(aDicioT[n],36,10) })
		If nPos > 0
			aDicioT[n] := Subs(ADicioT[n],1,28)+Subs(aDicFch[nPos],29,1)+']'+Subs(aDicioT[n],31,23)+Subs(aDicFch[nPos],54,2)+Subs(aDicFch[nPos],56,3) //mantem a ordem determinada pelo usuario
		Endif
	Next n
	FClose(nHdl)
Else
	aAgrup	:= {}
	aAdd(aAgrup,"Agrup" +space(4)+"01"+STR0001+ space(28) )
	aAdd(aAgrup,"Agrup" +space(4)+"02"+STR0002+ space(28) )
	aAdd(aAgrup,"Agrup" +space(4)+"03"+STR0003+ space(28) )
EndIf

aDicioA := {}
Aeval(aAgrup,{ |x| Aadd(aDicioA,{Subs(x,1,05),;
		 					  Subs(x,10,02),;	//Agrupamento
							  Subs(x,12,20); 	//Descricao
							  })})

aDicioT	:= aSort(aDicioT,,,{|x,y| Substr(x,54,2)+ Substr(x,56,3) < Substr(y,54,2)+Substr(y,56,3)})
aAgrup	:= aSort(aAgrup,,,{ |x,y| substr(x,10,2) < SUBSTR(Y,10,2)})
aDicioA	:= aSort(aDicioA,,,{ |x,y| x[2] < y[2] })

Return Nil


/*/
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuncao    ณ Tcf004Dicณ Autor ณ Marcelo Faria         ณ Data ณ03/04/2012ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescricao ณ Achoice para escolha do Sx3 para a ficha                   ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณ TCF004                                                     ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿*/
Function Tcf004Dic()
Local cDet
Local cText
Local oFont3
Local oFont
Local oFont06
Local oBar
Local oBtn1
Local oBtnMarcTod
Local oBtnDesmTod
Local oBtnInverte
Local oGroup1
Local oGroup2
Local bSet15
Local bSet24

Local cFile  		:= "TcfPortal.fch"
Local cFilRHW		:= xFilial("RHW")
Local cBuffer		:= ""
Local cPara			:= "   "
Local n,x   			:= 0 
Local nHdl			:= 0 
Local nOpt			:= 0                       
Local aDicBkp 		:= Aclone(aDicioT)
Local bNIL			:= { || NIL }
Local bSvVK_F4		:= bNIL
Local bSvVK_F5		:= bNIL
Local bSvVK_F6		:= bNIL 
Local aReserv		:= {} 
Local lMultSelect		:= .T. 
Local aButtons 		:= {}
Local lVolta 		:=.f.

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declaracao de arrays para dimensionar tela		             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords		:= {}	
		
Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}	
Local aObj2Coords 	:= {}	
	
Local aAdv3Size		:= {}
Local aInfo3AdvSize	:= {}
Local aObj3Size		:= {}	
Local aObj3Coords 	:= {}

Private  cGrupo		:= "  " 
Private  aGrupos 	:= {}
Private  l1Elem		:= .F.
Private  lFirst		:= .T.
Private  oAgrup
Private  oPara
Private  oCima
Private  oBaixo
Private  oOpcao 
Private  oText 
Private  oNext
Private  oPrev
Private  oBtnOrdem
 
oOk := LoadBitmap( GetResources(), "Enable" )
oNo := LoadBitmap( GetResources(), "LBNO" )

aDicioW := {}
Aeval(aDicioT,{ |x| If(substr(x,1,5)#"Agrup" , Aadd(aDicioW,{Subs(x,1,16),;	//Descricao Campo
								   If (Subs(x,29,1) = "X",.t.,.f.),;		//usado ou nao usado
								   Subs(x,36,18) , ;                      //Campo
								   Subs(x,54,2), ;						//Agrupamento
								   Subs(x,56,3) }),"" ) })        			//Ordem
//-- Array Combobox
aAgrupa:={}
Aeval(aDicioA,{|x| aadd(aAgrupa,x[2]+"-"+x[3]) })

//-- Array dos Agrupamentos efetivados
aGrupos:= {}
Aeval(aDiciow,{| x| If(x[4] = substr(aAgrupa[1],1,2), ;
					aAdd(aGrupos,{x[2],x[1],x[4],x[5],x[3]}),"" ) })    		//Usado,Desc.Campo,Agrup,Ordem
					
If Len(aGrupos) <= 0
	Aadd(AGrupos,{.f.,"","","",""})
Endif

cTitulo := oEmToAnsi(STR0004)  											//Dicion rio

SETAPILHA()
/*
ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
ณ Monta as Dimensoes dos Objetos         					   ณ
ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
aAdvSize	:= MsAdvSize()
aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
aAdd( aObjCoords , { 063 , 000 , .T. , .T. } )	//Coluna da esquerda (Selecao de campos para ficha)
aAdd( aObjCoords , { 010 , 000 , .F. , .T. } )	//Seta
aAdd( aObjCoords , { 037 , 000 , .T. , .T. } )	//Coluna da direita (Agrupamento)
aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords, .T., .T. ) 
    
aAdv2Size := aClone(aObjSize[1])				//Clone da Coluna da esquerda

aInfo2AdvSize    := { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 10 }
aAdd( aObj2Coords , { 000 , 000 , .T. , .T., .T. } )
aAdd( aObj2Coords , { 000 , 020 , .T. , .F. } )
aObj2Size := MsObjSize( aInfo2AdvSize , aObj2Coords )

aAdv3Size := aClone(aObjSize[3])				//Clone da coluna da direita

aInfo3AdvSize    := { aAdv3Size[2] , aAdv3Size[1] , aAdv3Size[4] , aAdv3Size[3] , 5 , 10 }
aAdd( aObj3Coords , { 000 , 020 , .T. , .F. } )
aAdd( aObj3Coords , { 000 , 000 , .T. , .T., .T. } )
aObj3Size := MsObjSize( aInfo3AdvSize , aObj3Coords )

aAdd(aButtons, { "BMPORD1", { || fOrdena(@aGrupos,aGrupos[oOpcao:nAt,3]) } , OemToAnsi(STR0005) } ) // "Ordenar"
aAdd(aButtons, { "S4WB005N", { || fAgrupa(aAgrupa,oAgrup) }, OemToAnsi( STR0006 ) } ) // "Agrupa"

DEFINE FONT oFont3  NAME "Arial" BOLD
DEFINE FONT oFont   NAME "Arial" SIZE 0,-11 
DEFINE FONT oFont06 NAME "Arial" SIZE 01,01
//-- Atualiza Array com os campos agrupados 
DEFINE MSDIALOG oDlg4 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cTitulo PIXEL

	bSet15 := {|| lLoop:=lVolta,(If( !f260Vazio(aDicBkp) , (nOpt := 1.00 , oDlg4:End(),.F.), ( nOpt := 0 )))}
	bSet24 := {|| lLoop:=.f.,(nOpt := 3,oDlg4:End()),ButtonOff(bSet15,bSet24,.T.)}
			      
	@ aObjSize[1,1],aObjSize[1,2] Group oGroup1 To aObjSize[1,3],aObjSize[1,4] PROMPT OemToAnsi(STR0007) Of oDlg4 Pixel COLOR CLR_BLUE //Selecao de Campos para Ficha
	@ aObjSize[3,1],aObjSize[3,2] Group oGroup2 To aObjSize[3,3],aObjSize[3,4] PROMPT OemToAnsi(STR0008) Of oDlg4 Pixel COLOR CLR_BLUE //Agrupamento
	
	//--ListBox do Dicionario de dados
	@ aObj2Size[1,1],aObj2Size[1,2] LISTBOX oUso;
			FIELDS HEADER STR0009,STR0010,Left(STR0008,5),STR0011;  //"U."###"Campos/Agrupamento / ordem
			SIZE aObj2Size[1,3],aObj2Size[1,4] ;
			ON DBLCLICK (aDicioW:= fTroca(aDicioW,,oUso:nAT), If(substr(cGrupo,1,2)== aDicioW[oUso:nAt,4],aGrupos:=fGrupos(aDicioW,aDicioW[oUso:nAt,4]),aGrupos),oOpcao:Refresh() , oUso:Refresh(.f.) ) ;
			OF oDlg4 PIXEL
			oUso:SetArray(aDicioW)
			oUso:bLine := { || {if(aDicioW[oUso:nAt,2],oOk,oNo),OemToAnsi(aDicioW[oUso:nAt,1]),aDicioW[oUso:nAt,4],aDicioW[oUso:nAt,5] }}
			oUso:Refresh()
	
	//--  Botoes Usado/Nao Usado 						
	@ aObj2Size[2,1]+5, aObj2Size[2,2] BUTTON oBtnMarcTod	PROMPT OemToAnsi(STR0012) FONT oFont06	SIZE 65,13 OF oDlg4	PIXEL  ;
      ACTION (aDicioW:=fTroca(aDicioW,"M"),aGrupos:=fGrupos(aDicioW,substr(cGrupo,1,2) ),oUso:Refresh(),oOpcao:Refresh()) //"Marca Todos - <F4>"
      bSvVK_F4 := SetKey(VK_F4,{ || (aDicioW:=fTroca(aDicioW,"M"),oUso:Refresh()) } )
	@ aObj2Size[2,1]+5, aObj2Size[2,2]+70 BUTTON oBtnDesmTod	PROMPT OemToAnsi(STR0013) FONT ofont06	SIZE 65,13 OF oDlg4	PIXEL ;
	  ACTION (aDicioW:=fTroca(aDicioW,"D"),aGrupos:=fGrupos(aDicioW,substr(cGrupo,1,2) ),oUso:Refresh(),oOpcao:Refresh()) //"Desmarca Todos - <F5>"
   	  bSvVK_F6 := SetKey(VK_F5,{ || (aDicioW:=fTroca(aDicioW,"D"),oUso:Refresh()) } )
	@ aObj2Size[2,1]+5, aObj2Size[2,2]+140 BUTTON oBtnInverte	PROMPT OemToAnsi(STR0014) FONT ofont06	SIZE 65,13 OF oDlg4	PIXEL ;
	  ACTION (aDicioW:=fTroca(aDicioW,"I"),aGrupos:=fGrupos(aDicioW,substr(cGrupo,1,2) ),oUso:Refresh(),oOpcao:Refresh()) //"Inverte Seleo - <F6>"
	  bSvVK_F6 := SetKey(VK_F6,{ || (aDicioW:=fTroca(aDicioW,"I"),oUso:Refresh()) } )
	
	
	//-- Agrupa os Campos selecionados 
	@ aObjSize[2,3]-aObjSize[2,1],aObjSize[2,2]*2 BTNBMP oNext   Resource 'NEXT' NO BORDER   Size 30,25 Design ;
	        ACTION(fCadAGrup(4,oUso:nAt,oUso,aDicioW,cGrupo,.F.) ) OF oDlg4  PIXEL//-- marca somente 1

	//-- Retorna os Campos selecionados 
	@ aObjSize[2,3]-aObjSize[2,1]+40,aObjSize[2,2]*2 BTNBMP oPrev   Resource 'PREV' NO BORDER   Size 30,25 Design ;
	        ACTION(fCadReturn(oUso,aDicioW) ) OF oDlg4  PIXEL//-- marca somente 1

	//-- Listbox dos Agrupamento efetivados
	@ aObj3Size[2,1], aObj3Size[2,2] LISTBOX oOpcao;
			FIELDS HEADER STR0009,STR0010,Left(STR0008,5),STR0011;  //"U."###"Campos/Agrupamento / ordem
			SIZE aObj3Size[2,3], aObj3Size[2,4] OF oDlg4 PIXEL ;
			oOpcao:SetArray(aGrupos)
			oOpcao:bLine := { || {If(aGrupos[oOpcao:nAt,1],oOk,oNo),OemToAnsi(aGrupos[oOpcao:nAt,2]),aGrupos[oOpcao:nAt,3],aGrupos[oOpcao:nAt,4] }}
			oOpcao:Refresh()
           
	//-- COMBOBOX dos Grupos cadastrados
	@ aObj3Size[1,1], aObj3Size[1,2] MSCOMBOBOX oAgrup ;							//Objeto Combo
			VAR    cGrupo  ;
			ITEMS  aAgrupa ;		                    	//Array dos agrupamentos existentes
			SIZE   080,200  OF oDlg4 PIXEL ;
            ON CHANGE ( aGrupos:=fGrupos(aDicioW,substr(cGrupo,1,2),oOpcao:Refresh()))
			oAgrup:Setitems(aAgrupa)
			oAgrup:Refresh()
    
			
ACTIVATE MSDIALOG oDlg4 ON INIT EnchoiceBar( oDlg4 , bSet15 , bSet24 , Nil , aButtons ) CENTERED

SETAPILHA()

SetKey( VK_F4	,	IF( Empty( bSvVK_F4 ) , bNIL , bSvVK_F4 ) )
SetKey( VK_F5	,	IF( Empty( bSvVK_F5 ) , bNIL , bSvVK_F5 ) )
SetKey( VK_F6	,	IF( Empty( bSvVK_F6 ) , bNIL , bSvVK_F6 ) )

//--volta o Array da tela para o aDicioT para ser gravado
If nOpt == 1
	aDicioT := {}
	nAGrup:= Len(aAgrupa)
	For n=1 to nAgrup
		aAdd(aDicioT, "Agrup"+space(4)+ subs(aAgrupa[n],1,2)+ subs(aAgrupa[n],4,20) + space(27) )
	Next n
	Aeval(aDicioW,{ |x| Aadd(aDicioT,Subs(x[1],1,12)+Space(14)+CHR(179)+"["+If (x[2],"X"," ")+"]"+Space(5)+x[3]+x[4]+x[5] )})
Endif 

DeleteObject(oOk)
DeleteObject(oNo)


//--Quando confirma grava o Arquivo TcfPortal.fch
If nOpt == 1
    DbSelectArea("RHW")
	dbSetOrder(1)
	
	nHdl := MSFCREATE(cFile,FC_NORMAL)
	If nHdl == -1   .or. fError() # 0 
		Help(" ",1,"SAVECONS")
	Else
		For n=1 to Len(aDicioT)
			cDet	:= aDicioT[n]+Chr(13)+Chr(10)
			fWrite(nHdl,cDet,Len(cDet) )

			If Alltrim(SubStr(cDet,36,13)) != ""
				If !RHW->(dbSeek(cFilRHW+"SRA"+SubStr(cDet,36,10))) 
				   	RecLock("RHW",.T.)
					RHW->RHW_FILIAL 	:= cFilRHW
					RHW->RHW_TABELA 	:= "SRA"
					RHW->RHW_CAMPO	:= SubStr(cDet,36,10) 
	
					For x=1 to nAgrup
						If subs(aAgrupa[x],1,2) == Subs(cDet,54,2) 
							RHW->RHW_GRUPO     := Alltrim(aAgrupa[x])
							exit
						Endif
					Next x
	
					RHW->RHW_SEQ  	:= val(SubStr(cDet,56,3))
					IF SubStr(cDet,29,1) == "X"
						RHW->RHW_ACAO	:= "C"
					Else
						RHW->RHW_ACAO	:= ""
					EndIF	
					MsUnLock()
				Else
				   	RecLock("RHW",.F.)
	
					If SubStr(RHW->RHW_GRUPO,1,2) != SubStr(cDet,54,2)
						For x=1 to nAgrup
							If subs(aAgrupa[x],1,2) == Subs(cDet,54,2) 
								RHW->RHW_GRUPO     := Alltrim(aAgrupa[x])
								exit
							Endif
						Next x
					EndIf
					
					If RHW->RHW_SEQ   != val(SubStr(cDet,56,3))
						RHW->RHW_SEQ  := val(SubStr(cDet,56,3))
					EndIf
				
					IF SubStr(cDet,29,1) == "X"
						RHW->RHW_ACAO	:= "C"
					Else
						RHW->RHW_ACAO	:= ""
					EndIF	
					MsUnLock()
				EndIf
			EndIf
			
		Next
	EndIf
	FClose(nHdl)    //Fecha arq.binario e grava no disco 
Else
	aDicioT	:= Aclone(aDicBkp)
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfGrupos   บAutor  ณMicrosiga -Natie    บ Data ณ  02/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta  Array dos Campos Agrupados                           บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fGrupos(aGrupAux,nUso)

Local n
	aGrupos:= {} 
	For n:= 1 to Len(aGrupAux)
		If nUso == aGrupAux[n,4]
			Aadd(Agrupos,{aGrupAux[n,2], aGrupAux[n,1],aGrupAux[n,4],aGrupAux[n,5],aGrupAux[n,3] } )
		Endif
	next n 

	If Len(aGrupos) <= 0   //.and. lFirst   
		Aadd(AGrupos,{.f.,"","","",""})
		lFirst	:= .F.
	Endif  
	oOpcao:SetArray(aGrupos)
	oOpcao:bLine := { || {If(aGrupos[oOpcao:nAt,1],oOk,oNo),OemToAnsi(aGrupos[oOpcao:nAt,2]),aGrupos[oOpcao:nAt,3],aGrupos[oOpcao:nAt,4] }}
	oOpcao:Refresh()
	
	fAtivaBtn(aGrupos,oBtnOrdem)
	
Return aGrupos


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfAtivaBtn บAutor  ณMicrosiga -Natie    บ Data ณ  25/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณHabilita/desabilita botao da fchoice de acordo com o agrupa-บฑฑ
ฑฑบ          ณmento escolhido                                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณgpea260                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fAtivaBtn(aLbx,oBtnAux)

If Type("oBtnOrdem") # "U" 
	If len(aLbx) > 0  .and. aLbx[1,3] # ""
		oBtnAux:enable()
	Else	
		oBtnAux:disable()
	Endif	
Endif	

Return .T.
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณf260Vazio บAutor  ณMicrosiga -Natie    บ Data ณ  06/04/04   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณVerifica se array dos campos possui pelo menos 01 campo seleบฑฑ
ฑฑบ          ณcionado para visualizacao ou impressao da Ficha             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณgpea260                                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function f260Vazio(aDicBkp) 
Local nX   		:= 0
Local lVazio 	:= .T.

For nX:= 1 to Len(aDicioW)
	If aDicioW[nX,2]
		lVazio	:= .F. 
	Endif 
Next nX

If lVazio 
	aDicioT	:= Aclone(aDicBkp)
	Help(" ",1,"A260CPO") 	//-- "Para que a Ficha seja visualizada ou impressa, e necessario selecionar os campos desejados.## " 
Endif

Return(lVazio)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfTroca    บAutor  ณMicrosiga -Natie    บ Data ณ  02/04/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a troca da selecao no ListBox                        บฑฑ
ฑฑบ          ณ(controle Usado/nao usado )                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fTroca( aArray,		; //Array contendo os elementos para troca
					   cTipo  ,		; //Tipo da Multipla Selecao "M"Marca todos ; "D" Desmarca Todos; "I" Inverte Selecao
					   nEstou ,		; //oUso:nAt
	                   l1Elem)       //So pode escolher um  unico elemento usado no Array (.t.)
	                   
Local nArray	:= 0 
Local nX		:= 0
DEFAULT l1Elem	:= .F.
		
	If l1Elem 
		nArray:= Len(aArray)
		For nX := 1 To nArray
			IF nX == nEstou
				aArray[nEstou,4]	:= .T.
			Else
				aArray[nX,4]		:= .F. 
			EndIF
		Next nX	
	    oAgrup:SetArray(aArray)
		oAgrup:bLine := { || {if(aArray[oAgrup:nAT,4],oOk,oNo),aArray[oAgrup:nAt,2],aArray[oAgrup:nAt,3]}}
	Else
		IF cTipo == "M"
			aEval( aArray , { |x,y| aArray[y,2] := .T. } )
		ElseIF cTipo == "D"
			aEval( aArray , { |x,y| aArray[y,2] := .F. } )
		ElseIF cTipo == "I"
			aEval( aArray , { |x,y| aArray[y,2] := !aArray[y,2] } )
		Else
			aArray[nEstou,2] := !aArray[nEstou,2]
		EndIF
		
    Endif

Return aArray

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfAgrupa() บAutor  ณMicrosiga -Natie    บ Data ณ  11/06/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua Cadastramento/alteracao de agrupamentos              บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fAgrupa(aLbxBkp,oAGrupAux)	
Local cTitulo	:= ""
Local cDet 		:= ""
Local nOpt1		:= 0
Local nHdl		:= 0
Local nAGrup	:= 0 
Local n			:= 0 
Local cFile  	:= "GpeFicha.fch"
Local aDicAgr	:= aClone(aLbxBkp)              // Agrupamentos
Local oFont3
Local oBtn1
Local oBtn2
Local oBtn3
Local oGroup2
Local oGroup0
Local oOk
Local oNo
Local oAtu
Local oDlg5
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declara็ใo de arrays para dimensionar tela		                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
	
Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}	
Local aObj2Coords 	:= {}
	
Local aAdv3Size		:= {}
Local aInfo3AdvSize	:= {}
Local aObj3Size		:= {}	
Local aObj3Coords 	:= {}

Private cAgrup	:= space(2)
Private cDescr	:= space(20)

	oOk := LoadBitmap( GetResources(), "Enable" )
	oNo := LoadBitmap( GetResources(), "LBNO" )
	
	cTitulo := oEmToAnsi(STR0019)  									//Agrupamentos
	/*
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Monta as Dimensoes dos Objetos         					   ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/
	aAdvSize	:= MsAdvSize( ,.T.,370)
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
		
	aObj2Coords := {}
	aAdv2Size    := aClone(aObjSize[1])
	
	aInfo2AdvSize := { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 10 , 10 }
	aAdd( aObj2Coords , { 000 , 000 , .T. , .T., .T. } )
	aAdd( aObj2Coords , { 000 , 020 , .T. , .F. } )
	aObj2Size := MsObjSize( aInfo2AdvSize , aObj2Coords )
	
	aObj3Coords := {}
	aAdv3Size    := aClone(aObj2Size[2])
	
	aInfo3AdvSize := { aAdv3Size[2] , aAdv3Size[1] , aAdv3Size[4] , aAdv3Size[3] , 3 , 3 }
	aAdd( aObj3Coords , { 000 , 050 , .T. , .T. } )
	aAdd( aObj3Coords , { 000 , 010 , .T. , .F. } )
	aAdd( aObj3Coords , { 000 , 010 , .T. , .F. } )
	aAdd( aObj3Coords , { 000 , 010 , .T. , .F. } )
	aAdd( aObj3Coords , { 000 , 050 , .T. , .T. } )
	aObj3Size := MsObjSize( aInfo3AdvSize , aObj3Coords, ,.T.  )
	
	DEFINE FONT oFont3  NAME "Arial" BOLD	
	DEFINE MSDIALOG oDlg5 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cTitulo PIXEL
		
		@ aObjSize[1,1],aObjSize[1,2] Group oGroup0 To aObjSize[1,3],aObjSize[1,4] Of oDlg5 PIXEL COLOR CLR_BLUE
		
		@ aObj2Size[1,1],aObj2Size[1,2] LISTBOX oAtu ;
		    FIELDS HEADER OemtoAnsi(STR0018),OemToAnsi(STR0017) ;
		    SIZE aObj2Size[1,3],aObj2Size[1,4] OF oDlg5 PIXEL
			oAtu:SetArray(aLbxBkp)
			oAtu:bLine := { || { substr(aLbxBkp[oAtu:nAt],1,2),OemToAnsi(substr(aLbxBkp[oAtu:nAt],4,20)) } }
			oAtu:Refresh()	
	
		@ aObj2Size[2,1],aObj2Size[2,2]  GROUP oGroup2 TO aObj2Size[2,3],aObj2Size[2,4] OF oDlg5  PIXEL COLOR CLR_BLUE
	   
		DEFINE SBUTTON oBtn1 FROM aObj3Size[2,1], aObj3Size[2,2]  TYPE 04 ENABLE OF oDlg5 ;
		       Action (fIncGrupo(@oAtu,@aLbxBkp,oAtu:nAT), oAgrupAux:Refresh())       // Inclui
		DEFINE SBUTTON oBtn2 FROM aObj3Size[3,1], aObj3Size[3,2]  TYPE 11 ENABLE OF oDlg5 ;
		       Action (fEdiGrupo(@oAtu,@aLbxBkp,oAtu:nAT), oAgrupAux:Refresh())       // Edita
		DEFINE SBUTTON oBtn3 FROM aObj3Size[4,1], aObj3Size[4,2]  TYPE 03 ENABLE OF oDlg5 ;
			   Action (fExcGrupo(@oAtu,@aLbxBkp,oAtu:nAT),	oAgrupAux:Refresh())       // Exclui
	
	ACTIVATE DIALOG oDlg5 CENTERED 	
	
	SETAPILHA()     
	
	DeleteObject(oOk)
	DeleteObject(oNo)
	
	//--Atualiza dados
	aDicioT := {}
	aDicioA := {}
	nAGrup:= Len(aLbxBkp)
	For n=1 to nAgrup 
		aAdd(aDicioT, "Agrup"+ space(4)+ substr(aLbxBkp[n],1,2)+substr(aLbxBkp[n],4,20) + space(27))
		aAdd(aDicioA, {"Agrup",substr(aLbxBkp[n],1,2),substr(aLbxBkp[n],4,20)})
	Next n	
	Aeval(aDicioW,{ |x| Aadd(aDicioT,Subs(x[1],1,12)+Space(14)+CHR(179)+"["+If (x[2],"X"," ")+"]"+Space(5)+x[3]+x[4]+x[5] )})
	       	
	aAgrup		:= {}                                                       
	Aeval(aLbxBkp,{ |x| Aadd(aAgrup ,"Agrup"+space(4)+ substr(x,1,2)+ substr(x,4,20)+ space(27)  ) })
	
	//--Quando confirma grava o Arquivo GpeFicha.fch
	nHdl := MSFCREATE(cFile,FC_NORMAL)
	If nHdl == -1   .or. fError() # 0 
		Help(" ",1,"SAVECONS")
	Else
		For n=1 to Len(aDicioT)
			cDet	:= aDicioT[n]+Chr(13)+Chr(10)
			fWrite(nHdl,cDet,Len(cDet) )
		Next
	EndIf
	FClose(nHdl)    //Fecha arq.binario e grava no disco 
Return 

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfIncGrupo บAutor  ณMicrosiga -Natie    บ Data ณ  25/03/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณInsere Agrupamentos                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fIncGrupo(oGrAux,aLbxAx,nEstou)
Local oDlg7
Local nOpt1                      
Local oGroup1,oGroup2
Local oFont3 
Local bSet15
Local bSet24
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declara็ใo de arrays para dimensionar tela		                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}

cAgrup	:= space(2)
cDescr	:= space(20)

oOk := LoadBitmap( GetResources(), "Enable" )
oNo := LoadBitmap( GetResources(), "LBNO" )
	
	cTitulo := oEmToAnsi(STR0020)  									//Inclui
	/*
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Monta as Dimensoes dos Objetos         					   ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/   
	aAdvSize	:= MsAdvSize( ,.T.,090)
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 15 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
	
	DEFINE FONT oFont3  NAME "Arial" BOLD
	DEFINE MSDIALOG oDlg7 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cTitulo PIXEL // FONT oFont3 COLOR CLR_BLUE    

	@ aObjSize[1,1],aObjSize[1,2]  GROUP oGroup2 TO aObjSize[1,3],aObjSize[1,4] OF oDlg7 ;
    		   PIXEL COLOR CLR_BLUE
		   oGroup2:SetFont(oFont3)
	@ aObjSize[1,1]+5 , aObjSize[1,2]+5  	SAY OemtoAnsi(STR0018)	SIZE 65,17 OF oDlg7 PIXEL FONT oFont3 
	@ aObjSize[1,1]+5 , aObjSize[1,2]+30 	SAY OemtoAnsi(STR0017) 	SIZE 65,17 OF oDlg7 PIXEL FONT oFont3 
	@ aObjSize[1,1]+20, aObjSize[1,2]+5		GET  cAgrup           	SIZE 15,07 OF oDlg7 PIXEL FONT oFont3 
	@ aObjSize[1,1]+20, aObjSize[1,2]+30 	GET  cDescr		      	SIZE 70,07 of oDlg7 PIXEL FONT oFont3 
	
   		bSet15 := {|| fCadAgrup(5,oGrAux:nAt,@oGrAux,@aLbxAx,,1)}
	bSet24 := {|| oDlg7:End()}	  
ACTIVATE MSDIALOG oDlg7 ON INIT EnchoiceBar( oDlg7 , bSet15 , bSet24 , Nil , Nil ) CENTERED
Return
	
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfEdiGrupo บAutor  ณMicrosiga -Natie    บ Data ณ  25/03/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEdita AGrupamentos                                          บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fEdiGrupo(oGrAux,aLbxAx,nEstou)
Local oDlg7
Local nOpt1                      
Local oGroup1,oGroup2
Local oFont3
Local bSet15
Local bSet24
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declara็ใo de arrays para dimensionar tela		                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
Local cTitulo := oEmToAnsi(STR0021)	//Edita	
cDescr	:= space(20)

oOk := LoadBitmap( GetResources(), "Enable" )
oNo := LoadBitmap( GetResources(), "LBNO" )
	/*
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Monta as Dimensoes dos Objetos         					   ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/   
	aAdvSize	:= MsAdvSize( ,.T.,090)
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 15 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
	
	DEFINE FONT oFont3  NAME "Arial" BOLD
	DEFINE MSDIALOG oDlg7 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cTitulo PIXEL        
		@ aObjSize[1,1],aObjSize[1,2]  GROUP oGroup2 TO aObjSize[1,3],aObjSize[1,4] OF oDlg7 ;
	       			   	PIXEL COLOR CLR_BLUE
						oGroup2:SetFont(oFont3)
		@ aObjSize[1,1]+5 , aObjSize[1,2]+5   SAY  OemtoAnsi(STR0018)  					SIZE 65,17 OF oDlg7 PIXEL FONT oFont3
		@ aObjSize[1,1]+5 , aObjSize[1,2]+30  SAY  OemtoAnsi(STR0017)  					SIZE 65,17 OF oDlg7 PIXEL FONT oFont3
		@ aObjSize[1,1]+17, aObjSize[1,2]+5   SAY  substr(aLbxAx[nEstou],1,2)				SIZE 15,07 OF oDlg7 PIXEL FONT oFont3 
		@ aObjSize[1,1]+17, aObjSize[1,2]+30  SAY  oEmToAnsi(substr(aLbxAx[nEstou],4,20)) SIZE 70,07 of oDlg7 PIXEL FONT oFont3
		@ aObjSize[1,1]+25, aObjSize[1,2]+5   SAY  substr(aLbxAx[nEstou],1,2)				SIZE 15,07 OF oDlg7 PIXEL FONT oFont3
		@ aObjSize[1,1]+25, aObjSize[1,2]+30  GET  cDescr		      						SIZE 70,07 of oDlg7 PIXEL FONT oFont3
	    
	    bSet15 := {|| fCadAgrup(5,oGrAux:nAt,@oGrAux,@aLbxAx,,2),oDlg7:End()}
	    bSet24 := {|| oDlg7:End()}
	ACTIVATE MSDIALOG oDlg7 ON INIT EnchoiceBar( oDlg7 , bSet15 , bSet24 , Nil , Nil ) CENTERED 
    
Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfExcGrupo บAutor  ณMicrosiga -Natie    บ Data ณ  25/03/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณExclui AGrupamentos                                         บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fExcGrupo(oGrAux,aLbxAx,nEstou)
Local oDlg7
Local nOpt1 
Local oGroup1,oGroup2
Local oFont3
Local bSet15
Local bSet24
Local cTitulo := oEmToAnsi(STR0022)	//Exclui
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declara็ใo de arrays para dimensionar tela		             ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
	
Private nEstou1	:= nEStou

oOk := LoadBitmap( GetResources(), "Enable" )
oNo := LoadBitmap( GetResources(), "LBNO" )
	/*
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Monta as Dimensoes dos Objetos         					   ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/   
	aAdvSize	:= MsAdvSize( ,.T.,090)
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 15 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
	
	DEFINE FONT oFont3  NAME "Arial" BOLD
	DEFINE MSDIALOG oDlg7 FROM aAdvSize[7],0 TO aAdvSize[6], aAdvSize[5] TITLE cTitulo PIXEL        
		@ aObjSize[1,1],aObjSize[1,2]  GROUP oGroup2 TO aObjSize[1,3],aObjSize[1,4] OF oDlg7 ;
	       			   PIXEL COLOR CLR_BLUE
				   oGroup2:SetFont(oFont3)
	
		@ aObjSize[1,1]+5 , aObjSize[1,2]+5   	SAY  OemtoAnsi(STR0018)  						SIZE 65,17 OF oDlg7 PIXEL FONT oFont3
		@ aObjSize[1,1]+5 , aObjSize[1,2]+30  	SAY  OemtoAnsi(STR0017)  						SIZE 65,17 OF oDlg7 PIXEL FONT oFont3
	
		@ aObjSize[1,1]+20, aObjSize[1,2]+5 	SAY  substr(aLbxAx[nEstou1],1,2)				SIZE 15,07 OF oDlg7 PIXEL FONT oFont3
		@ aObjSize[1,1]+20, aObjSize[1,2]+30 	SAY  oEmToAnsi(substr(aLbxAx[nEstou1],4,20))	SIZE 70,07 of oDlg7 PIXEL FONT oFont3
	        
	        bSet15 := {|| fCadAgrup(5,oGrAux:nAt,@oGrAux,@aLbxAx,,3),oDlg7:End()}
	        bSet24 := {|| oDlg7:End()}	    
	ACTIVATE MSDIALOG oDlg7 ON INIT EnchoiceBar( oDlg7 , bSet15 , bSet24 , Nil , Nil ) CENTERED 	
Return	

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณfOrdena   บAutor  ณMicrosiga -Natie    บ Data ณ  11/06/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณEfetua a ordenacao de cada agrupamento, deixando-se de utiliบฑฑ
ฑฑบ          ณzar a ordem dos campos do SX3                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fOrdena(aGrupAux,nUso)

Local cTitulo 
Local cDet
Local cFile  	:= "GpeFicha.fch"
Local cGo		:= space(3)
Local nHdl			:= 0 
Local nOpt1			:= 0
Local nPos          := 0 
Local n				:= 0 
Local aGrupos1		:= {}
Local aOrdem	:= aClone(aGrupAux)              // Agrupamentos 
Local aAuxiliar := aClone(aGrupAux)
Local oOk
Local oNo
Local oDlg6
Local oGroup1
Local oGroup0
Local oFont3
//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ Declara็ใo de arrays para dimensionar tela		                         ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
Local aAdvSize		:= {}
Local aInfoAdvSize	:= {}
Local aObjSize		:= {}
Local aObjCoords	:= {}
	
Local aAdv2Size		:= {}
Local aInfo2AdvSize	:= {}
Local aObj2Size		:= {}	
Local aObj2Coords 	:= {}
	
Local aAdv3Size		:= {}
Local aInfo3AdvSize	:= {}
Local aObj3Size		:= {}	
Local aObj3Coords 	:= {}
	
Local aAdv4Size		:= {}
Local aInfo4AdvSize	:= {}
Local aObj4Size		:= {}	
Local aObj4Coords 	:= {}

	oOk := LoadBitmap( GetResources(), "Enable" )
	oNo := LoadBitmap( GetResources(), "LBNO" )
	
	cTitulo := oEmToAnsi(STR0023)  									//Altera Ordem
	aAuxiliar	:= aSort(aAuxiliar,,,{ |x,y| x[3]+x[4] < y[3]+y[4] })
	/*
	ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
	ณ Monta as Dimensoes dos Objetos         					   ณ
	ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู*/    
	aAdvSize	:= MsAdvSize( ,.T.,370)
	aInfoAdvSize	:= { aAdvSize[1] , aAdvSize[2] , aAdvSize[3] , aAdvSize[4] , 5 , 5 }
	aAdd( aObjCoords , { 000 , 000 , .T. , .T. } )
	aObjSize	:= MsObjSize( aInfoAdvSize , aObjCoords )
	
	aAdv2Size    := aClone(aObjSize[1])
	
	aInfo2AdvSize    := { aAdv2Size[2] , aAdv2Size[1] , aAdv2Size[4] , aAdv2Size[3] , 5 , 5 }
	aAdd( aObj2Coords , { 000 , 000 , .T. , .T. } )
	aAdd( aObj2Coords , { 000 , 040 , .T. , .F. } )
	aObj2Size := MsObjSize( aInfo2AdvSize , aObj2Coords )
	
	aAdv3Size    := aClone(aObj2Size[1])
	
	aInfo3AdvSize    := { aAdv3Size[2] , aAdv3Size[1] , aAdv3Size[4] , aAdv3Size[3] , 5 , 5 }
	aAdd( aObj3Coords , { 000 , 000 , .T. , .T., .T. } )
	aAdd( aObj3Coords , { 060 , 000 , .F. , .T. } )
	aObj3Size := MsObjSize( aInfo3AdvSize , aObj3Coords, ,.T. )
	
	aAdv4Size    := aClone(aObj2Size[2])
	
	aInfo4AdvSize    := { aAdv4Size[2] , aAdv4Size[1] , aAdv4Size[4] , aAdv4Size[3] , 5 , 5 }
	aAdd( aObj4Coords , { 000 , 015 , .T. , .F. } )
	aAdd( aObj4Coords , { 000 , 000 , .T. , .T. } )
	aObj4Size := MsObjSize( aInfo4AdvSize , aObj4Coords )
	
	DEFINE FONT oFont3  NAME "Arial" BOLD	
	DEFINE FONT oFont   NAME "Arial" 
	DEFINE MSDIALOG odlg6 FROM aAdvSize[7],0 TO aAdvSize[6],aAdvSize[5] TITLE cTitulo PIXEL
	
		@ aObjSize[1,1],aObjSize[1,2] Group oGroup0 To aObjSize[1,3],aObjSize[1,4] Of oDlg6 PIXEL COLOR CLR_BLUE 
		
		@ aObj3Size[1,1],aObj3Size[1,2] LISTBOX oAgrup1;
		FIELDS  HEADER 	STR0024,STR0025,Left(STR0019,5),STR0026 ;
		SIZE aObj3Size[1,3], aObj3Size[1,4] OF odlg6 PIXEL
		oAgrup1:SetArray(aAuxiliar)
		oAgrup1:bLine := { || {If(aAuxiliar[oAgrup1:nAt,1],oOk,oNo),OemToAnsi(aAuxiliar[oAgrup1:nAt,2]),aAuxiliar[oAgrup1:nAt,3],aAuxiliar[oAgrup1:nAt,4] }}
		oAgrup1:Refresh()
	       
		@ aObj3Size[2,1]+5 , aObj3Size[2,2]  BUTTON oAcima 		PROMPT STR0033	SIZE 45,12	OF oDlg6	PIXEL ACTION fCadAgrup(1,oAgrup1:nAt,@oAgrup1,@aAuxiliar) FONT oFont3		//"Inverter Acima"
		@ aObj3Size[2,1]+25, aObj3Size[2,2]  BUTTON oAbaixo		PROMPT STR0034	SIZE 45,12	OF oDlg6	PIXEL ACTION fCadAgrup(2,oAgrup1:nAt,@oAgrup1,@aAuxiliar) FONT oFont3		//"Inverter Abaixo"
	
	
		@ aObj2Size[2,1], aObj2Size[2,2]  GROUP oGroup1 TO aObj2Size[2,3], aObj2Size[2,4] OF oDlg6  	PIXEL COLOR CLR_BLUE
		
		@ aObj4Size[1,1], aObj4Size[1,2] SAY	OemtoAnsi(STR0027)	OF oDlg6	PIXEL FONT oFont COLOR CLR_BLUE
		@ aObj4Size[2,1], aObj4Size[2,2] GET	cGo SIZE 15,07    	OF oDlg6	PIXEL FONT oFont
		DEFINE SBUTTON	oGo FROM aObj4Size[2,1], aObj4Size[2,2]+35  TYPE 1 ENABLE OF oDlg6 Action  fCadAgrup(3,oAgrup1:nAt,@oAgrup1,@aAuxiliar,@cGo,.f.) //Altera
	
	ACTIVATE DIALOG odlg6 CENTERED ON INIT EnchoiceBar	(odlg6,	{|| nOpt1:=1,odlg6:End() },;
												     	{|| nOpt1:=0,odlg6:End()})
	SETAPILHA()
	
	 	//--volta o Array da tela    
	 	
	If nOpt1 == 1
		For N:= 1 to Len(aAuxiliar)
			If (npos:= aScan(aDicioW,{|x| x[3] == aAuxiliar[n,5]} )) > 0
				aDicioW[nPos,1] := aAuxiliar[n,2]
				aDicioW[nPos,2] := aAuxiliar[n,1]
				aDicioW[nPos,4] := aAuxiliar[n,3]
				aDicioW[nPos,5] := aAuxiliar[n,4]
			Endif
		Next N                 
		aSort(aDicioW,,,{|x,y| x[4]+x[5]< y[4]+y[5]})
		oUso:SetArray(aDicioW)
		oUso:bLine := { || {if(aDicioW[oUso:nAt,2],oOk,oNo),oEmToAnsi(aDicioW[oUso:nAt,1]),aDicioW[oUso:nAt,4],aDicioW[oUso:nAt,5], aDicioW[oUso:nAt,3]}}
		oUso:Refresh()
		
	    aGrupos1	:= {}
		Aeval(aAuxiliar,{|x|,aAdd(aGrupos1,{x[1],x[2],x[3],x[4]} ) })  //U./Campo/Agrup/Ordem
		oOpcao:SetArray(aGrupos1)
		oOpcao:bLine := { || {If(aGrupos1[oOpcao:nAt,1],oOk,oNo),OemToAnsi(aGrupos1[oOpcao:nAt,2]),aGrupos1[oOpcao:nAt,3],aGrupos1[oOpcao:nAt,4] }}
		oOpcao:Refresh()
		aGrupos := aclone(aauxiliar)
	Endif
	
	DeleteObject(oOk)
	DeleteObject(oNo)
	
Return  


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณGPEA260   บAutor  ณMicrosiga -Natie    บ Data ณ  12/31/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณfCadAgrup() - Cadadastro de Agrupamentos                    บฑฑ
ฑฑบ          ณnQual	: 1-Acima/2-Abaixo/3-Alt.Ordem/4-Cad.Agr./5-Inc็.Agrupบฑฑ
ฑฑบ          ณnEstou: Posicao atual                                       บฑฑ
ฑฑบ          ณoLbx  : Objeto                                              บฑฑ
ฑฑบ          ณaLbx  : Array                                               บฑฑ
ฑฑบ          ณcPara : Variavel contendo o agrup. para troca               บฑฑ
ฑฑบ          ณnProcesso: Logico (1-Incl. 2-Edita  3-exclui                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function fCadAgrup(nQual,nEstou,oLbx,aLbx,cPara,nProcesso)
Local aAux 	:={},aLbxBkp:= {}
Local aSalva:={}
Local nAlbx	:= 0
Local nCont	:= 0 
Local nElem := Len( aLbx )
Local nPos	:= 0
Local nPos1	:= 0 
Local nPos2	:= 0
Local nx	:= 0
Local nOrdem := 0
Local i		:= 0  	

IF nQual == 1		//Inverter Acima
	IF nEstou # 1                                                  
		aAux	:= aClone( aLbx[ nEstou		] )
		aLbx[ nEstou      ]			:= aClone( aLbx[ nEstou - 1 ] )
		aLbx[ nEstou - 1  ]			:= aClone( aAux )
		oLbx:nAt					:= nEstou - 1
		aLbx[ oLbx:nAt 	   , 04 ]	:= StrZero( oLbx:nAt , 03 )
		aLbx[ oLbx:nAt + 1 , 04 ]	:= StrZero( oLbx:nAt + 1 , 03 )
	EndIF
ElseIF nQual == 2	//Inverter Abaixo
	IF 	nEstou # nElem
		aAux 						:= aClone( aLbx[ nEstou ]	  )
		aLbx[ nEstou      ]			:= aClone( aLbx[ nEstou + 1 ] )
		aLbx[ nEstou + 1  ]			:= aClone( aAux )
		oLbx:nAt					:= nEstou + 1
		aLbx[ oLbx:nAt 	   , 04 ]	:= StrZero( oLbx:nAt , 03 )
		aLbx[ oLbx:nAt - 1 , 04 ]	:= StrZero( oLbx:nAt - 1 , 03 )
	EndIF
	
ElseIf nQual == 3	// Altera Ordem dos campos
	IF !Empty( cPara )
		IF Val( cPara ) >= nElem
			cPara := StrZero( nElem , 3 )
		ElseIF Val( cPara ) <= 0.00 
			cPara := StrZero( 1 , 3 )
		EndIF
		cPara := StrZero( Val(cPara) , 3 )
		If ( nPos := aScan( aLbx ,{ |x| Val( x[4] ) == Val( cPara ) } ) ) > 0.00
			aSalva		:= {}
			aAdd(aSalva,{aLbx[nEstou,1],aLbx[nEstou,2],aLbx[nEstou,3],aLbx[nEstou,4],aLbx[nEstou,5]})
			aDel(aLbx,nEstou)
			aSize(aLbx,Len(aLbx)-1)
			aAux		:= aClone(aLbx)
			aLbx		:= {}
			nCont		:= 0
			nx			:= 0 
			While nx < Len(aAux)
				nx	  	:= nx + 1 			// Contador 
				nCont	:= nCont +  1		// Ordem dos campos
				If 	nPos = nx  
					Aadd(aLbx,{aSalva[1][1],aSalva[1][2],aSalva[1][3],cPara,aSalva[1,5] })
					nCont := nCont +  1
					Aadd(aLbx,{aAux[nx][1],aAux[nx][2],aAux[nx][3],StrZero(nCont,3),aAux[nx][5]})
				Else			
					Aadd(aLbx,{aAux[nx][1],aAux[nx][2],aAux[nx][3],StrZero(nCont,3),aAux[nx][5]})
				EndIf
			EndDo 
			//-- 
			If (nPos:= aScan(aLbx,{|x| Val(x[4]) == Val(cPara) })) == 0 
				Aadd(aLbx,{aSalva[1][1],aSalva[1][2],aSalva[1][3],cPara,aSalva[1][5] })
			Endif
		Endif 
	EndIF
	aSort(aLbx,,,{|x,y| x[3]+x[4]<y[3]+y[4] }) 
	oLbx:SetArray(aLbx)  
	oLbx:bLine := { || {If(aLbx[oLbx:nAt,1],oOk,oNo),OemToAnsi(aLbx[oLbx:nAt,2]),aLbx[oLbx:nAt,3],aLbx[oLbx:nAt,4] }}
ElseIf nQual ==5
	If nProcesso == 1 		//Inclusao de Novo Agrupamento
		nPos:= Ascan(aLbx,{|x| substr(x,1,2) = cAgrup })
		If nPos <= 0     	// Inclui Descricao 
			If !Empty(cAgrup) .or. !empty(cDescr)
				aAdd(aLbx,cAgrup+"-"+cDescr )
			Endif
		Else
			MsgAlert(STR0029,STR0030)
			Return .f.
		Endif
		cDescr	:= Space(20)
		cAgrup	:= Space(02)		
	ElseIf nProcesso ==2   // Altera descricao de agrupamento
		If Empty(cDescr)
			Return .F.
		Endif	
		aLbx[nEstou]	:= substr(albx[nEstou],1,3)+ cDescr
		oLbx:SetArray(aLbx)
		oLbx:nAt  		:= nEstou
	Else					// Delecao de Agrupamentos
		If MsgNoYes(STR0028 + "   " +STR0019 + " " + aLbx[nEstou] )
			//-- Verifica se E Agrupamentos com este codigo 
			nPos:=aScan(aDicioW,{|x|x[4] == substr(aLbx[nEstou],1,2) })
			If Len(aLbx) == 1						
				MsgAlert(oEmToAnsi(STR0031),STR0030)	// nao exclui qdo ha apenas 1 agrupamento
				oAgrup:SetItems(aAgrupa)
				oLbx:SetArray(aLbx)
				oLbx:bLine := { || { substr(aLbx[oLbx:nAt],1,2),Substr(aLbx[oLbx:nAt],4,20) } }				
				Return .F.
			Endif
			If  (nPos > 0 .and. MsgNoYes(oEmToAnsi(STR0032))  ) .or. nPos = 0
				aAux	:= aLbx[nEstou]
				aLbxBkp	:= aClone(aLbx)
				aLbx	:= {}
				nAlbx	:= Len(aLbxBkp)
				nEstou1	:= nEstou1 -1
			    For i= 1 to  nALbx
					If aLbxBkp[i] # aAux .and. !Empty(aAux)
						aAdd(aLbx, aLbxBkp[i] )
					Endif
				Next i 
			Endif	
		Endif		
	Endif
	//-- Acerta Ordem  dos dados
	aSort(aLbx,,,{|x,y| x < y })	
	oAgrup:SetItems(aAgrupa)
	oAgrup:Refresh()
	oLbx:SetArray(aLbx) 
	oLbx:Refresh()
	oLbx:bLine := { || { substr(aLbx[oLbx:nAt],1,2),Substr(aLbx[oLbx:nAt],4,20) } }
Endif
// Efetua troca dos Agrupamentos 
If nQual == 4
	cGrupo 	:= substr(cPara,01,02)
	//-- Verifica se existe o agrupamento  cadastrado
	nPos  	:= Ascan(aAgrupa,{|x| Subs(x,1,2) = cGrupo } )
	If nPos <=  0
		MsgAlert(STR0023,STR0018)
		Return .F.
	Else
		If cGrupo == aLbx[nEstou,4]
			Return .f.
		Endif
		aLbxBkp	:= {}
		Aeval(albx,{|x| If(cGrupo= x[4], Aadd(aLbxBkp,{x[1],x[2],x[3],x[4],x[5]}),"") })
		nAlbx		:= Len(aLbxBkp)
		cGrupoAux	:= aLbx[nEstou][4]                                                  
		//-- Checa ja existe o agrupamento no dicionario
		If nAlbx > 0
			aadd(aLbxBkp,{aLbx[nEstou,1],aLbx[nEstou,2],aLbx[nEstou,3],cGrupo,StrZero(nAlbx + 1, 3)} )
			For I:= 1 to (naLbx + 1)
			
				nPos2  	:= Ascan(aLbx,{|x| aLbxBkp[I,3] = x[3] } )
				If nPos2 > 0
					aLbx[nPos2,4]	:= aLbxBkp[I,4]
					aLbx[nPos2,5]	:= aLbxBkp[I,5]
				Endif
			Next i 		
		Else			//-- Primeira ocorrencia
			aadd(aLbxBkp,{aLbx[nEstou,1],aLbx[nEstou,2],aLbx[nEstou,3],cGrupo,StrZero(nAlbx + 1, 3)} )
			aLbx[nEstou,4]	:= cGrupo
			aLbx[nEstou,5]	:= "001"
			//-- Ativa botao de ordenacao
			fAtivaBtn(aLbxBkp,oBtnOrdem)
		Endif
	
		//-- Acerta Ordem 
		nX	:= 0
		nTam:= 0             

		While nTam < Len(aLbx)
		    nTam:= nTam+ 1
		    nX	:= nX  + 1 
			If cGrupoAux == aLbx[nx][4]
			    nOrdem	:= nOrdem + 1
				aLbx[nX][5]	:= Strzero(nOrdem,3)
			Endif
		Enddo

	Endif
	aLbx := aSort(aLbx,,,{|x,y| x[4]+x[5]<y[4]+y[5] })
	oLbx:SetArray(aLbx)
	oLbx:bLine := { || {if(aLbx[oLbx:nAt,2],oOk,oNo),OemtoAnsi(aLbx[oLbx:nAt,1]),aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5] }}

    //-- Array auxiliar com  os campos agrupados
	aGrupos	:= {}
	Aeval(aLbxBkp,{|x| , aAdd(aGrupos,{x[2],x[1],x[4],x[5],x[3]} ) })   //U./Campo/Agrup/Ordem
	oOpcao:SetArray(aGrupos)
	oOpcao:bLine := { || {If(aGrupos[oOpcao:nAt,1],oOk,oNo),oEmToAnsi(aGrupos[oOpcao:nAt,2]),aGrupos[oOpcao:nAt,3],aGrupos[oOpcao:nAt,4] }}
	oOpcao:Refresh()
EndIf

oLbx:Refresh()

Return .T.

/*/{Protheus.doc} fCadReturn
	(long_description)
	@type  Static Function
	@author Emerson Grassi Rocha
	@since 19/11/2020
	@version version
	@param param_name, param_type, param_descr
	@return return_var, return_type, return_description
	@example
	(examples)
	@see (links_or_references)
	/*/
Static Function fCadReturn(oLbx,aLbx)
Local nPos	:= 0
Local nx	:= 0
Local nOrdem:= 0
Local cGrupo:= ""

If oOpcao:nAt > 0
	cSeq	:= aGrupos[oOpcao:nAt][4] 
	cGrupo  := aGrupos[oOpcao:nAt][3]

	nPos := aScan(aLbx,{|x| x[4] = cGrupo .and. x[5] = cSeq })
	If nPos > 0

		//Retorna c๓digo do Grupo no Albx para "01" (Padrao)
		aLbx[nPos][4] := "01"
	
		//Retirar campo do aGrupos
		Adel(aGrupos, oOpcao:nAt) 
		Asize(aGrupos, Len(aGrupos)-1)
		
	EndIf
	
	//-- Acerta Ordem 
	nX	:= 0
	nTam:= 0             
	While nTam < Len(aLbx)
		nTam:= nTam+ 1
		nX	:= nX  + 1 
		If aLbx[nx][4] == "01"
			nOrdem	:= nOrdem + 1
			aLbx[nX][5]	:= Strzero(nOrdem,3)
		Endif
	Enddo

	aLbx := aSort(aLbx,,,{|x,y| x[4]+x[5]<y[4]+y[5] })
	oLbx:SetArray(aLbx)
	oLbx:bLine := { || {if(aLbx[oLbx:nAt,2],oOk,oNo),OemtoAnsi(aLbx[oLbx:nAt,1]),aLbx[oLbx:nAt,4],aLbx[oLbx:nAt,5] }}
   
   	oOpcao:SetArray(aGrupos)
	oOpcao:bLine := { || {If(aGrupos[oOpcao:nAt,1],oOk,oNo),oEmToAnsi(aGrupos[oOpcao:nAt,2]),aGrupos[oOpcao:nAt,3],aGrupos[oOpcao:nAt,4] }}
	oOpcao:Refresh()
EndIf

oLbx:Refresh()

Return .T.
