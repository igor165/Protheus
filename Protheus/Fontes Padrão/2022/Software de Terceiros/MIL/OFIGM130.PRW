// ÉÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÍ»
// º Versao º 13     º
// ÈÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÍ¼
#include "Ofigm130.ch"
#include "protheus.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³ OFIGM130 ³ Autor ³ Andre                 ³ Data ³ 14/02/01 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ NF de entrada e saida de envio de peca para fabrica        ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static cTipOpe := Space(9)

Function OFIGM130

Private nIndex    :=  0 
Private cCadastro := OemToAnsi(STR0001)                     //Remessa de Peca p/ Fabrica
Private aRotina   := MenuDef()
Private cIndex , cChave , cCond 
Private lsDoc     := FieldPos("VG5_SDOCE") > 0

DbSelectArea("VGA")     
DbSetOrder(1)
cIndex  := CriaTrab(nil,.f.)
cChave  := Indexkey()
cCond   := 'VGA->VGA_TRANSM == "S"'
IndRegua("VGA",cIndex,cChave,,cCond,STR0014)

DbSelectArea("VGA")
nIndex := RetIndex("VGA")+1
DbSetOrder(nIndex)

cDelFunc := ".T."
cMarca := GetMark()

aCamList := {{"VGA_OK",   ,"",OemToAnsi("")},;
              {"VGA_NUMOSV","",OemToAnsi(STR0019)},;
              {"VGA_CODMAR","",OemToAnsi(STR0006)},;
              {"VGA_CHAINT","",OemToAnsi(STR0047)},;
              {"VGA_ABEGAR","",OemToAnsi(STR0048)},;
              {"VGA_DATFEC","",OemToAnsi(STR0049)},;
              {"VGA_KILGAR","",OemToAnsi(STR0050)}}

lInverte := .F.

//Markbrow("VGA","VGA_OK","FS_TIKGM130()",,,cMarca)
Markbrow("VGA","VGA_OK",,,,cMarca,,,,,"Processa( { || FS_TIKGM130() } ) ")

DbSelectArea("VGA")
RetIndex()
DbSetOrder(1)

Return
               
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ GM130M   ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Montagem do listbox para marcar as pecas que serao enviadas³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GM130M(cAlias,nReg,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Uso       ³ Garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GM130M(cAlias,nReg,nOpc)

Local lInverte := .F.
Local aArea := {}
Private oLbox, oDlgNfR
Private aVetCampos := {} , aCampos := {}
Private cArqPec
Private cArqIPec1  := CriaTrab(NIL, .F.)
Private cArqIPec2  := CriaTrab(NIL, .F.)
Private nOpca      := nOpc
Private lMsHelpAuto := .f.
Private lMsErroAuto := .t.

aArea := sGetArea(aArea , "VGA")

DbSelectArea("VGA")
DbSetOrder(nIndex)     
      
If nOpc==4
	nOpc :=5
	nOpca:=5
Endif	

&& Cria vetor da Msgetdb Servico Total
AADD(aCampos,{ "PEC_OK"    ,"", "  "               ,""    })
AADD(aCampos,{ "PEC_CODMAR","", TRIM(STR0018)      , "@!" })   //"Cod Marca"
AADD(aCampos,{ "PEC_NUMOSV","", TRIM(STR0019)      , "@!" })   //"Nro OS"
AADD(aCampos,{ "PEC_GRUITE","", TRIM(STR0020)      , "@!" })   //"Grupo"
AADD(aCampos,{ "PEC_CODITE","", TRIM(STR0021)      , "@!" })   //"Cod Item"
AADD(aCampos,{ "PEC_DESITE","", TRIM(STR0022)      , "@!" })   //"Descricao"
AADD(aCampos,{ "PEC_QTDITE","", TRIM(STR0023)      , "@E 9999999999"     })  //"Qtd Item"
AADD(aCampos,{ "PEC_VAEXNF","", TRIM(STR0024)	    , "@E 999,999,999.99" })  //"Vlr Exp"
AADD(aCampos,{ "PEC_VAIMNF","", TRIM(STR0025)	    , "@E 999,999,999.99" })  //"Vlr Imp"
AADD(aCampos,{ "PEC_CODCLI","", TRIM(STR0026)      , "@!"	})   //"Cod Cliente"
AADD(aCampos,{ "PEC_LOJCLI","", TRIM(STR0027)      , "@!"	})   //"Loja"
AADD(aCampos,{ "PEC_CGCCLI","", TRIM(STR0028)      , "@!"	})   //"CGC"
AADD(aCampos,{ "PEC_NUMNFI","", TRIM(STR0029) 		 , "@!"	})   //"Nf Saida"
AADD(aCampos,{ "PEC_SERIEN","", TRIM(STR0030)      , "!!!"	})   //"Serie"
AADD(aCampos,{ "PEC_NFIENT","", TRIM(STR0031)		 , "@!"	})   //"Nf Entrada"
AADD(aCampos,{ "PEC_SERENT","", TRIM(STR0032)      , "!!!"	})   //"Serie"

&& Cria Arquivo de Trabalho Pecas  Total grupo
aVetCampos := {}
aadd(aVetCampos,{ "PEC_CODMAR" , "C" , 3                                               , 0 })  && Codigo da marca
aadd(aVetCampos,{ "PEC_NUMOSV" , "C" , 8                                               , 0 })  && Nro OS
aadd(aVetCampos,{ "PEC_GRUITE" , "C" , 4                                               , 0 })  && Grupo do item
aadd(aVetCampos,{ "PEC_CODITE" , "C" , 27                                              , 0 })  && Codigo do item
aadd(aVetCampos,{ "PEC_DESITE" , "C" , 30                                              , 0 })  && Descricao
aadd(aVetCampos,{ "PEC_PECINT" , "C" , 15                                              , 0 })  && Codigo interno
aadd(aVetCampos,{ "PEC_QTDITE" , "N" , 10                                              , 0 })  && Quantidade do item
aadd(aVetCampos,{ "PEC_QTDREC" , "N" , 10                                              , 0 })  && Quantidade do Recall
aadd(aVetCampos,{ "PEC_VAEXNF" , "N" , 12                                              , 2 })  && Formula de exportacao/prc
aadd(aVetCampos,{ "PEC_VAIMNF" , "N" , 12                                              , 2 })  && Formula de Importacao/prc
aadd(aVetCampos,{ "PEC_PROVEI" , "C" , 6                                               , 0 })  && Proprietario do veiculo
aadd(aVetCampos,{ "PEC_LOJPRO" , "C" , 2                                               , 0 })  && Loja do proprietario
aadd(aVetCampos,{ "PEC_CODCLI" , "C" , 6                                               , 0 })  && Cliente
aadd(aVetCampos,{ "PEC_LOJCLI" , "C" , 2                                               , 0 })  && Loja
aadd(aVetCampos,{ "PEC_NOMCLI" , "C" , 30                                              , 0 })  && Nome
aadd(aVetCampos,{ "PEC_CGCCLI" , "C" , 14                                              , 0 })  && CGC
aadd(aVetCampos,{ "PEC_CGCFAB" , "C" , 14                                              , 0 })  && CGC Fabrica
aadd(aVetCampos,{ "PEC_CONPGT" , "C" , 3                                               , 0 })  && Condicao de pagamento
aadd(aVetCampos,{ "PEC_CODDEF" , "C" , 3                                               , 0 })  && Codigo do defeito
aadd(aVetCampos,{ "PEC_ENVOBR" , "C" , 1                                               , 0 })  && Peca de envio obrigatorio
aadd(aVetCampos,{ "PEC_NUMNFI" , "C" , tamsx3( "F2_DOC")[1]                      	   , 0 })  && Numero da Nf de saida
aadd(aVetCampos,{ "PEC_ORDNFI" , "C" , 2                                               , 0 })  && Ordem do item na NF
aadd(aVetCampos,{ "PEC_NFIENT" , "C" , tamsx3( "F2_DOC")[1]                      	   , 0 })  && Numero da Nf de Entrada
aadd(aVetCampos,{ "PEC_SERIEN" , "C" , tamsx3("VGA_SERIEN")[1]                         , 0 })  && Serie da Nf de saida
aadd(aVetCampos,{ "PEC_SERENT" , "C" , tamsx3("VG5_SERENT")[1]                         , 0 })  && Serie da Nf de Entrada
aadd(aVetCampos,{ "PEC_OK"     , "C" , 2                                               , 0 })  && Marca do browse

oObjTempTable := OFDMSTempTable():New()
oObjTempTable:cAlias := "PEC"
oObjTempTable:aVetCampos := aVetCampos
oObjTempTable:AddIndex(cArqIPec1, {"PEC_NUMOSV","PEC_GRUITE","PEC_CODITE"} )
oObjTempTable:AddIndex(cArqIPec2, {"PEC_CODCLI","PEC_LOJCLI","PEC_NUMOSV","PEC_GRUITE","PEC_CODITE"} )
oObjTempTable:CreateTable(.f.)

DbSelectArea("VGA")
DbSetOrder(1)
DbSeek(xFilial("VGA"))
Do while !EOF()

   If !IsMark("VGA_OK",ThisMark(),ThisInv())
		DbSelectArea("VGA")
      DbSkip() 
      Loop
   Endif

	If (( nOpc == 3 .And. Empty(VGA->VGA_NUMNFI)) ;
	   .Or. ( nOpc == 5 .And. !Empty(VGA->VGA_NUMNFI)))

		&& Posiciona nos arquivos              
	   DbSelectArea("VO1")
	   DbSetOrder(1)
	   DbSeek( xFilial("VO1") + VGA->VGA_NUMOSV )
	   DbSelectArea("VV1")
	   DbSetOrder(1)
	   DbSeek( xFilial("VV1") + VO1->VO1_CHAINT )
	   DbSelectArea("VE4")
	   DbSetOrder(1)
	   DbSeek( xFilial("VE4") + VV1->VV1_CODMAR )
	   DbSelectArea("SA1")
	   DbSetOrder(1)
	   DbSeek( xFilial("SA1") + VGA->VGA_CODCLI+VGA->VGA_LOJA )
	
	   DbSelectArea("VG5")
	   DbSetOrder(1)
	   DbSeek( xFilial("VG5") + VGA->VGA_CODMAR+VGA->VGA_NUMOSV )
	
	   While !Eof() .And. VG5->VG5_FILIAL+VG5->VG5_CODMAR+VG5->VG5_NUMOSV == xFilial("VG5")+VGA->VGA_CODMAR+VGA->VGA_NUMOSV
	      
	      If VG5->VG5_TRANSM == "S" .And. !Empty(VG5->VG5_PECINT) ;
	      	.And. ( nOpc == 3 .Or. VG5->VG5_NUMNFI+VG5->VG5_SERIEN == VGA->VGA_NUMNFI+VGA->VGA_SERIEN ) 
	      
			   DbSelectArea("SB0")
			   DbSetOrder(1)
			   DbSeek( xFilial("SB0") + VG5->VG5_PECINT )
			   DbSelectArea("SB1")
			   DbSetOrder(7)
			   DbSeek( xFilial("SB1") + VG5->VG5_GRUITE+VG5->VG5_CODITE )
			   DbSelectArea("SB5")
			   DbSetOrder(1)
			   DbSeek( xFilial("SB5") + SB1->B1_COD )
	
				DbSelectArea("PEC")
				RecLock("PEC",.T.)
				PEC->PEC_CODMAR := VG5->VG5_CODMAR
				PEC->PEC_NUMOSV := VG5->VG5_NUMOSV
				PEC->PEC_GRUITE := VG5->VG5_GRUITE
				PEC->PEC_CODITE := VG5->VG5_CODITE
				PEC->PEC_DESITE := SB1->B1_DESC
				PEC->PEC_PECINT := VG5->VG5_PECINT
				PEC->PEC_QTDITE := VG5->VG5_QTDITE
				PEC->PEC_QTDREC := VG5->VG5_QTDREC
				PEC->PEC_VAEXNF := Round(FG_Formula(VE4->VE4_FOEXNF),2)
				PEC->PEC_VAIMNF := Round(FG_Formula(VE4->VE4_FOIMNF),2)
				PEC->PEC_PROVEI := VO1->VO1_PROVEI
				PEC->PEC_LOJPRO := VO1->VO1_LOJPRO
				PEC->PEC_CODCLI := VGA->VGA_CODCLI
				PEC->PEC_LOJCLI := VGA->VGA_LOJA
				PEC->PEC_NOMCLI := SA1->A1_NOME
				PEC->PEC_CGCCLI := SA1->A1_CGC
				PEC->PEC_CGCFAB := VE4->VE4_CGCFAB
				PEC->PEC_CONPGT := VE4->VE4_PGTPED
				PEC->PEC_CODDEF := VG5->VG5_CODDEF
				PEC->PEC_ENVOBR := SB1->B1_ENVOBR
				PEC->PEC_NUMNFI := VGA->VGA_NUMNFI
				PEC->PEC_SERIEN := VGA->VGA_SERIEN
				PEC->PEC_ORDNFI := VG5->VG5_ORDNFI
				PEC->PEC_NFIENT := VG5->VG5_NFIENT
				PEC->PEC_SERENT := VG5->VG5_SERENT
				PEC->PEC_OK     := "  "
				If nOpc == 5	
					PEC->PEC_OK  := cMarca
				EndIf	
				MsUnLock()
	
	      EndIf        
	      
			DbSelectArea("VG5")
	      DbSkip()
	   Enddo
 
	EndIf   
 
   DbSelectArea("VGA")
   DbSkip()
   
Enddo

If PEC->(RecCount()) # 0
                   
	DbSelectArea("PEC")
	DbSetOrder(1)
	DbGoTop()

	DEFINE MSDIALOG oDlgNfR TITLE OemtoAnsi(STR0015)+" - "+If(Empty(cTipOpe),STR0034,STR0035)+STR0036 FROM  39,20 TO 59,100 OF oMainWnd
	                   
	oLbox := MsSelect():New("PEC","PEC_OK",,aCampos,@lInverte,@cMarca,{002,001,130,315},,,oDlgNfR)

	oLbox:oBrowse:BlDblClick := {|| FS_GM130FLAG(nOpca) }

   DEFINE SBUTTON FROM 135,200 TYPE 4 ACTION (A020Inclui("SA2",SA2->(Recno()),3)) ENABLE ONSTOP STR0037 OF oDlgNfr
   DEFINE SBUTTON FROM 135,240 TYPE 1 ACTION (Processa( { || FS_SELITENS(nOpca) } ),If(!lMsErroAuto,oDlgNfr:End(),.f.)) ENABLE ONSTOP If(nOpc==5,STR0017,STR0005)+STR0038 OF oDlgNfr
   DEFINE SBUTTON FROM 135,280 TYPE 2 ACTION (oDlgNfr:End()) ENABLE OF oDlgNfr

	ACTIVATE MSDIALOG oDlgNfR CENTER 

EndIf

DbSelectArea("PEC")
oObjTempTable:CloseTable()
	
DbSelectArea("VGA")
DbSetOrder(nIndex)
sRestArea(aArea)

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³FS_SELITENS³ Autor ³Renata                ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Montagem dos vetores com as pecas marcadas                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³GM130M(cAlias,nReg,nOpc)                                    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Garantia                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SELITENS(nOpc)

Local nPos := 0               
Local aArea:={}, cMsgNf := ""
Local aItemEnt    := {}
Local aItemSaida  := {}
Local j:=0

Private aNotaEnt := {} , aNotaSai := {}
private cSerie   := ""
private lFormul  := .t.
Private cRecInt  := ""
Private cCodMar  := ""

lMsHelpAuto := .t.
lMsErroAuto := .f.

aArea := sGetArea(aArea , Alias())
aArea := sGetArea(aArea , "PEC")

If nOpc # 5
	lFormul := Sx5NumNota()   
EndIf	

ProcRegua( PEC->(RecCount()) ) 

DbSelectArea("PEC")
DbSetOrder(2)
DbGoTop()
Do While !PEC->(Eof())
   
	&& Registro selecionado
	If PEC->PEC_OK == cMarca
	
		&& Monta itens da nf de entrada	
	   If PEC->PEC_CODDEF != "CS "  						// Desconsidera Recalls
	   
	   	If Len(aItemEnt) == 0 .Or. aItemEnt[Len(aItemEnt),1,12]+aItemEnt[Len(aItemEnt),1,2] # PEC->PEC_CGCCLI+PEC->PEC_NUMOSV
	         aAdd(aItemEnt,{})
			EndIf
				   
	      If Len(aItemEnt[Len(aItemEnt)]) == 0 .Or. (nPos := aScan(aItemEnt[Len(aItemEnt)],{|x| x[3] == PEC->PEC_PECINT })) == 0
	      
	         aAdd(aItemEnt[Len(aItemEnt)],{PEC->PEC_CODMAR,PEC->PEC_NUMOSV,;
							                        PEC->PEC_PECINT,PEC->PEC_CODITE,PEC->PEC_VAIMNF,;
							                        PEC->PEC_QTDITE,PEC->PEC_PROVEI,PEC->PEC_LOJPRO,.f.,PEC->PEC_CODCLI,PEC->PEC_LOJCLI,PEC->PEC_CGCCLI,PEC->PEC_NFIENT,PEC->PEC_SERENT })
	                       
	      Else
	          aItemEnt[Len(aItemEnt),nPos,6] += PEC->PEC_QTDITE
	      EndIf
	
	   EndIf                          
	   
	   && Monta itens da nf de saida
	   If Len(aItemSaida) == 0 .Or. ( nPos := Ascan(aItemSaida,{|x| x[2]+x[3] == PEC->PEC_NUMOSV+PEC->PEC_PECINT }) ) == 0
	
	      aAdd(aItemSaida,{PEC->PEC_CODMAR,PEC->PEC_NUMOSV,;
	                       PEC->PEC_PECINT,PEC->PEC_CODITE,PEC->PEC_VAEXNF,;
	                       If(PEC->PEC_CODDEF == "CS ",PEC->PEC_QTDREC,PEC->PEC_QTDITE),PEC->PEC_PROVEI,PEC->PEC_LOJPRO,.f.,PEC->PEC_CODCLI,PEC->PEC_LOJCLI,PEC->PEC_CGCFAB,PEC->PEC_NUMNFI,PEC->PEC_SERIEN,PEC->PEC_ORDNFI,If(PEC->PEC_CODDEF == "CS ",.T.,.F.)})
	
	   Else
	      aItemSaida[nPos,6]  += If(PEC->PEC_CODDEF == "CS ",PEC->PEC_QTDREC,PEC->PEC_QTDITE)
	   Endif
   
   Elseif PEC->PEC_ENVOBR == "S"
      Help(" ",1,"OFIGM13008")        //peca de envio obrigatorio nao marcada
	   DisarmTransaction()
	   Break
	EndIf

	IncProc( OemtoAnsi( STR0039 ) )   

	DbSelectArea("PEC")
	DbSkip()
        
EndDo

If Len(aItemSaida) == 0
   Help(" ",1,"OFIGM13009")           //nao existe pecas marcadas para emissao
	sRestArea(aArea)
   Return( .f.)
EndIf

ProcRegua( Len(aItemEnt)+Len(aItemSaida) ) 

Begin Transaction
	                                
	&& Gera nf de entrada por cliente
	If nOpc == 3
		For nPos := 1 To Len(aItemEnt)
	      //NF Entrada - 10% do valor do preco de venda, Tributada
	      FS_ENTNFVW(aItemEnt[nPos],@aNotaEnt,nOpc)
	   Next   
	EndIf
		
	&& Gera/exclui nf de saida para a fabrica
	If Len(aItemSaida) # 0
	
	   FS_SAI1(aItemSaida,@aNotaSai,nOpc)         //nf saida - 10% do valor do preco de venda, tributada
	
	EndIf         
	
	&& Exclui nf de entrada por cliente
	If nOpc == 5
		For nPos := 1 To Len(aItemEnt)
	      //NF Entrada - 10% do valor do preco de venda, Tributada
	      FS_ENTNFVW(aItemEnt[nPos],@aNotaEnt,nOpc)
	   Next   
	EndIf
		
End Transaction    
        
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ TEMPORARIO - Desbloqueia SX6 pois a MAPVLNFS esta na dentro da Transacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
dbSelectArea("SX6")
MsRUnLock()

If lMsErroAuto 

   MostraErro()

	sRestArea(aArea)

	lMsHelpAuto := .f.
	lMsErroAuto := .t.
	
	Return( .f. )

Else

	//Executa RdMake do relatorio de pecas para envio
	If ExistBlock("RLPCDVFB")
	   ExecBlock("RLPCDVFB",.f.,.f.)
	Endif   
	
	//Executa RdMake da Nota Fiscal de Entrada
	If ExistBlock("NFENTRADA")
		For j:=1 to Len(aNotaEnt)
		   ExecBlock("NFENTRADA",.f.,.f.,aNotaEnt[j])
		Next
	Endif   
	             
	//Executa RdMake da Nota Fiscal
	If ExistBlock("NFPECSER") .And. Len(aNotaSai) # 0
		ExecBlock("NFPECSER",.f.,.f.,aNotaSai[1])
	EndIf
      
	&& Mostra quais Nf foram geradas
	cMsgNf += STR0040
	For j:=1 to Len(aNotaEnt)
		cMsgNf += Chr(13)+aNotaEnt[j,1]+" "+aNotaEnt[j,2]
	Next                      
	
	If Len(aNotaSai) # 0
		cMsgNf += Chr(13)+Chr(13)+STR0041
		cMsgNf += Chr(13)+aNotaSai[1,1]+" "+aNotaSai[1,2]+Chr(13)
	EndIf

	MsgInfo(cMsgNf,STR0042+If(nOpc==5,STR0043,""))	
                   
	If nOpc == 3

//		If !Empty(cRecInt)
//			OFIIA200(2,cCodMar,GetNewPar("MV_OGM130","202"),"StrZero(SF2->(Recno()),10) $ cRecInt",,,,.t.)
//		EndIf 

	EndIf 

EndIf 

sRestArea(aArea)
Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Funcao    ³FS_ENTNFVW³ Autor ³Andre                  ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³Montagem do vetor para a chamda do MATA100 nota fiscal de   ³±±
±±³          ³entrada tributada com 10% do valor do item                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³Garantia                                                    ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_ENTNFVW(aItemEnt,aNotaEnt,nOpc)
                     
Local aCabNFE        := {}
Local aIteTempNFE    := {}
Local aIteNFE        := {}
Local aCabFornecedor := {}
Local cNumero        := ""
Local i              := 0 
Local cCf            := ""
Local cTes
Local cCont				:= "00"
Default nOpc := 3
 
DbSelectArea("SA1")
DbSetOrder(3)
DbSeek( xFilial("SA1") + aItemEnt[1,12] )

DbSelectArea("SA2")
DbSetOrder(3)
DbSeek( xFilial("SA2") + aItemEnt[1,12] )

If !Found()
     
	aAdd(aCabFornecedor,{"A2_COD"     ,CriaVar("A2_COD") 		,Nil}) //
	aAdd(aCabFornecedor,{"A2_LOJA"    ,CriaVar("A2_LOJA")    ,Nil}) //
	aAdd(aCabFornecedor,{"A2_NOME"    ,SA1->A1_NOME   			,Nil}) //
	aAdd(aCabFornecedor,{"A2_TIPO"    ,SA1->A1_TIPO   			,Nil}) //
	aAdd(aCabFornecedor,{"A2_CGC"     ,SA1->A1_CGC   			,Nil}) //
	aAdd(aCabFornecedor,{"A2_NREDUZ"  ,SA1->A1_NREDUZ 			,Nil}) //
	aAdd(aCabFornecedor,{"A2_END"  	 ,SA1->A1_END	 			,Nil}) //
	aAdd(aCabFornecedor,{"A2_BAIRRO"	 ,SA1->A1_BAIRRO 			,Nil}) //
	aAdd(aCabFornecedor,{"A2_MUN"		 ,SA1->A1_MUN	 			,Nil}) //
	aAdd(aCabFornecedor,{"A2_EST"		 ,SA1->A1_EST	 			,Nil}) //
	aAdd(aCabFornecedor,{"A2_CEP"		 ,SA1->A1_CEP	 			,Nil}) //
	aAdd(aCabFornecedor,{"A2_DDD"		 ,SA1->A1_DDD	 			,Nil}) //
	aAdd(aCabFornecedor,{"A2_TEL"		 ,SA1->A1_TEL	 			,Nil}) //
	aAdd(aCabFornecedor,{"A2_FAX"		 ,SA1->A1_FAX	 			,Nil}) //
	aAdd(aCabFornecedor,{"A2_EMAIL"	 ,SA1->A1_EMAIL 			,Nil}) //
	aAdd(aCabFornecedor,{"A2_ATIVIDA" ,"000001"		 			,Nil}) //
	aAdd(aCabFornecedor,{"A2_SATIV1"  ,"000001"		 			,Nil}) //
	
	ConfirmSx8()                               

	MsErroAuto := .f.
	MSExecAuto({|x,y| MATA020(x)},aCabFornecedor)
	If lMsErroAuto 
	   DisarmTransaction()
	   Break
	EndIf

EndIf

DbSelectArea("SA2")
DbSetOrder(3)
If !DbSeek( xFilial("SA2") + aItemEnt[1,12] )
   Help("  ",1,"NFOUND",,STR0051+Chr(13)+STR0052+aItemEnt[1,12],4,1)
   DisarmTransaction()
   Break
EndIf

If nOpc # 5
	If lFormul
	   cNumero := NxtSX5Nota(cSerie)
	EndIf
Else
	cNumero := aItemEnt[1,13]
	cSerie  := aItemEnt[1,14]
EndIf              

IncProc( OemtoAnsi(STR0044+cNumero+" "+FGX_UFSNF(cSerie)+STR0045+SA2->A2_COD+" "+SA2->A2_LOJA+" "+SA2->A2_NOME ) )

aAdd(aCabNFE,{"F1_TIPO"    ,"N"            			,Nil}) //
aAdd(aCabNFE,{"F1_ESPECIE" ,GetNewPar("MV_ESPECNF","NF"),Nil})
//aAdd(aCabNFE,{"F1_ESPECIE" ,"NF"           			,Nil}) //
aAdd(aCabNFE,{"F1_FORMUL"  ,"S"            			,Nil}) //
aAdd(aCabNFE,{"F1_DOC"     ,cNumero        			,Nil}) //
aAdd(aCabNFE,{"F1_SERIE"   ,cSerie         			,Nil}) //
aAdd(aCabNFE,{"F1_EMISSAO" ,dDataBase      			,Nil}) //
aAdd(aCabNFE,{"F1_FORNECE" ,SA2->A2_COD     			,Nil}) //
aAdd(aCabNFE,{"F1_LOJA"    ,SA2->A2_LOJA 		      ,Nil}) //
aAdd(aCabNFE,{"F1_ICMSRET" ,0          		      ,Nil}) //
aAdd(aCabNFE,{"F1_COND"    ,GetMv("MV_CONDNFR")   ,Nil}) //

lMSHelpAuto := .t.
cCont := "00"
   
For i:=1 to len(aItemEnt)
   
   aIteTempNFE := {}

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek( xFilial("SB1") + aItemEnt[i,3] )

   cTes := FG_TABTRIB(VE4->VE4_CDOPEN,SB1->B1_ORIGEM) //SIMPLES REMESSA
     
	DbSelectArea("SF4")
	DbSetOrder(1)
	DbSeek( xFilial("SF4") + cTes )

	cCF := If(SA2->A2_TIPO != "X",iif(SA2->A2_EST == alltrim(GetMv("MV_ESTADO")),SF4->F4_CF,"2"+;
                Subs(SF4->F4_CF,2,LEN(SF4->F4_CF)-1)),"3"+Subs(SF4->F4_CF,2,LEN(SF4->F4_CF)-1))

	cCont := Soma1( cCont , 2 )

	If nOpc # 5
	   aAdd(aIteTempNFE,{"D1_ITEM"    ,cCont                       ,Nil}) 
	   aAdd(aIteTempNFE,{"D1_COD"     ,aItemEnt[i,3]               ,Nil}) 
	   aAdd(aIteTempNFE,{"D1_UM"      ,"PC"                         ,Nil}) 
	   aAdd(aIteTempNFE,{"D1_QUANT"   ,aItemEnt[i,6]               ,Nil})
	   aAdd(aIteTempNFE,{"D1_VUNIT"   ,aItemEnt[i,5]               ,Nil}) 
	   aAdd(aIteTempNFE,{"D1_TOTAL"   ,aItemEnt[i,5]*aItemEnt[i,6] ,Nil})
	  	aAdd(aIteTempNFE,{"D1_EMISSAO" ,dDataBase                    ,Nil})
	   aAdd(aIteTempNFE,{"D1_VALIPI"  ,0                            ,Nil}) 
	   aAdd(aIteTempNFE,{"D1_VALICM"  ,0                            ,Nil}) 
	   aAdd(aIteTempNFE,{"D1_BASEIPI" ,0                            ,Nil}) 
	   aAdd(aIteTempNFE,{"D1_BASEICM" ,0                            ,Nil}) 
	   aAdd(aIteTempNFE,{"D1_TES"     ,cTES                         ,Nil}) 
	   aAdd(aIteTempNFE,{"D1_CONTA"   ,SB1->B1_CONTA                ,Nil}) 
	   aAdd(aIteTempNFE,{"D1_CC"      ,Space(9)                     ,Nil}) 
	   aAdd(aIteTempNFE,{"D1_RATEIO"  ,"2"                          ,Nil})
	   aAdd(aIteTempNFE,{"D1_LOCAL"   ,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"),Nil}) 
	   aAdd(aIteTempNFE,{"D1_LOCPAD"  ,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"),Nil}) 
		aAdd(aIteTempNFE,{"D1_FORNECE" ,SA2->A2_COD                  ,Nil}) 
		aAdd(aIteTempNFE,{"D1_LOJA"    ,SA2->A2_LOJA                 ,Nil}) 
	
	   aadd(aIteNFE,aIteTempNFE)
	Else
		aAdd(aIteTempNFE,{"D1_DOC"     ,cNumero        ,Nil})
		aAdd(aIteTempNFE,{"D1_SERIE"   ,cSerie         ,Nil})
		aAdd(aIteTempNFE,{"D1_FORNECE" ,SA2->A2_COD    ,Nil})
		aAdd(aIteTempNFE,{"D1_LOJA   " ,SA2->A2_LOJA   ,Nil})
		aAdd(aIteTempNFE,{"D1_COD"     ,aItemEnt[i,3]  ,Nil})
		aAdd(aIteTempNFE,{"D1_ITEM"    ,cCont			   ,Nil})
	   
		aAdd(aIteNFE,aClone(aIteTempNFE))
	EndIf
	
Next

SB1->(DbSetOrder(1))
MsErroAuto := .f.
MSExecAuto({|x,y,z| MATA103(x,y,z)},aCabNFE,aIteNFE,nOpc)
If lMsErroAuto 
   DisarmTransaction()
   Break
EndIf

Aadd(aNotaEnt, { cNumero , cSerie })

&& Grava nro da Nf nos arquivos VGA/VG5
For i := 1 to len(aItemEnt)
	
   DbSelectArea("VG5")	
   DbSetOrder(1)
   DbSeek( xFilial("VG5") + aItemEnt[i,1] + aItemEnt[i,2] + aItemEnt[i,3] )
   Do While !Eof() .And. VG5->VG5_FILIAL+VG5->VG5_CODMAR+VG5->VG5_NUMOSV+VG5->VG5_PECINT == xFilial("VG5") + aItemEnt[i,1] + aItemEnt[i,2] + aItemEnt[i,3]

	   RecLock("VG5",.f.)
	   VG5->VG5_NFIENT := If( nOpc==5,Space(6),cNumero)
	   VG5->VG5_SERENT := If( nOpc==5,Space(3),cSerie)
	   If lsDoc	                                                
		VG5->VG5_SDOCE := FGX_UFSNF(VG5->VG5_SERENT)
           Endif
	   MsUnLock()
	   
	   DbSelectArea("VG5")
	   DbSkip()

	EndDo				

Next

Return
  
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³ FS_SAI1  ³ Autor ³Andre                  ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Montagem do vetor para a chamda do MATA410                 ³±±
±±³          ³ nota fiscal de saida tributada c/ 10% do valor do item     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ FS_SAI1()                                                  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ Garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function FS_SAI1(aItemSaida,aNotaSai,nOpc)

Local aCabPv    := {} , aItePv := {} , aIteTempPV := {} , aPvlNfs := {} , aMata520Cab := {}
Local cNota, cCfiscal, cCont := "00" , i := 0

Private cNumped
                                     
Default nOpc := 3
             
cCodMar     := aItemSaida[1,1]
        
lMSHelpAuto := .t.
lMsErroAuto := .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Geracao e Liberacao dos Pedidos de Venda                            ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea("VAI")
DbSetOrder(4)
DbSeek( xFilial("VAI") + __cUserID )
DbSelectArea("SA3")
DbSetOrder(1)
DbSeek( xFilial("SA3") + VAI->VAI_CODVEN )
DbSelectArea("SA1")
DbSetOrder(3)
DbSeek( xFilial("SA1") + aItemSaida[1,12] )

IncProc( OemtoAnsi( STR0046+SA1->A1_COD+" "+SA1->A1_LOJA+" "+SA1->A1_NOME ) )

If nOpc # 5	&& Gera a Nf de Saida

	cNumped  := CriaVar("C5_NUM")
	
	//Cabecalho
	aAdd(aCabPV,{"C5_NUM"    ,cNumped          ,Nil}) // Numero do pedido
	aAdd(aCabPV,{"C5_TIPO"   ,"N"              ,Nil}) // Tipo de pedido
	aAdd(aCabPV,{"C5_CLIENTE",SA1->A1_COD      ,Nil}) // Codigo do cliente
	aAdd(aCabPV,{"C5_LOJAENT",SA1->A1_LOJA     ,Nil}) // Loja para entrada
	aAdd(aCabPV,{"C5_LOJACLI",SA1->A1_LOJA     ,Nil}) // Loja do cliente
	aAdd(aCabPV,{"C5_CONDPAG",RetCondVei()    ,Nil}) // Codigo da condicao de pagamanto - SE4
	aAdd(aCabPV,{"C5_TABELA" ,"1"              ,Nil}) // Codigo da Tabela de Preco
	aAdd(aCabPV,{"C5_VEND1"  ,SA3->A3_COD     ,Nil}) // Codigo do vendedor - SA3
	aAdd(aCabPV,{"C5_EMISSAO",dDataBase        ,Nil}) // Data de emissao
	aAdd(aCabPV,{"C5_TIPOCLI",SA1->A1_TIPO     ,Nil}) // Tipo do Cliente
	aAdd(aCabPV,{"C5_DESC1"  ,0                ,Nil}) // Percentual de Desconto
	aAdd(aCabPV,{"C5_INCISS" ,"N"              ,Nil}) // ISS Incluso
	aAdd(aCabPV,{"C5_TIPLIB" ,"2"              ,Nil}) // 
	aAdd(aCabPV,{"C5_MOEDA"  ,1                ,Nil}) // Moeda
	aAdd(aCabPV,{"C5_LIBEROK","S"              ,Nil}) // Liberacao Total
	aAdd(aCabPV,{"C5_COMIS1" ,0                ,Nil}) // Percentual de Comissao

	If SC5->(FieldPos("C5_INDPRES")) > 0 
		aAdd(aCabPV,{"C5_INDPRES"  ,'0'	,Nil}) 	// Presenca do Comprador
	Endif

	cCont := "00"
	
	For i := 1 to len(aItemSaida)
	   
	   aIteTempPV := {}
	   
	   //Itens
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek( xFilial("SB1") + aItemSaida[I,3] )
		
	   If aItemSaida[i,16]   // Recall deve usar TES diferente
	      cTes := "540"  // Fixo provisoriamente por necessidade urgente de emissao da nf
	      cCFiscal := FG_CLAFIS(cTes)
	   Else          
	      cTes := FG_TABTRIB(VE4->VE4_CDOPSA,SB1->B1_ORIGEM) //SIMPLES REMESSA
	      cCFiscal := FG_CLAFIS(cTes)
	   EndIf
	   
		DbSelectArea("SB5")
		DbSetOrder(1)
		DbSeek( xFilial("SB5") + SB1->B1_COD )
		DbSelectArea("SB2")
		DbSetOrder(1)
		DbSeek( xFilial("SB2") + SB1->B1_COD )
		DbSelectArea("SF4")
		DbSetOrder(1)
		DbSeek( xFilial("SF4") + cTes )    
		
		cCont := Soma1( cCont , 2 )             
		
		aItemSaida[I,15] := cCont

	   aAdd(aIteTempPV,{"C6_NUM"    ,cNUMPED               				,Nil}) // Numero do Pedido
	   aAdd(aIteTempPV,{"C6_ITEM"   ,cCont			         				,Nil}) // Numero do Item no Pedido
	   aAdd(aIteTempPV,{"C6_PRODUTO",aItemSaida[i,3]           			,Nil}) // Codigo do Produto
	   aAdd(aIteTempPV,{"C6_QTDVEN" ,aItemSaida[i,6]           			,Nil}) // Quantidade Vendida
	   aAdd(aIteTempPV,{"C6_PRUNIT" ,aItemSaida[i,5]           			,Nil}) // Preco Unitario Liquido
	   aAdd(aIteTempPV,{"C6_PRCVEN" ,aItemSaida[i,5]           			,Nil}) // Preco Unitario Liquido
	   aAdd(aIteTempPV,{"C6_VALOR"  ,aItemSaida[i,5]*aItemSaida[i,6] ,Nil}) // Valor Total do Item
	   aAdd(aIteTempPV,{"C6_ENTREG" ,dDataBase             				,Nil}) // Data da Entrega
	   aAdd(aIteTempPV,{"C6_UM"     ,"PC"                  				,Nil}) // Unidade de Medida Primar.
	   aAdd(aIteTempPV,{"C6_TES"    ,cTes                  				,Nil}) // Tipo de Entrada/Saida do Item
	   aAdd(aIteTempPV,{"C6_LOCAL"  ,FM_PRODSBZ(SB1->B1_COD,"SB1->B1_LOCPAD"),Nil}) // Almoxarifado
	   aAdd(aIteTempPV,{"C6_CF"     ,cCfiscal            					,Nil}) // CFO
	   aAdd(aIteTempPV,{"C6_VALDESC",0                     				,Nil}) // Valor do Desconto
	   aAdd(aIteTempPV,{"C6_COMIS1" ,0                     				,Nil}) // Comissao Vendedor
	   aAdd(aIteTempPV,{"C6_DESCRI" ,SB1->B1_DESC          				,Nil}) // Descricao do Produto
	   aAdd(aIteTempPV,{"C6_CLI"    ,SA1->A1_COD           				,Nil}) // Cliente
	   aAdd(aIteTempPV,{"C6_LOJA"   ,SA1->A1_LOJA          				,Nil}) // Loja do Cliente
	   If GetVersao(.f.) == "P10"
		   	aAdd(aIteTempPV,{"C6_QTDEMP" ,aItemSaida[i,6]            		,Nil}) // Quantidade Empenhada
	   Endif
	//   aAdd(aIteTempPV,{"C6_QTDLIB" ,aItemSaida[i,6]            			,Nil}) // Quantidade Liberada
	
	   aAdd(aItePv,aIteTempPV)
	
	Next
	
	lMSHelpAuto := .t.              
	lMsErroAuto := .f.
	MsExecAuto({|x,y,z| mata410(x,y,z)},aCabPV,aItePv,3)
	If lMsErroAuto 
	   DisarmTransaction()
	   Break
	EndIf                       
	
	lCredito := .t.
	lEstoque := .t.
	lLiber   := .t.
	lTransf  := .f.
	
	dbSelectArea("SC6")
	dbSetOrder(1)
	dbSeek(xFilial("SC6")+cNumPed+"01")
	While !eof() .and. SC6->C6_FILIAL == xFilial("SC6") .and. SC6->C6_NUM == cNumPed
	   nQtdLib := SC6->C6_QTDVEN
	   cChavSC9 := cNumPed+SC6->C6_ITEM
	   FG_Seek("SC9","cChavSC9")
	   nQtdLib := MaLibDoFat(SC6->(RecNo()),nQtdLib,@lCredito,@lEstoque,.F.,.F.,lLiber,lTransf)
	   dbSelectArea("SC6")
	   dbSkip()
	Enddo
	
	DbSelectArea("SC9")
	FG_Seek("SC9","cNumPed+'01'")
	While !Eof() .And. SC9->C9_FILIAL+SC9->C9_PEDIDO == xFilial("SC9")+cNumPed
	
	   If Empty(SC9->C9_BLCRED) .And. Empty(SC9->C9_BLEST)
	      FG_Seek("SB1","SC9->C9_PRODUTO",1)
	      FG_Seek("SC5","SC9->C9_PEDIDO",1,.F.)
	      FG_Seek("SC6","SC9->C9_PEDIDO+SC9->C9_ITEM",1)
	      FG_Seek("SB5","SB1->B1_COD")
	      FG_Seek("SB2","SB1->B1_COD")
	      FG_Seek("SF4","SC6->C6_TES")
	      FG_Seek("SE4","RetCondVei()",1)  //Tem que ser Tipo A para nao criar E1 automatico
	
	      aAdd(aPvlNfs,{C9_PEDIDO,;
	                     C9_ITEM,;
	                     C9_SEQUEN,;
	                     C9_QTDLIB,;
	                     C9_PRCVEN,;
	                     C9_PRODUTO,;
	                     SF4->F4_ISS=="S",;
	                     SC9->(RecNo()),;
	                     SC5->(RecNo()),;
	                     SC6->(RecNo()),;
	                     SE4->(RecNo()),;
	                     SB1->(RecNo()),;
	                     SB2->(RecNo()),;
	                     SF4->(RecNo())})
	   Else       
	      MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabPv,aItePv,5)
	   EndIf
	   DbSkip()
	Enddo
	
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Gera F2/D2, Atualiza Estoque, Financeiro, Contabilidade             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	//cNota := MaPvlNfs(aPvlNfs,cSerie, .F., .F., .T., .T., .F., 0, 0, .T., .F.)
	cNota := MaPvlNfs(aPvlNfs,cSerie, .F., .F., .F., .T., .F., 0, 0, .T., .F.)

	cRecInt += StrZero(SF2->(Recno()),10)+"/"
	
Else    		&& Exclui a Nf de saida
           
	cNota  := aItemSaida[1,13]
	cSerie := aItemSaida[1,14]
	
	DbSelectArea("SD2")
	DbSetOrder(3)
	DbSeek(xFilial("SD2") + cNota + cSerie + SA1->A1_COD + SA1->A1_LOJA  )
	
	cNumPed := SD2->D2_PEDIDO
	
	// Exclui Nota
	aMata520Cab   := {{"F2_DOC"      , cNota  ,Nil},; //numero da nota
							{"F2_SERIE"    , cSerie ,Nil}}  //serie
	
	lMSHelpAuto := .t.
	lMsErroAuto := .f.
	MSExecAuto({|x| MATA520(x)},aMata520Cab)
	
	If lMsErroAuto 
	   DisarmTransaction()
	   Break
	EndIf                       
	
	// Exclui Pedido	
	SC9->(DbSetOrder(1))
	SC9->(DbSeek(xFilial("SC9")+cNumPed))
	While !SC9->(Eof()) .And. xFilial('SC9') == SC9->C9_FILIAL .and. cNumPed == SC9->C9_PEDIDO
		SC9->(a460Estorna())
		SC9->(dbSkip())
	EndDo
	
	aCabPV := {{"C5_NUM"    , cNumPed     ,Nil}} //numero do pedido
	aItePv := {{"C5_NUM"    , cNumPed     ,Nil}} //numero do pedido
	
	lMSHelpAuto := .t.
	lMsErroAuto := .f.
	MSExecAuto({|x,y,z| MATA410(x,y,z)},aCabPV,{aItePv},5)
	
	If lMsErroAuto 
	   DisarmTransaction()
	   Break
	EndIf                       
	
EndIf

aadd(aNotaSai,{cNota,cSerie})            

&& Grava nro da Nf nos arquivos VGA/VG5
For i := 1 to len(aItemSaida)
	
	DbSelectArea("VGA")	
	DbSetOrder(1)
	If DbSeek(xFilial("VGA")+aItemSaida[i,1]+aItemSaida[i,2])
	
	   RecLock("VGA",.f.)
	   VGA->VGA_NUMNFI := If( nOpc==5,Space(6),aNotaSai[1,1])
	   VGA->VGA_SERIEN := If( nOpc==5,Space(3),aNotaSai[1,2])
	   If lsDoc	                                                
	       VGA->VGA_SDOCE := FGX_UFSNF(VGA->VGA_SERIEN)
	   Endif
	   VGA->VGA_OK     := ""
	   MsUnLock()
	    
	   DbSelectArea("VG5")	
	   DbSetOrder(1)
	   DbSeek(xFilial("VG5")+VGA->VGA_CODMAR+VGA->VGA_NUMOSV+aItemSaida[i,3])
	   Do While !Eof() .And. VG5->VG5_FILIAL+VG5->VG5_CODMAR+VG5->VG5_NUMOSV+VG5->VG5_PECINT == xFilial("VG5")+VGA->VGA_CODMAR+VGA->VGA_NUMOSV+aItemSaida[i,3]
	
		   RecLock("VG5",.f.)
		   VG5->VG5_NUMNFI := VGA->VGA_NUMNFI
		   VG5->VG5_SERIEN := VGA->VGA_SERIEN
		   If lsDoc	                                                
			VG5->VG5_SDOCS := FGX_UFSNF(VG5->VG5_SERIEN)
		   Endif

		   VG5->VG5_ORDNFI := If( nOpc==5,Space(2),aItemSaida[i,15])
		   MsUnLock()
		   
		   DbSelectArea("VG5")
		   DbSkip()
	
		EndDo				
	    
	EndIf

Next

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡…o    ³GM130V    ³ Autor ³Renata                 ³ Data ³ 25/11/99 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³ Visualiza dados do VGA/VG5 modelo 3                        ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe e ³ GM130V(cAlias,nReg,nOpc)                                   ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³                                                            ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso      ³ garantia                                                   ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GM130V(cAlias,nReg,nOpc)

Local bCampo   := { |nCPO| Field(nCPO) }
Local nCntFor := 0 , _ni := 0 , nUsado := 0
Local cTitulo , cAliasEnchoice , cAliasGetD , cLinOk , cTudOk , cFieldOk  

Private aRotina := { { "" ,"", 0 , 1   },;
                     { "" ,"", 0 , 2   },;    //VIZUALIZAR
                     { "" ,"", 0 , 4   },;   //LIBERAR
                     { "","",  0,  4   }}
Private aCols := {} , aHeader := {} , aCpoEnchoice := {}
         
DbSelectArea("VGA")
      
If !&(cCond)

	DbSetOrder(nIndex)     
	Return

EndIf      
                     
Inclui := .f.

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria variaveis M->????? da Enchoice                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
RegToMemory("VGA",.t.)         // .t. para carregar campos virtuais

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VGA")

While !Eof().And.(x3_arquivo=="VGA")
   
   if X3USO(x3_usado).And.cNivel>=x3_nivel.And.!( Alltrim(x3_campo) $ [VGA_TRANSM/VGA_EXCLUI/VGA_CODSER/VGA_SERINT/VGA_EXPGAR])
      AADD(aCpoEnchoice,x3_campo)
   Endif
   
   &( "M->" + Alltrim(x3_campo) ) := CriaVar(x3_campo)
   
   dbSkip()
   
End

If !(Inclui)
   DbSelectArea("VGA")
   For nCntFor := 1 TO FCount()
      M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
   Next
Endif

if nOpc == 3   //ALTERAR
   nOpcE := 4
   nOpcG := 4
elseif nOpc == 2  //VIZUALIZAR
   nOpcE := 2
   nOpcG := 2
else
   nOpcE := 5      //EXCLUIR
   nOpcG := 5
endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Cria aHeader e aCols da GetDados                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
nUsado:=0

dbSelectArea("SX3")
dbgotop()
dbSeek("VG5")

aHeader:={}

While !Eof().And.(x3_arquivo=="VG5")

   If X3USO(x3_usado).And.cNivel>=x3_nivel.And.!( Alltrim(x3_campo) $ [VG5_CODMAR/VG5_DESMAR/VG5_NUMOSV/VG5_TRANSM/VG5_EXCLUI/VG5_NOSNUP/VG5_NOSNUS])

      nUsado:=nUsado+1
      Aadd(aHeader,{ TRIM(X3Titulo()), x3_campo, x3_picture,;
         x3_tamanho, x3_decimal,x3_valid,;
         x3_usado, x3_tipo, x3_arquivo, x3_context, x3_relacao, x3_reserv } )
      
      &( "M->" + Alltrim(x3_campo) ) := CriaVar(x3_campo)

   Endif

   dbSkip()

End

If Inclui

   aCols:={Array(nUsado+1)}
   aCols[1,nUsado+1]:=.F.

   For _ni:=1 to nUsado
       aCols[1,_ni]:=CriaVar(aHeader[_ni,2])
   Next

Else

   aCols:={}
   dbSelectArea("VG5")
   dbSetOrder(1)
   dbSeek(xFilial()+M->VGA_CODMAR+M->VGA_NUMOSV)

   While !Eof() .And. VG5->VG5_CODMAR+VG5->VG5_NUMOSV == M->VGA_CODMAR+M->VGA_NUMOSV ;
                 .And. VG5->VG5_FILIAL == xFilial("VG5")

       AADD(aCols,Array(nUsado+1))

       For _ni:=1 to nUsado
           aCols[Len(aCols),_ni]:=If(aHeader[_ni,10] # "V",FieldGet(FieldPos(aHeader[_ni,2])),CriaVar(aHeader[_ni,2]))
       Next

       aCols[Len(aCols),nUsado+1]:=.F.

       dbSkip()

   End

   dbsetorder(1)

Endif

If Len(aCols)>0

   //ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
   //³ Executa a Modelo 3                                           ³
   //ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
   cTitulo       :=STR0001    //"Exclui Garantia"
   cAliasEnchoice:="VGA"
   cAliasGetD    :="VG5"
   cLinOk        :="AlwaysTrue()"
   cTudOk        :="AlwaysTrue()" 
   cFieldOk      :="FG_MEMVAR()"

   Modelo3(cTitulo,cAliasEnchoice,cAliasGetD,aCpoEnchoice,cLinOk,cTudOk,nOpcE,nOpcG,cFieldOk)

Endif
      
DbSelectArea("VGA")
DbSetOrder(nIndex)     

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_TIKGM130ºAutor  ³Fabio              º Data ³  03/25/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Marca                                                       º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_TIKGM130()
           
Local aArea:={}, cNumNf := VGA->VGA_NUMNFI, cSerNf := VGA->VGA_SERIEN, nRegMark:=VGA->(Recno())

aArea := sGetArea(aArea , Alias())
aArea := sGetArea(aArea , "VGA")
            
ProcRegua( VGA->(RecCount()) ) 
              
DbSelectArea("VGA") 
If ( !Empty(cNumNf) .Or. cNumNf+cSerNf # cTipOpe )
	DbGoTop()
EndIf	
Do While !Eof()
                   
	RecLock("VGA",.F.)	
	If Empty(cNumNf)                                          
		If (( VGA->VGA_OK == cMarca .And. nRegMark == Recno() ) .Or. !Empty(VGA->VGA_NUMNFI))
			VGA->VGA_OK := "  "
		ElseIf nRegMark == Recno()
			VGA->VGA_OK := cMarca
		EndIf	
	Else		
		If ( VGA->VGA_NUMNFI # cNumNf .Or. VGA->VGA_OK == cMarca )
			VGA->VGA_OK := "  "
		Else
			VGA->VGA_OK := cMarca
		EndIf	
	EndIf	
	MsUnLock()                  

	IncProc( OemtoAnsi( STR0039 ) )   

	If ( Empty(cNumNf) .And. cNumNf+cSerNf == cTipOpe )
		Exit
	EndIf	

	DbSelectArea("VGA")
	DbSkip()
               
EndDo
        
sRestArea(aArea)
MarkBRefresh()

cTipOpe := cNumNf+cSerNf

Return(.t.)

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FS_GM130FLºAutor  ³Fabio               º Data ³  03/25/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Marca box                                                   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function FS_GM130FLAG(nOpc)  

Local cMsg130 := ""

If nOpc # 5

	If Empty(PEC->PEC_CGCCLI)
		
	   DbSelectArea("SX3")
	   DbSetOrder(2)
	   SX3->(DbSeek( "A1_COD" ))
		cMsg130 += X3Titulo()+PEC->PEC_CODCLI+Chr(13)
	   SX3->(DbSeek( "A1_LOJA" ))
		cMsg130 += X3Titulo()+PEC->PEC_LOJCLI+Chr(13)
	   SX3->(DbSeek( "A1_CGC" ))
		cMsg130 += X3Titulo()+PEC->PEC_CODCLI+Chr(13)		

      Help(1," ","OBRIGAT",,cMsg130,4,1)
	   
	   DbSelectArea("SX3")
	   DbSetOrder(1)

	   Return                             
	   
	EndIf

	DbSelectArea("PEC")
	RecLock("PEC",.F.)	
	PEC->PEC_OK := If(PEC->PEC_OK # cMarca,cMarca,Space(Len(PEC->PEC_OK)))
	MsUnLock()
	
EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³MenuDef    ºAutor  ³Fabio              º Data ³  03/25/04   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Menu.				                                          º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Static Function MenuDef()
Local aRotina := {{ STR0002 ,"axPesqui", 0 , 1},; //Pesquisar
                 { STR0003 ,"GM130V"  , 0 , 2},;  //Visualizar
                 { STR0005 ,"GM130M"  , 0 , 3},;  //Emitir
                 { STR0017 ,"GM130M"  , 0 , 5}}   //Cancelar
Return aRotina
