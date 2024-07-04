// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 0      º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼

#INCLUDE "veicc580.ch"
#Include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VEICC580  ºAutor  ³Fabio               º Data ³  05/30/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Bolsa de veiculos consulta oferta.                          º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function VEICC580

Private cCpaVda  := "1"
Private aCampos := {}          
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0005) //"Bolsa de Veiculos"
             

mBrowse( 6, 1,22,75,"VC4")

Return

Function FS_CRUZABOL(cAlias,nReg,nOpc)

Local cSele := Alias(), nPosVC4 := &(cSele)->(RecNo()) , nIndVC4 := VC4->(IndexOrd())
Private aStruVC4 := {}
Private oFonte   := TFont():New( "Arial", 6, 12 )
Private oMarcaF,oGruMod,oModeloc,oTipCor,oGruCor,oCorF
Private cCodMar,cGruMod,cDesGMod,cModVei,cDesMod,cTipCor,cGruCor,cCor,cDesCor,;
        cCombus,nAnoIni,nAnoFin,nValFxI,nValFxF,nKMFxa
Private cDesMar  := ""
Private cDesGCor := ""   
Private aTipCor  := {OemToAnsi(""),OemToAnsi(STR0006),OemToAnsi(STR0007),OemToAnsi(STR0008)} //"0-Solida"###"1-Metalica"###"2-Perolisada"
Private aCombus  := X3CBOXAVET("VV1_COMVEI","0")
Private M->VV1_CODMAR := ""

cCodMar  := Space(Len(VE1->VE1_CODMAR))
cDesMar  := Space(Len(VE1->VE1_DESMAR))
cGruMod  := Space(Len(VVR->VVR_GRUMOD))
cDesGMod := Space(Len(VVR->VVR_DESCRI))
cModVei  := Space(Len(VV2->VV2_MODVEI))
cDesMod  := Space(Len(VV2->VV2_DESMOD))
cTipCor  := ""   
cGruCor  := Space(Len(VVQ->VVQ_GRUCOR))
cDesGCor := Space(Len(VVQ->VVQ_DESCRI))
cCor     := Space(Len(VVC->VVC_CORVEI))
cDesCor  := Space(Len(VVC->VVC_DESCRI))
cCombus  := ""
nAnoIni  := 0
nAnoFin  := 0
nValFxI  := 0
nValFxF  := 0
nKMFxa   := 0

If nOpc == 3
   cCpaVda := "0"          
EndIf  

/////////////////////////
// FNC - 20103 RAFAEL  //
/////////////////////////

// Cria Filtro do SXB MC1 //
OFIAtuSXB()
//////////////////////////
//      F I M           //
//////////////////////////


/*
cIndVC4 := CriaTrab(Nil, .F.)
cChave  := "VC4_FILIAL+VC4_CHASSI+VC4_OFEVAL+VC4_VEI_CV"
cCond   := "VC4->VC4_OFEVAL == '0' .And. VC4->VC4_VEI_CV == cCpaVda"        // A = OS Aberta
IndRegua("VC4",cIndVC4,cChave,,cCond,OemToAnsi(STR0002) ) //"Comprar"
*/
DEFINE MSDIALOG oDlg TITLE cCadastro+" "+If(nOpc==3,STR0003,STR0002) FROM  4.5,0 To 35.5,80 OF oMainWnd //"Vender"###"Comprar"

@ 20,004 SAY  OemToAnsi(STR0014)  OF oDlg PIXEL COLOR CLR_BLUE && //"Marca"
@ 20,044 MSGET oMarcaF VAR cCODMAR PICTURE "@!" F3 "VE1" VALID FS_CFILBOLSA() SIZE 48,4 OF oDlg PIXEL
@ 20,096 SAY cDesMar OF oDlg PIXEL COLOR CLR_BLUE

@ 20,154 SAY  OemToAnsi(STR0015)  OF oDlg PIXEL COLOR CLR_BLUE &&"Kilometragem" //"Ate"
@ 20,194 MSGET oKMFxa VAR nKMFxa PICTURE "@E 99,999,999,999" VALID FS_CFILBOLSA() SIZE 48,4  OF oDlg PIXEL  FONT oFonte COLOR CLR_BLACK
@ 20,244 SAY OemToAnsi(STR0016) OF oDlg PIXEL COLOR CLR_BLUE //" Kilometros"

@ 32,004 SAY OemToAnsi(STR0017) OF oDlg PIXEL COLOR CLR_BLUE && //"Modelo"
@ 32,044 MSGET oGruMod VAR cGruMod PICTURE "@!" F3 "MC1" VALID FS_CFILBOLSA() SIZE 48,4  OF oDlg PIXEL  FONT oFonte COLOR CLR_BLACK
@ 32,096 SAY cDesGMod OF oDlg PIXEL COLOR CLR_BLUE

@ 32,154 SAY OemToAnsi(STR0018) OF oDlg PIXEL COLOR CLR_BLUE &&"Modelo Especifico" //"Mod Especifico"
@ 32,194 MSGET oModeloc VAR cMODVEI PICTURE "@!" F3 "MOD" VALID FS_CFILBOLSA() SIZE 48,4  OF oDlg PIXEL  FONT oFonte COLOR CLR_BLACK
@ 32,266 SAY cDesMod OF oDlg PIXEL COLOR CLR_BLUE

@ 46,004 SAY  OemToAnsi(STR0019)  OF oDlg PIXEL COLOR CLR_BLUE && //"Tipo de Cor"
@ 46,044 MSCOMBOBOX oTipCor VAR cTipCor VALID FS_CFILBOLSA() SIZE 48,5 COLOR CLR_BLACK;
           ITEMS aTipCor OF oDlg PIXEL

@ 46,154 SAY  OemToAnsi(STR0020)  OF oDlg PIXEL COLOR CLR_BLUE && //"Cor"
@ 46,194 MSGET oGruCor VAR cGruCor PICTURE "@!" F3 "VVQ" VALID FS_CFILBOLSA() SIZE 48,4  OF oDlg PIXEL  FONT oFonte COLOR CLR_BLACK
@ 46,244 SAY cDesGCor OF oDlg PIXEL COLOR CLR_BLUE

@ 60,004 SAY  OemToAnsi(STR0021)  OF oDlg PIXEL COLOR CLR_BLUE &&"Cor Específica" //"Cor Especifica"
@ 60,044 MSGET oCorF VAR cCOR PICTURE "@!" F3 "COR" VALID FS_CFILBOLSA() SIZE 48,4  OF oDlg PIXEL  FONT oFonte COLOR CLR_BLACK
@ 60,096 SAY Subs(cDesCor,1,14)  OF oDlg PIXEL COLOR CLR_BLUE

@ 60,154 SAY  OemToAnsi(STR0022)  OF oDlg PIXEL COLOR CLR_BLUE && //"Combustivel"
@ 60,194 MSCOMBOBOX oCombus VAR cCombus VALID FS_CFILBOLSA() SIZE 105,5 COLOR CLR_BLACK;
           ITEMS aCombus OF oDlg PIXEL

@ 74,004 SAY  OemToAnsi(STR0023)  OF oDlg PIXEL COLOR CLR_BLUE &&"Faixa de Ano" //"Ano de "
@ 74,044 MSGET oAnoIni VAR nAnoIni PICTURE "9999" VALID FS_CFILBOLSA() SIZE 38,4  OF oDlg PIXEL  FONT oFonte COLOR CLR_BLACK
@ 74,086 SAY OemToAnsi(STR0015) OF oDlg PIXEL COLOR CLR_BLUE //"ate"
@ 74,095 MSGET oAnoFin VAR nAnoFIn PICTURE "9999" VALID FS_CFILBOLSA() SIZE 38,4  OF oDlg PIXEL  FONT oFonte COLOR CLR_BLACK
@ 74,155 SAY  OemToAnsi(STR0024)  OF oDlg PIXEL COLOR CLR_BLUE &&"Faixa de Valor //"Valor de "
@ 74,194 MSGET oValFxI VAR nValFxI PICTURE "@E 999,999.99" VALID FS_CFILBOLSA() SIZE 48,4  OF oDlg PIXEL  FONT oFonte COLOR CLR_BLACK
@ 74,244 SAY OemToAnsi(STR0015) OF oDlg PIXEL COLOR CLR_BLUE //"ate"
@ 74,256 MSGET oValFxF VAR nValFxF PICTURE "@E 999,999.99" VALID FS_CFILBOLSA() SIZE 48,4  OF oDlg PIXEL  FONT oFonte COLOR CLR_BLACK
                                         
@ 92,1 LISTBOX oLbox FIELDS HEADER;
					OemToAnsi(STR0025),; //"Chassi"
					OemtoAnsi(STR0014),; //"Marca"
					OemToAnsi(STR0017),; //"Modelo"
					OemtoAnsi(STR0020),; //"Cor"
					OemToAnsi(STR0026),; //"Kilometragem"
					OemToAnsi(STR0027),; //"Estado"
					OemToAnsi(STR0028),; //"Ano"
					OemToAnsi(STR0029+GetMv("MV_SIMB1")),; //"Valor em "
					OemToAnsi(STR0030); //"Valor Avaliacao"
COLSIZES 50,19,40,40,33,22,35,40,40;
SIZE 315,142 OF oDlg PIXEL 

aadd(aStruVC4, { "","","","","","","",0,0 } )

oLbox:SetArray(aStruVC4)
oLbox:bLine := { || {  aStruVC4[oLbox:nAt,01],;
						aStruVC4[oLbox:nAt,02],;
						aStruVC4[oLbox:nAt,03],;
						aStruVC4[oLbox:nAt,04],;
						Transform(aStruVC4[oLbox:nAt,05],"@E 99,999,999,999"),;
						aStruVC4[oLbox:nAt,06],;
						Transform(Val(aStruVC4[oLbox:nAt,07]),"@R 9999/9999"),;
						Transform(aStruVC4[oLbox:nAt,08],"@E 99,999,999.99") ,;
						Transform(aStruVC4[oLbox:nAt,09],"@E 99,999,999.99") } }

@ 5,1 BUTTON oGrpOK PROMPT "OK" OF oDlg SIZE 45,10 PIXEL ACTION oDlg:End()
@ 5,50 BUTTON oGrpSair PROMPT "Cancelar" OF oDlg SIZE 45,10 PIXEL ACTION oDlg:End()

//ACTIVATE MSDIALOG oDlg CENTER ON INIT (EnCHOICEBAR(oDlg,{|| oDlg:End() } , {|| oDlg:End() }) , FS_CFILBOLSA() )
ACTIVATE MSDIALOG oDlg CENTER // ON INIT (EnCHOICEBAR(oDlg,{|| oDlg:End() } , {|| oDlg:End() }) , FS_CFILBOLSA() )

return

DbSelectArea("VC4")
RetIndex()

#IFNDEF TOP
   If File(cIndVC4+OrdBagExt())
      fErase(cIndVC4+OrdBagExt())
   Endif
#ENDIF

DbSetOrder(nIndVC4)
DbGoTo(nPosVC4)

DbSelectArea(cSele)

Return

Static Function FS_CFILBOLSA()
   
Local lAdd := .t.

aStruVC4 := {}

DbSelectArea("VC4")
DbGoTop()
Do While !Eof()
   
   If !Empty(cCodMar) .And. VC4->VC4_CODMAR # cCodMar
      lAdd := .f.
   EndIf                                    

   DbSelectArea("VE1")
   DbSetOrder(1)
   DbSeek(xFilial("VE1")+cCodMar)
   
   If UPPER(readvar()) == "CCODMAR"  
      cDesMar  := VE1->VE1_DESMAR
      M->VV1_CODMAR := cCodMar
   EndIf

   If UPPER(readvar()) == "CGRUCOR" 
      DbSelectArea("VVQ")
      DbSetOrder(2)
      DbSeek(xFilial("VVQ")+cGruCor)
      cDesGCor := VVQ->VVQ_DESCRI 
   EndIf

   If UPPER(readvar()) == "CCOR" 
      DbSelectArea("VVC")
      DbSetOrder(1)
      DbSeek(xFilial("VVC")+cCodMar+cCor)
      cDesCor := VVC->VVC_DESCRI 
   EndIf
      
   DbSelectArea("VV2")                           
   DbSetOrder(1)
   DbSeek(xFilial("VV2")+VC4->VC4_CODMAR+VC4->VC4_MODVEI)
 
   If !Empty(cGruMod) .And. VV2->VV2_GRUMOD # cGruMod
      lAdd := .f.
   EndIf
   
   If !Empty(cModVei) .And. VC4->VC4_MODVEI # cModVei
      lAdd := .f.
   EndIf

   DbSelectArea("VVC")
   DbSetOrder(1)
   DbSeek(xFilial("VVC")+VC4->VC4_CODMAR+VC4->VC4_CORVEI)

   If !Empty(cTipCor) 

      If VVC->VVC_TIPCOR # Substr(cTipCor,1,1)
         lAdd := .f.
      EndIf   

   EndIf                  

   If !Empty(cGruCor) .And. VVC->VVC_GRUCOR # cGruCor
      lAdd := .f.
   EndIf

   If !Empty(cCor) .And. VC4->VC4_CORVEI # cCor
      lAdd := .f.
   EndIf
   
   If !Empty(cCombus) .And. VC4->VC4_COMVEI # Substr(cCombus,1,1)
      lAdd := .f.
   EndIf                                    
   
   If !Empty(nAnoIni) .And. Val(Substr(VC4->VC4_FABMOD,1,4)) < nAnoIni
      lAdd := .f.
   EndIf                              
   
   If !Empty(nAnoFin) .And. Val(Substr(VC4->VC4_FABMOD,1,4)) > nAnoFin
      lAdd := .f.
   EndIf                                   
   
   If !Empty(nValFxI) .And. VC4->VC4_VALOFE < nValFxI
      lAdd := .f.
   EndIf

   If !Empty(nValFxF) .And. VC4->VC4_VALOFE > nValFxF
      lAdd := .f.
   EndIf                                        

   If !Empty(nKMFxa) .And. VC4->VC4_KILATU > nKMFxa   
      lAdd := .f.
   EndIf
   
   If lAdd

      aadd(aStruVC4, { VC4->VC4_CHASSI,VC4->VC4_CODMAR,VV2->VV2_DESMOD+VC4->VC4_MODVEI,VVC->VVC_DESCRI+VC4->VC4_CORVEI,VC4->VC4_KILATU,if(VC4->VC4_NOVUSA=="0",STR0031,STR0032)+Space(10),VC4->VC4_FABMOD,VC4->VC4_VALOFE, VC4->VC4_VALAVA } ) //"Novo "###"Usado"
   
   EndIf
        
   lAdd := .t.
   
   DbSelectArea("VC4")
   DbSkip()
EndDo
                                 
If Len(aStruVC4) == 0
   aadd(aStruVC4, { "","","","","","","",0,0 } )
EndIf

oLbox:SetArray(aStruVC4)
oLbox:bLine := { || { aStruVC4[oLbox:nAt,01],;
					   aStruVC4[oLbox:nAt,02],;
					   aStruVC4[oLbox:nAt,03],;
					   aStruVC4[oLbox:nAt,04],;
 					   Transform(aStruVC4[oLbox:nAt,05],"@E 99,999,999,999"),;
					   aStruVC4[oLbox:nAt,06],;
                       Transform(Val(aStruVC4[oLbox:nAt,07]),"@R 9999/9999"),;
					   Transform(aStruVC4[oLbox:nAt,08],"@E 99,999,999.99")  ,;
					   Transform(aStruVC4[oLbox:nAt,09],"@E 99,999,999.99") } }

oLbox:Refresh()

Return(.t.) 
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_CRUZAMENTOºAutor³Fabio              º Data ³   05/31/00  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Consulta cruzamento de veiculos,Bolsa Veiculos              º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ C E V                                                      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_CRUZAMENTO(cAlias,nReg,nOpc)

Local cSele :=  Alias() , nPosVC4 := &(cSele)->(RecNo()) , nIndVC4 := VC4->(IndexOrd())
Local cCodMar,cModVei,nPosxx := 0
Local nComVen := 0	

Private aComVen0 := {},aComVen1 := {}, lRComVen1 := .t. , lRComVen2 := .f. , cSList2 := STR0033 //"Oferta"
PRIVATE oMarca    := LoadBitmap( GetResources(), "LBNO" )
PRIVATE oDesmarca := LoadBitmap( GetResources(), "LBTIK" )
Private nPosCom := 1 , nPosVen := 1

cIndVC4 := CriaTrab(Nil, .F.)
cChave  := "VC4_FILIAL+VC4_VEI_CV+VC4_CODMAR+VC4_MODVEI+VC4_FABMOD"
cCond   := "VC4->VC4_OFEVAL == '0'"        // A = OS Aberta
IndRegua("VC4",cIndVC4,cChave,,cCond,OemToAnsi(STR0002) ) //"Comprar"

For nComVen := 0 to 1

   cComVen := Str(nComVen,1)

   DbSelectArea("VC4")
   DbSeek(xFilial("VC4")+cComVen)
   Do While !Eof() .And. VC4->VC4_VEI_CV == cComVen

      VV2->(DbSetOrder(1))
      VV2->(DbSeek(xFilial("VV2")+VC4->VC4_CODMAR+VC4->VC4_MODVEI))

      VVC->(DbSetOrder(1))
      VVC->(DbSeek(xFilial("VVC")+VC4->VC4_CODMAR+VC4->VC4_CORVEI))

      aadd(aComVen&(cComVen), { .f.,VC4->VC4_CODMAR,VC4->VC4_MODVEI,VV2->VV2_DESMOD,VVC->VVC_DESCRI+VC4->VC4_CORVEI,VC4->VC4_KILATU,if(VC4->VC4_NOVUSA=="0",STR0031,STR0032),VC4->VC4_FABMOD,VC4->VC4_VALOFE ,VC4->VC4_VALAVA, VC4->VC4_CHASSI , VC4->VC4_CONCES, VC4->VC4_PLAVEI, VC4->VC4_CODCLI, VC4->VC4_LOJA, VC4->VC4_NOMPRO, VC4->VC4_TELCON } ) //"Novo "###"Usado"

      cCodMar := VC4->VC4_CODMAR
      cModVei := VC4->VC4_MODVEI  
      

      nPosxx := Recno()

      If DbSeek(xFilial("VC4")+If(cComVen=="0","1","0")+cCodMar+cModVei)

         aadd(aComVen&(cComVen)[Len(aComVen&(cComVen))], {} )

         Do While !Eof() .And. VC4->VC4_VEI_CV+VC4->VC4_CODMAR+VC4->VC4_MODVEI == If(cComVen=="0","1","0")+cCodMar+cModVei

            VV2->(DbSetOrder(1))
            VV2->(DbSeek(xFilial("VV2")+VC4->VC4_CODMAR+VC4->VC4_MODVEI))

            VVC->(DbSetOrder(1))
            VVC->(DbSeek(xFilial("VVC")+VC4->VC4_CODMAR+VC4->VC4_CORVEI))

            aadd(aComVen&(cComVen)[Len(aComVen&(cComVen)),Len(aComVen&(cComVen)[Len(aComVen&(cComVen))])], { .f.,VC4->VC4_CODMAR,VC4->VC4_MODVEI,VV2->VV2_DESMOD,VVC->VVC_DESCRI+VC4->VC4_CORVEI,VC4->VC4_KILATU,if(VC4->VC4_NOVUSA=="0",STR0031,STR0032),VC4->VC4_FABMOD,VC4->VC4_VALOFE ,VC4->VC4_VALAVA ,VC4->VC4_CHASSI , VC4->VC4_CONCES, VC4->VC4_PLAVEI, VC4->VC4_CODCLI, VC4->VC4_LOJA, VC4->VC4_NOMPRO, VC4->VC4_TELCON} ) //"Novo "###"Usado"

            DbSelectArea("VC4")
            DbSkip()

         EndDo

      Else

         aadd(aComVen&(cComVen)[Len(aComVen&(cComVen))], {} )

         aadd(aComVen&(cComVen)[Len(aComVen&(cComVen)),Len(aComVen&(cComVen)[Len(aComVen&(cComVen))])], { .f.,"","","","","","","",0,0,"","","","","","","" } )

      EndIf

//      Asort(aComVen1[Len(aComVen1),Len(aComVen1[Len(aComVen1)])] ,1,,{ |x,y| x[2]+x[3]+x[8]+Str(x[9])+x[5]+Str(x[6]) == y[2]+y[3]+y[8]+Str(y[9])+y[5]+Str(y[6])  })

      DbGoTo(nPosxx)

      DbSelectArea("VC4")
      DbSkip()

   EndDo

Next

If Len(aComVen0) == 0

   aadd(aComVen0, { .f.,"","","","","","","",0,0,"","","","","","","" } )

   aadd(aComVen0[Len(aComVen0)], {} )

   aadd(aComVen0[Len(aComVen0),Len(aComVen0[Len(aComVen0)])], { .f.,"","","","","","","",0,0,"","","","","","","" } )

EndIf

If Len(aComVen1) == 0

   aadd(aComVen1, { .f.,"","","","","","","",0,0,"","","","","","","" } )

   aadd(aComVen1[Len(aComVen1)], {} )

   aadd(aComVen1[Len(aComVen1),Len(aComVen1[Len(aComVen1)])], { .f.,"","","","","","","",0,0,"","","","","","","" } )

EndIf

DEFINE MSDIALOG oDlg TITLE cCadastro+" "+STR0004 FROM  4.5,0 To 35.5,80 OF oMainWnd //"Cruzamento"

@ 006,002 TO 214,317 OF oDlg PIXEL

@ 005, 005 CHECKBOX oRComVen1 VAR lRComVen1 PROMPT STR0034 ; //"&Compra"
                           OF oDlg ;
                           ON CLICK FS_COMP1() ;
                           FONT TFont():New( "System", 8, 10 ) ;
                           SIZE 40,10 PIXEL

@ 005, 045 CHECKBOX oRComVen2 VAR lRComVen2 PROMPT STR0035 ; //"&Venda"
                           OF oDlg ;
                           ON CLICK FS_VEND() ;
                           FONT TFont():New( "System", 8, 12 ) ;
                           SIZE 40,10 PIXEL

@ 20,6 LISTBOX oLList0 FIELDS HEADER;
					OemToAnsi(""),;
					OemtoAnsi(STR0014),; //"Marca"
					OemToAnsi(STR0017),; //"Modelo"
					OemToAnsi(STR0036),; //"Descricao"
					OemtoAnsi(STR0020),; //"Cor"
					OemToAnsi(STR0026),; //"Kilometragem"
					OemToAnsi(STR0027),; //"Estado"
					OemToAnsi(STR0028),; //"Ano"
					OemToAnsi(STR0029+GetMv("MV_SIMB1")),; //"Valor em "
					OemToAnsi(STR0030),; //"Valor Avaliacao"
					OemToAnsi(STR0025); //"Chassi"
COLSIZES 20,19,30,40,30,33,22,35,40,50;
SIZE 307,90 OF oDlg ON CHANGE (FS_FILCRUZA("1",If(lRComVen1,"0","1")),oLList1:SetFocus(),oLList0:SetFocus()) ;
                    ON DBLCLICK FS_MRLIST(If(lRComVen1,"0","1")) PIXEL

oLList0:bGotFocus := {|| oLList1:nClrPane := CLR_HGRAY,oLList0:nClrPane := CLR_WHITE }

oLList0:SetArray(aComVen0)
oLList0:bLine := { || {  If(aComVen0[oLList0:nAt,01],oDesMarca,oMarca) ,;
						aComVen0[oLList0:nAt,02],;
						aComVen0[oLList0:nAt,03],;
						aComVen0[oLList0:nAt,04],;
						aComVen0[oLList0:nAt,05],;
						Transform(aComVen0[oLList0:nAt,06],"@E 99,999,999,999"),;
						aComVen0[oLList0:nAt,07],;
						Transform(aComVen0[oLList0:nAt,08],"@R 9999/9999"),;
						Transform(aComVen0[oLList0:nAt,09],"@E 99,999,999.99") ,;
						Transform(aComVen0[oLList0:nAt,10],"@E 99,999,999.99") ,;
						aComVen0[oLList0:nAt,11] } }
  
@ 112,006 SAY oSList2 VAR cSList2  Font TFont():New( "System", 8, 10 ) SIZE 40,15 OF oDlg PIXEL COLOR CLR_BLACK

@ 120,6 LISTBOX oLList1 FIELDS HEADER;
					OemToAnsi(""),;
					OemtoAnsi(STR0014),; //"Marca"
					OemToAnsi(STR0017),; //"Modelo"
					OemToAnsi(STR0036),; //"Descricao"
					OemtoAnsi(STR0020),; //"Cor"
					OemToAnsi(STR0026),; //"Kilometragem"
					OemToAnsi(STR0027),; //"Estado"
					OemToAnsi(STR0028),; //"Ano"
					OemToAnsi(STR0029+GetMv("MV_SIMB1")),; //"Valor em "
					OemToAnsi(STR0030),; //"Valor Avaliacao"
					OemToAnsi(STR0025); //"Chassi"
COLSIZES 20,19,30,40,30,33,22,35,40,50;
SIZE 307,90 OF oDlg ON DBLCLICK (aComVen&(If(lRComVen1,"0","1"))[oLList0:nAt,18,oLList1:nAt,01] := !aComVen&(If(lRComVen1,"0","1"))[oLList0:nAt,18,oLList1:nAt,01], If(aComVen&(If(lRComVen1,"0","1"))[oLList0:nAt,18,oLList1:nAt,01],(aComVen&(If(lRComVen1,"0","1"))[oLList0:nAt,1] := .t. , oLList0:Refresh() ),.f.) )  COLORS CLR_BLACK,CLR_HGRAY PIXEL //Font TFont():New( "System", 8, 10 )

oLList1:bGotFocus := {|| oLList0:nClrPane := CLR_HGRAY,oLList1:nClrPane := CLR_WHITE}

oLList1:SetArray(aComVen0[1,18])
oLList1:bLine := { || {  If(aComVen0[1,18,oLList1:nAt,01],oDesMarca,oMarca) ,;
						aComVen0[1,18,oLList1:nAt,02],;
						aComVen0[1,18,oLList1:nAt,03],;
						aComVen0[1,18,oLList1:nAt,04],;
						aComVen0[1,18,oLList1:nAt,05],;
						Transform(aComVen0[1,18,oLList1:nAt,06],"@E 99,999,999,999"),;
						aComVen0[1,18,oLList1:nAt,07],;
						Transform(aComVen0[1,18,oLList1:nAt,08],"@R 9999/9999"),;
						Transform(aComVen0[1,18,oLList1:nAt,09],"@E 99,999,999.99") ,;
						Transform(aComVen0[1,18,oLList1:nAt,10],"@E 99,999,999.99") ,;
						aComVen0[1,18,oLList1:nAt,11] } }

DEFINE SBUTTON FROM 220,235 TYPE 6 ACTION (FS_IMPBOLSA()) ENABLE OF oDlg
DEFINE SBUTTON FROM 220,275 TYPE 2 ACTION (oDlg:End()) ENABLE OF oDlg
  
ACTIVATE MSDIALOG oDlg CENTER 

DbSelectArea("VC4")
RetIndex()

#IFNDEF TOP
   If File(cIndVC4+OrdBagExt())
      fErase(cIndVC4+OrdBagExt())
   Endif
#ENDIF

DbSetOrder(nIndVC4)
DbGoTo(nPosVC4)

DbSelectArea(cSele)
      
Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³VEICA590  ºAutor  ³Microsiga           º Data ³  05/31/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_FILCRUZA(cLBox,cVetor)
   
Local lAdd := .t.,nPosxx := 0,cCodMar,cModVei,cAnoFab,nPosL1 := 0
            
If cLBox == "0"

	oLList0:SetArray(aComVen&(cVetor))
	oLList0:bLine := { || {  If(aComVen&(cVetor)[oLList0:nAt,01],oDesMarca,oMarca) ,;
							aComVen&(cVetor)[oLList0:nAt,02],;
							aComVen&(cVetor)[oLList0:nAt,03],;
							aComVen&(cVetor)[oLList0:nAt,04],;
							aComVen&(cVetor)[oLList0:nAt,05],;
							Transform(aComVen&(cVetor)[oLList0:nAt,06],"@E 99,999,999,999"),;
							aComVen&(cVetor)[oLList0:nAt,07],;
							Transform(aComVen&(cVetor)[oLList0:nAt,08],"@R 9999/9999"),;
							Transform(aComVen&(cVetor)[oLList0:nAt,09],"@E 99,999,999.99") ,;
							Transform(aComVen&(cVetor)[oLList0:nAt,10],"@E 99,999,999.99") ,;
							aComVen&(cVetor)[oLList0:nAt,11] } }

Else

	oLList1:SetArray(aComVen&(cVetor)[oLList0:nAt,18])
	oLList1:bLine := { || {  If(aComVen&(cVetor)[oLList0:nAt,18,oLList1:nAt,01],oDesMarca,oMarca) ,;
							aComVen&(cVetor)[oLList0:nAt,18,oLList1:nAt,02],;
							aComVen&(cVetor)[oLList0:nAt,18,oLList1:nAt,03],;
							aComVen&(cVetor)[oLList0:nAt,18,oLList1:nAt,04],;
							aComVen&(cVetor)[oLList0:nAt,18,oLList1:nAt,05],;
							Transform(aComVen&(cVetor)[oLList0:nAt,18,oLList1:nAt,06],"@E 99,999,999,999"),;
							aComVen&(cVetor)[oLList0:nAt,18,oLList1:nAt,07],;
							Transform(aComVen&(cVetor)[oLList0:nAt,18,oLList1:nAt,08],"@R 9999/9999"),;
							Transform(aComVen&(cVetor)[oLList0:nAt,18,oLList1:nAt,09],"@E 99,999,999.99") ,;
							Transform(aComVen&(cVetor)[oLList0:nAt,18,oLList1:nAt,10],"@E 99,999,999.99") ,;
							aComVen&(cVetor)[oLList0:nAt,18,oLList1:nAt,11] } }

    nPosL1 := Ascan(aComVen&(cVetor)[oLList0:nAt,18] ,{ |x| x[2]+x[3]+x[8] >= aComVen&(cVetor)[oLList0:nAt,2]+aComVen&(cVetor)[oLList0:nAt,3]+aComVen&(cVetor)[oLList0:nAt,8]  })

    If nPosL1 == 0
       oLList1:nAt := 1
    Else
       oLList1:nAt := nPosL1
    EndIf    

EndIf

Return(.t.)

Function FS_COMP1()
                    
nPosVen := oLList0:nAt
      
FS_FILCRUZA("0","0")
     
lRComVen2 := .f.
oRComVen2:Refresh()
cSList2 := STR0033 //"Oferta"
oSList2:Refresh()

oLList0:nat := nPosCom
oLList1:nat := 1

FS_FILCRUZA("1","0")

oLList0:Refresh()
oLList1:Refresh()

Return

Function FS_VEND()

nPosCom := oLList0:nAt

FS_FILCRUZA("0","1")
     
lRComVen1 := .f.
oRComVen1:Refresh()
cSList2 := STR0037 //"Procura"
oSList2:Refresh()
       
oLList0:nat := nPosVen
oLList1:nat := 1
      
FS_FILCRUZA("1","1")

oLList0:Refresh()
oLList1:Refresh()

Return

Function FS_MRLIST(cVetor)

Local nix := 0      
aComVen&(cVetor)[oLList0:nAt,01] := !aComVen&(cVetor)[oLList0:nAt,01]
                                       
For nix:=1 to Len(aComVen&(cVetor)[oLList0:nAt,18])                         

   aComVen&(cVetor)[oLList0:nAt,18,nix,01] := aComVen&(cVetor)[oLList0:nAt,01]
     
   x:= 1
   
Next   

oLList1:SetFocus()
oLList0:SetFocus()

Return
      

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_IMPBOLSAºAutor ³Microsiga           º Data ³  06/01/00   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³                                                            º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP5                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_IMPBOLSA()

Local nLin := 0 , cVetor
Local nReg,nReg1,nVetor := 0                        
PRIVATE aReturn  := { OemToAnsi(STR0038), 1,OemToAnsi(STR0039), 2, 2, 2,,1 } //"Incluir"###"Alterar"
PRIVATE titulo,cabec1,cabec2,nLastKey:=0,wnrel,tamanho:="P",oPrinter,oFont

cAlias := "VC4"
cNomRel:= "CRUZAMEN"
cTitulo:= STR0005 //"Bolsa de Veiculos"
cDesc1 := If(lRComVen2,STR0003,STR0002)

lHabil := .f.
cTamanho:= "P"

NomeRel := SetPrint(cAlias,cNomRel,nil,@cTitulo,cDesc1,"","",lHabil,,,cTamanho)

cbTxt    := Space(10)
cbCont   := 0
cString  := "VC4"
Li       := 80
m_Pag    := 1

wnRel    := "VEICA590"

cTitulo:= STR0005 //"Bolsa de Veiculos"
cabec1 := "x"
cabec2 := " "
//cabec2 := "--- -- ---- --------------------------- ---------------------------- ----- ------- --------- -------------- -------------- ------"
nomeprog:="VEICA590"
tamanho:="P"
nCaracter:=15
nTotal := 0
nLin   := 0

If nlastkey == 27
   Return(Allwaystrue())
EndIf

SetDefault(aReturn,cAlias)

Set Printer to &NomeRel
Set Printer On
Set device to Printer

For nVetor := 0 to 1
                        
    cVetor  := Str(nVetor,1)

    cTitulo := STR0005+" - "+If(cVetor=="0",STR0037,STR0033) //"Bolsa de Veiculos"###"Procura"###"Oferta"

    For nReg:=1 to Len(aComVen&(cVetor))

        If aComVen&(cVetor)[nReg,01]

           cabec1 := If(cVetor=="0",STR0037,STR0033)+aComVen&(cVetor)[nReg,14]+" "+aComVen&(cVetor)[nReg,15]+" "+aComVen&(cVetor)[nReg,16] //"Procura"###"Oferta"
           cabec2 := STR0041+aComVen&(cVetor)[nReg,17]+STR0042+aComVen&(cVetor)[nReg,12] //"Fone "###" Concessionaria "

           nLin := cabec(ctitulo,cabec1,cabec2,nomeprog,tamanho,nCaracter) + 1

           @ nLin++,1 pSay STR0014+" "+aComVen&(cVetor)[nReg,02]+space(10)+STR0017+" "+aComVen&(cVetor)[nReg,03]+"   "+aComVen&(cVetor)[nReg,04] //"Marca"###"Modelo"
           @ nLin++,1 pSay STR0020+" "+Substr(aComVen&(cVetor)[nReg,05],1,14)+" "+STR0043+" "+aComVen&(cVetor)[nReg,07] //"Cor"###"Est"
           @ nLin++,1 pSay STR0044+" "+Transform(aComVen&(cVetor)[nReg,06],"999,999,999")+"     "+STR0028+" "+Transform(aComVen&(cVetor)[nReg,08],"@R 9999/9999")+space(27)+STR0045+" "+GetMv("MV_SIMB1")+" "+Transform(aComVen&(cVetor)[nReg,09],"@E 99,999,999.99")+If(!Empty(aComVen&(cVetor)[nReg,10]), STR0046+" "+Transform(aComVen&(cVetor)[nReg,10],"@E 999,999,999.99"),"") //"Km"###"Ano"###"Vlr"###"Vlr Aval"

           @ nLin++,1 pSay Repl("_",79)
           @ nLin++,1 pSay If(cVetor=="0",STR0047,STR0048)+STR0049 //"Chassi                     Placa    "###"Nome                                "###"Fone            Concessionaria"
           @ nLin++,1 pSay STR0050+GetMv("MV_SIMB1")+If(cVetor=="0",STR0051,"") //"Cor               Kilometragem  Estado       Ano    Valor em "###"   Vlr Avaliado"
      	   @ nLin++,1 pSay Repl("_",79)

           For nReg1:=1 to Len(aComVen&(cVetor)[nReg,18])
             
               If aComVen&(cVetor)[nReg,18,nReg1,1]
            
	      	      @ nLin++,1 pSay If(cVetor=="0",aComVen&(cVetor)[nReg,18,nReg1,11] +"  "+Transform(aComVen&(cVetor)[nReg,18,nReg1,13],"@R !!!-!!!!"), aComVen&(cVetor)[nReg,18,nReg1,16]+Space(5) )+" "+aComVen&(cVetor)[nReg,18,nReg1,17]+" "+aComVen&(cVetor)[nReg,18,nReg1,12] FONT TFont():New( "System", 12, 18 )
                
    	          @ nLin++,1 pSay Substr(aComVen&(cVetor)[nReg,18,nReg1,05],1,14)+"  "+Transform(aComVen&(cVetor)[nReg,18,nReg1,06],"@E 99,999,999,999")+"  "+aComVen&(cVetor)[nReg,18,nReg1,07] ;
	      	                       +"  "+Transform(aComVen&(cVetor)[nReg,18,nReg1,08],"@R 9999/9999")+"  "+Transform(aComVen&(cVetor)[nReg,18,nReg1,09],"@E 99,999,999.99")+"  "+If(cVetor=="0",Transform(aComVen&(cVetor)[nReg,18,nReg1,10],"@E 99,999,999.99"),"")
	      	                    
               EndIf      
                                                  
           Next
        
        EndIf

    Next
                 
Next

Set Printer to
Set device to Screen

MS_FLUSH()
      
If aReturn[5] == 1

   OURSPOOL(cNomRel)
   
EndIf   

Return

Static Function MenuDef()
Local aRotina := { { STR0001 ,"AxPesqui"     , 0 , 1},;     //"Pesquisar"
                      { STR0002 ,"FS_CRUZABOL"  , 0 , 2},;  //"Comprar"
                      { STR0003 ,"FS_CRUZABOL"  , 0 , 3},;  //"Vender"
                      { STR0004 ,"FS_CRUZAMENTO", 0 , 4} }  //"Cruzamento"
Return aRotina
              

//////////////////////////////////////
// CRIA CONSULTA PADRAO FNC - 20103 //
// RAFAEL GONCALVES 30/09/09        //
//////////////////////////////////////


Static Function OFIAtuSXB()
Local aEstrSXB := { "XB_ALIAS","XB_TIPO","XB_SEQ","XB_COLUNA","XB_DESCRI","XB_DESCSPA","XB_DESCENG","XB_CONTEM","XB_WCONTEM" } 
Local aSXB := {}
Local ni := 0
Local nj := 0

aEstrut := {'XB_ALIAS','XB_TIPO','XB_SEQ','XB_COLUNA','XB_DESCRI','XB_DESCSPA','XB_DESCENG','XB_CONTEM','XB_WCONTEM'}

Aadd(aSXB,{'MC1','1','01','DB','Modelo','Modelo','Model','VV2',''})
Aadd(aSXB,{'MC1','2','01','01','Modelo','Modelo','Model','',''})
Aadd(aSXB,{'MC1','3','01','01','Cadastra Novo','Incluye Nuevo','Add new','01',''})
Aadd(aSXB,{'MC1','4','01','01','Marca','Marca','Trademark','VV2_CODMAR',''})
Aadd(aSXB,{'MC1','4','01','02','Modelo','Modelo','Model','VV2_MODVEI',''})
Aadd(aSXB,{'MC1','4','01','03','Descricao','Descripcion','Description','VV2_DESMOD',''})
Aadd(aSXB,{'MC1','5','01','','','','','VV2->VV2_MODVEI',''})
Aadd(aSXB,{'MC1','6','01','01','','','','if(!empty(M->VV1_CODMAR),VV2->VV2_CODMAR == M->VV1_CODMAR,.t.)',''})



dbSelectArea("SXB")
dbSetOrder(1)
For ni:= 1 To Len(aSXB)
	DbSeek(Left(aSXB[ni,1]+SPACE(6),6)+aSXB[ni,2]+aSXB[ni,3]+Left(aSXB[ni,4]+SPACE(2),2))
	RecLock("SXB",!Found())
	For nj:=1 To Len(aSXB[ni])
		If ( FieldPos(aEstrSXB[nj])>0 .and. aSXB[ni,nj] # NIL )
			FieldPut(FieldPos(aEstrSXB[nj]),aSXB[ni,nj])
		EndIf
	Next nj
	dbCommit()
	MsUnLock()
Next ni

Return
