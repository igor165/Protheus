#INCLUDE "HSPAHP30.CH"
#INCLUDE "PROTHEUS.CH"

/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³HSPAHP30  º Autor ³ José Roberto       º      ³  22/08/2002 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDescricao ³ Confirmação de Exames                                      º±±
±±º          ³                                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Administracao Hospitalar                                   º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/                      
Function HSPAHP30()

Local cF3 := HS_CfgSx3("GBX_SOLICI")[17]

Private oTik   := LoadBitmap( GetResources(), "LBTIK" )
Private oNo    := LoadBitmap( GetResources(), "LBNO" )

Define  FONT oFont NAME "Arial" BOLD

Inclui := .T.

If Empty(cF3)
	cF3 := "GBX"
Endif

DbSelectArea("GBX")
RegToMemory("GBX",.T.)

M->GBX_SOLICI  := Space(Len(M->GBX_SOLICI))  // Usado para limpar o inicializador padrao.
M->GBX_DATSOL  := CtoD(" / / ")

cTitulo	:= OemToAnsi(STR0001) //"Confirmacao de Exames"
aAtendi	:= {STR0002,STR0003,STR0004} //"Total"###"Parcial"###"Nao Atendida"
cAtendi	:= SPACE(01)

aLbx          := {{.f.,"","",0,0}}
nOpcaP := 0

DEFINE MSDIALOG oDlg TITLE cTitulo From 9,0 to 40,80	of oMainWnd FONT oFont  

@ 015,008 Say OemToAnsi(STR0005) Size 60,0  PIXEL COLOR CLR_BLUE OF oDlg FONT oFont //"Nro Solicitacao"
@ 015,065 MSGet o01 var M->GBX_SOLICI F3 cF3 Picture "@!" ;
										Valid HS_Valid(1) Size  38,10 PIXEL COLOR CLR_BLACK FONT oFont OF oDlg

@ 029,008 Say OemToAnsi(STR0006) Size 60,0  PIXEL COLOR CLR_BLUE FONT oFont OF oDlg //"Nro Atendimento"
@ 029,065 MSGet o02 var M->GBX_REGATE Picture "@!" Size  038,10 PIXEL COLOR CLR_BLACK FONT oFont OF oDlg when .f.
@ 029,106 MSGet o03 var M->GBX_NOMPAC Picture "@!" Size  155,10 PIXEL COLOR CLR_BLACK FONT oFont OF oDlg when .f.

@ 043,008 Say OemToAnsi(STR0007) Size 60,0  PIXEL COLOR CLR_BLUE FONT oFont OF oDlg //"Data da Solicitacao"
@ 043,065 MSGet o04 var M->GBX_DATSOL Picture "@D"  Size  38,10 PIXEL COLOR CLR_BLACK FONT oFont OF oDlg

@ 058,008 BUTTON oBtn PROMPT STR0008 SIZE 30,10 FONT oFont OF oDlg PIXEL ACTION FS_Filtro() //"Filtrar"

@ 073,003 LISTBOX oLbx VAR cLbx FIELDS HEADER " ",;
										OemtoAnsi(STR0009),; //"Codigo"
										OemtoAnsi(STR0010),; //"Descricao"
										OemtoAnsi(STR0011);  //"Qtd Lancada"
										COLSIZES 10,29,182,29,29;
							 		SIZE 311,160 FONT oFont OF oDlg PIXEL ON DBLCLICK (nPos:=oLbx:nAt,FS_Marc(),oLbx:Refresh(),oLbx:nAt:=nPos)

oLbx:SetArray(aLbx)
oLbx:bLine:={||{if(aLbx[oLbx:nAt,1] == .f.,oNo,oTik), aLbx[oLbx:nAt,2], aLbx[oLbx:nAt,3], aLbx[oLbx:nAt,4]}}

      
ACTIVATE MSDIALOG oDlg CENTERED ON INIT (EnchoiceBar(oDlg,{|| oDlg:End(),nOpcaP := 1},{|| oDlg:End() }))

If nOpcaP == 1
	GrvHSP07()
Endif

Return
                                    
                                    
//////////////////////////
Static Function GrvHSP07()
 Local i:= 0
	Local aDesp := {}
	Local nSeqDes := ""
	Private aRotina

	aRotina	:=	{	{"", '', 0, 1},;
														{"", '', 0, 2},;
														{"", '', 0, 3},;
														{"", '', 0, 4},;
														{"", '', 0, 5} }

 DBSelectArea("GBX")
 DBSetOrder(1)
 DBSeek(xfilial("GBX")+M->GBX_SOLICI)
 cTotal := .t.	
 For i:=1 to len(aLbx)
  DbSelectArea("GBY")                      
  DbSetOrder(1)
  If DbSeek(xFilial("GBY")+M->GBX_SOLICI+aLbx[i,2])
   RecLock("GBY",.F.)
   GBY->GBY_ENTREG  := Iif(aLbx[i,1] == .T.,'1',' ')
   MsUnlock()

   If !Empty(GBY->GBY_SEQDES)
   	DbSelectArea("GAO")                      
   	DbSetOrder(5)
   	If DbSeek(xFilial("GAO") +	PadR(AllTrim(GBY->GBY_SEQDES), Len(GAO->GAO_SEQDES)) + ;
    																											PadR(AllTrim(M->GBX_REGATE  ), Len(GAO->GAO_REGATE)) + ;
    																											PadR(AllTrim(GBY->GBY_PROSOL), Len(GAO->GAO_CODPRO)))

    	RecLock("GAO",.F.)                     
     GAO->GAO_GLODES  := Iif(aLbx[i,1] == .T.,'0','1')
     GAO->GAO_DATDES  := M->GBX_DATSOL
     GAO->GAO_REGATE  := M->GBX_REGATE
     GAO->GAO_CODCCU  := M->GBX_CODCCU
    	MsUnlock()
   	Endif
			Else
				aDesp := {}
				aAdd(aDesp, {"CODPRO", aLbx[i, 2], 			.T.})
				aAdd(aDesp, {"QTDPRO", aLbx[i, 4], 			.F.})
				aAdd(aDesp, {"DATDES", M->GBX_DATSOL, .F.})
			
				DbSelectArea("GO1")
				DbSetOrder(3)
				If DbSeek(xFilial("GO1") + M->GBX_SOLICI + "1" + aLbx[i, 2])
					aAdd(aDesp, {"VALPRO", GO1->GO1_VALUNI, .T.})
					aAdd(aDesp, {"VALDES", GO1->GO1_VALDES, .F.})
				Endif		

				aAdd(aDesp, {"CODPRE", M->GBX_CODPRE, .F.})
				aAdd(aDesp, {"FLGDCI", M->GBX_FLGDCI, .F.})
				aAdd(aDesp, {"DSPBER", M->GBX_DSPBER, .F.})
				aAdd(aDesp, {"GLODES", "0", .F.})

				HS_LDManut("P", 3, 3, aDesp, .T., @nSeqDes, .T.)	

   	RecLock("GBY",.F.)
   	GBY->GBY_SEQDES := nSeqDes
   	MsUnlock()
			Endif
 
   IF aLbx[i,1] == .F.
    cTotal := .F.	
   ENDIF
  ENDIF
 Next              

 DbSelectArea("GBX")
 RecLock("GBX",.F.)
 GBX->GBX_FLGATE  := FS_VERLIST()
 GBX->GBX_LOGARQ  := HS_LogArq()
 GBX->GBX_DATSOL  := M->GBX_DATSOL
 MsUnlock()

 If cTotal .And. GAD->GAD_ATERPD == "1" // 1=Sim para Atendimento rapido
  If GAD->GAD_ATENDI $ "2" // 2=Exame
   If Empty(AllTrim(GAD->GAD_TPALTA))
    If !EMPTY(GAD->GAD_QUAINT) //  Só da alta se o leito estiver ocupado
     //No caso de atendimento rapido para Exames da alta logo após a confirmação da digitação do resultado
     While !HSAHP31(0) /// nOpcOrig == 0 para alta automatica
      // Fica no lopping ate que o usuário confirme a alta
     EndDo               
    Else
     RecLock("GAD", .F.)
     GAD->GAD_DATALT := dDataBase
     GAD->GAD_HORALT := Time()
     GAD->GAD_TPALTA := "XX" // INDICA QUE O ATENDIMENTO NAO FAZ MOVIMENTACAO DE LEITO
     MsUnlock()
    EndIf
   EndIf 
  
   // Alterado com a solicitação do Adalberto e Dra. Terezinha na ultima reunião
   // Agora o Fechamento da conta é na hora da digitação do laudo do exame	 	  
   // José Orfeu 09/09/2003
   // QUANDO EXAME FECHA CONTA AUTOMATICAMENTO
   //RecLock("GAD", .F.)
   //GAD->GAD_DATFEC := dDataBase
   //MsUnlock()                                                                    
  
   // Alterado com a solicitação do Adalberto e Dra. Terezinha na ultima reunião
   // Agora a integração com o Siga Loja ocorre na hora da solicitação do exame
   // José Orfeu 09/09/2003
   //DbSelectArea("GA9")
   //DBSetOrder(1)
   //DbSeek(xFilial("GA9") + GAD->GAD_CODCON)
   //If HS_RCfgCP(GAD->GAD_CODCON, GAD->GAD_CODPLA, "_TIPCON", GBX->GBX_DATSOL) == "1" // Somente para atendimentos particulares
   // HS_IntLoja(GAD->GAD_REGATE) // Gera integração com o SigaLoja
   //EndIf 
   DbSelectArea("GBX")
  EndIf                                          
 EndIf
Return(.T.)

/////////////////////////
Static Function HS_Valid(cVar)
              
cSavAlias := alias()

If cVar == 1 // Número da Solicitação...
   
   M->GBX_SOLICI := STRZERO(VAL(M->GBX_SOLICI),6)
   
   DBSelectArea("GBX")
   DBSetOrder(1)
   If !DBSeek(xfilial("GBX")+M->GBX_SOLICI)
      MsgStop(STR0012,STR0013) //"Número da Solicitação não encontrado !"###"Atenção"
      Return .f.
   Endif
   M->GBX_DATSOL  := GBX->GBX_DATSOL
   M->GBX_REGATE  := GBX->GBX_REGATE
   cAtendi       := IF(!EMPTY(GBX->GBX_FLGATE),GBX->GBX_FLGATE,cAtendi)

   // IF cAtendi == '0'    
   IF cAtendi == '1' 
      aAtendi       := {STR0002,STR0003,STR0004} //"Total"###"Parcial"###"Nao Atendida"
      MsgStop(STR0014,STR0013) //"Esta Solicitação Já Foi Atendida !"###"Atenção"
    ELSEIF cAtendi == 'P' 
     aAtendi       := {STR0003,STR0002,STR0004} //"Parcial"###"Total"###"Nao Atendida"
    ELSEIF cAtendi == ' ' 
     aAtendi       := {STR0004,STR0003,STR0002} //"Nao Atendida"###"Parcial"###"Total"
   ENDIF
   
   DbSelectArea("GAD")
   DBSetOrder(1)
   If !DbSeek(xFilial("GAD")+M->GBX_REGATE)
      MsgStop(STR0015,STR0013) //"Registro de Atendimento não Encontrado!"###"Atenção"
      Return .f.
   Endif
   M->GBX_NOMPAC  := GAD->GAD_NOME
Endif

Return .t.
  

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡„o    ³FS_Marc        ³ Autor ³  José Roberto    ³ Data  22/08/2002³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡„o ³ Marca no ListBox do Filtro                                 ³±±
±±³          ³                                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Static Function FS_Marc()

/*
nQtdade := 0
nOpca1  := 0
									 	 	  
DEFINE MSDIALOG oDlgx TITLE OemToAnsi("") From 9,1 to 14,55 of oMainWnd
@ 017,004 Say OemToAnsi("Quantidade") of Odlgx Pixel 
@ 017,092 MSGET oQtdade VAR nQtdade VALID FS_ValQtd() PICTURE "@!" F3 "GBJ" SIZE 43,4 OF oDlgx PIXEL COLOR CLR_BLACK
ACTIVATE MSDIALOG oDlgx CENTERED ON INIT EnchoiceBar(oDlgx,{||nOpca1 := 1,oDlgx:End()},{||nOpca1 := 0,oDlgx:End() })	
											 											 
If nOpca1 == 1                
   aLbx[oLbx:nAt,5] := nQtdade
Endif
*/	 	

If aLbx[oLbx:nAt,1] == .F.
   aLbx[oLbx:nAt,1] := .T.
  Else
   aLbx[oLbx:nAt,1] := .F.
Endif

oLbx:refresh()

Return


//////////////////////////////////////////////////////////
// Seleciona registros a partir dos parametros informados
//////////////////////////////////////////////////////////
Static Function FS_Filtro()

cSavAlias := alias()

DbSelectArea("GBX")                      
DbSetOrder(1)
If !DbSeek(xFilial("GBX")+M->GBX_SOLICI)
   MsgStop(STR0012,STR0013) //"Número da Solicitação não encontrado !"###"Atenção"
   Return .f.
Endif   

aLbx := {}
DbSelectArea("GBY")                      
DbSetOrder(1)
If DbSeek(xFilial("GBY")+M->GBX_SOLICI)
	while !eof() .and. GBY->GBY_FILIAL+GBY->GBY_SOLICI == xFilial("GBY")+M->GBX_SOLICI
	                                                            
	      DbSelectArea("GA7")
	      DbSeek(xFilial("GA7")+GBY->GBY_PROSOL)
	                     
	      aadd(aLbx,{IF(GBY->GBY_ENTREG=='1',.T.,.F.),GBY->GBY_PROSOL,GA7->GA7_DESC,GBY->GBY_QTDSOL,GBY->GBY_SEQDES,GBY->GBY_ENTREG})
	                    
	      DbSelectArea("GBY")
	      DbSkip()
	         
	Enddo
	   
	oLbx:SetArray(aLbx)
	oLbx:bLine:={||{if(aLbx[oLbx:nAt,1] == .F.,oNo,oTik),;
		          aLbx[oLbx:nAt,2],;
		          aLbx[oLbx:nAt,3],;				
		          aLbx[oLbx:nAt,4]}}
	oLbx:Refresh()
ENDIF		   
	
DbSelectArea(cSavAlias)

Return .t.



Static Function FS_VERLIST()
 LOCAL nInt
 LOCAL lTrue  := .F.
 LOCAL lFalse := .F.
 
 For nInt := 1 to Len(aLbx)
  If aLbx[nInt,1] == .T.
   lTrue := .T.
  Else
   lFalse := .T.
  EndIf
 Next          
 If lTrue .And. !lFalse
  Return ("1")
 ElseIf lTrue .And. lFalse
  Return ("0")
 ElseIf !lTrue .And. lFalse
  Return (" ") 
 EndIf
Return ("")