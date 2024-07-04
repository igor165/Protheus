#Include "PROTHEUS.CH"
#INCLUDE "OFIOM230.ch" 


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ OFIOM230 ณ Autor ณ  Fabio                ณ Data ณ 02/08/01 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescrio ณ Liberacao e Movimentacao de Veiculo entre Prisma           ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณSintaxe   ณ                                                            ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณUso       ณ                                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static aPrisma := {}

Function OFIOM230
Private cIndVSN, cChave, cCond 
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0004) //Liberacao de Prisma

FS_PCHA230( "S" )

dbSelectArea("VSN")

mBrowse( 6, 1,22,75,"VSN")          

FS_PCHA230( "N" )

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณOFIOM230L บAutor  ณFabio / Emilton     บ Data ณ  09/21/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMonta Tela                                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOM230L(cAlias, nReg, nOpc)

Local bCampo   := { |nCPO| Field(nCPO) } , nCntFor := 0
Local nIndVSN := VSN->( IndexOrd() ) , aCpoAltera := {}
Private aTELA[0][0], aGETS[0], aHeader[0]
Private aCpoEnchoice  :={}
Private lSitOsvCheck := .f. , lSitSrvCheck := .f.
Private oOk := LoadBitmap( GetResources(), "LBOK" )
Private oNo := LoadBitmap( GetResources(), "LBNO" )
Private oBranco    := LoadBitmap( GetResources(), "FOLDER9" )
Private oVerde     := LoadBitmap( GetResources(), "BR_VERDE" )
Private oVermelho  := LoadBitmap( GetResources(), "BR_VERMELHO" )
Private oAmarelo   := LoadBitmap( GetResources(), "BR_AMARELO" )
       
aRotina := {{"", "",0,1},;
             {"", "",0,2},;
             {"", "",0,3},;
             {"", "",0,4} }

aPrisma := {}
         
nOpcE := nOpc

If nOpc == 3

	nOpcE := nOpc := 4
	Inclui := .f.
	Altera := .t.

EndIf

Aadd( aPrisma , {} )
Aadd( aPrisma , {} )

aPrisma := FS_FILPRISMA( VSN->VSN_CODCOR , VSN->VSN_PRISMA )          
           
If Len( aPrisma[1] ) == 0 .And. Len( aPrisma[2] ) == 0
   
	Aviso(STR0005,STR0006,{"ok"}) //Atencao###Este PRISMA esta vazio, impossivel a transferencia de veiculos

   return .f.

EndIf

If Len( aPrisma[1] ) == 0 
                 
   Aadd( aPrisma[1] , { .f. , "" , "" , "" , "" , "" , "" } )  
     
EndIf

If Len( aPrisma[2] ) == 0 

   Aadd(aPrisma[2],{ .f. , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" , "" } )

EndIf                      

DbSelectArea("SX3")
DbSetOrder(1)
DbSeek("VSN")
While !Eof().and.(x3_arquivo=="VSN")

   If X3USO(x3_usado).and.cNivel>=x3_nivel
   
   	If nOpc == 4 .Or. !( Alltrim( x3_campo ) $ "VSN_NOVCOR/VSN_NOVPRI" )
   	
	      AADD(aCpoEnchoice,x3_campo)

		EndIf	
   
      &("M->"+x3_campo):= CriaVar(x3_campo)

   Endif

   dbSkip()

End

DbSelectArea("VSN")
For nCntFor := 1 TO FCount()
   M->&(EVAL(bCampo,nCntFor)) := FieldGet(nCntFor)
Next
         
Aadd( aCpoAltera , "VSN_NOVCOR" )
Aadd( aCpoAltera , "VSN_NOVPRI" )
                                              
DEFINE MSDIALOG oDlgLibPrisma FROM 001,000 TO 032,080 TITLE STR0004 OF oMainWnd //Liberacao de Prisma
                                
        EnChoice( cAlias, nReg, nOpcE, ,"VSN",oemtoansi(STR0004),aCpoEnchoice,{012,002,090,318},aCpoAltera,3,,,,,,.F.)  //Liberacao de Prisma

   @ 092,001 FOLDER oFolder SIZE 316,143 OF oDlgLibPrisma PROMPTS STR0007,STR0008 PIXEL //Ordem de Servico###Servicos
   // Abas do Folder
   FG_INIFOLDER("oFolder")
   
	// OS / Servicos       
	@ 001, 005 CHECKBOX oSitOsvCheck VAR lSitOsvCheck PROMPT STR0009 ; //Todos
                           OF oFolder:aDialogs[1] ;
                           ON CLICK ( FS_TICK( lSitOsvCheck ) , oSitOsv:Refresh() ) ;
                           SIZE 40,10 PIXEL 

   @ 011,003 LISTBOX oSitOsv FIELDS HEADER OemToAnsi(""),; 
                                            OemToAnsi(""),; 
                                            OemToAnsi(STR0014),;  //Nro Os 
                                            OemToAnsi(STR0010),;  //Chassi
                                            OemToAnsi(STR0011),;  //Proprietario
                                            OemToAnsi(STR0012),;  //Loja
                                            OemToAnsi(STR0013);  //Nome
   COLSIZES 10,10,40,60,40,20,60;
   SIZE 312,120 OF oFolder:aDialogs[1] ON DBLCLICK FS_TICK( !aPrisma[1][oSitOsv:nAt,1] , oSitOsv:nAt ) PIXEL

   oSitOsv:SetArray(aPrisma[1])
   oSitOsv:bLine := { || {  If( aPrisma[1][oSitOsv:nAt,1]  , oOk , oNo ) ,;
                              If( Empty( aPrisma[1][oSitOsv:nAt,2] ) , oBranco , If( aPrisma[1][oSitOsv:nAt,2] == "O" , oVerde , If( aPrisma[1][oSitOsv:nAt,2] == "P" , oAmarelo , oVermelho ) ) ) ,;
                              aPrisma[1][oSitOsv:nAt,3] ,;
                              aPrisma[1][oSitOsv:nAt,4] ,;
                              aPrisma[1][oSitOsv:nAt,5] ,;
                              aPrisma[1][oSitOsv:nAt,6] ,;
                              aPrisma[1][oSitOsv:nAt,7] }}
                
	@ 001, 005 CHECKBOX oSitSrvCheck VAR lSitSrvCheck PROMPT STR0009 ; //Todos
                           OF oFolder:aDialogs[2] ;
                           ON CLICK ( FS_TICK( lSitSrvCheck ) , oSitSrv:Refresh() ) ;
                           SIZE 40,10 PIXEL 

   @ 011,003 LISTBOX oSitSrv FIELDS HEADER OemToAnsi(""),; 
                                            OemToAnsi(""),; 
                                            OemToAnsi(STR0014),;  //Nro Os
                                            OemToAnsi(STR0010),;  //Chassi
                                            OemToAnsi(STR0011),;  //Proprietario
                                            OemToAnsi(STR0012),;  //Loja
                                            OemToAnsi(STR0013),;  //Nome
                                            OemToAnsi(STR0015),;  //Tp
                                            OemToAnsi(STR0016),;  //Grupo
                                            OemToAnsi(STR0017),;  //Cod Srv
                                            OemToAnsi(STR0018),;  //Descricao
                                            OemToAnsi(STR0019);  //Tp Srv
   COLSIZES 10,10,40,60,40,20,60,10,20,40,50,30;
   SIZE 312,120 OF oFolder:aDialogs[2] ON DBLCLICK FS_TICK( !aPrisma[2][oSitSrv:nAt,1] , oSitSrv:nAt ) PIXEL

   oSitSrv:SetArray(aPrisma[2])
   oSitSrv:bLine := { || {  If( aPrisma[2][oSitSrv:nAt,1] , oOk , oNo ) ,;
                              If( Empty( aPrisma[2][oSitOsv:nAt,2] ) , oBranco , If( aPrisma[2][oSitOsv:nAt,2] == "O" , oVerde , If( aPrisma[2][oSitOsv:nAt,2] == "P" , oAmarelo , oVermelho ) ) ) ,;
                              aPrisma[2][oSitSrv:nAt,3] ,;
                              aPrisma[2][oSitSrv:nAt,4] ,;
                              aPrisma[2][oSitSrv:nAt,5] ,;
                              aPrisma[2][oSitSrv:nAt,6] ,;
                              aPrisma[2][oSitSrv:nAt,7] ,;
                              aPrisma[2][oSitSrv:nAt,8] ,;
                              aPrisma[2][oSitSrv:nAt,9] ,;
                              aPrisma[2][oSitSrv:nAt,10] ,;
                              aPrisma[2][oSitSrv:nAt,11] ,;
                              aPrisma[2][oSitSrv:nAt,12] }}

ACTIVATE MSDIALOG oDlgLibPrisma CENTER ON INIT EnchoiceBar(oDlgLibPrisma,{|| If( FS_LIBPRISMA() , oDlgLibPrisma:End() , .F. ) },{|| oDlgLibPrisma:End() } )
                   
Return .T.

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_FILPRISบAutor  ณFabio               บ Data ณ  08/02/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณFiltra os Prisma em aberto                                  บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                    
Static Function FS_FILPRISMA( cCor , cPrisma )
                                  
DbSelectArea("VOF")
DbSetOrder(3)
DbSeek( xFilial("VOF") + cCor + cPrisma )

Do While !Eof() .And. VOF->VOF_FILIAL + VOF->VOF_CODCOR + VOF->VOF_PRISMA == xFilial("VOF") + cCor + cPrisma
     
	If !Empty( VOF->VOF_NUMOSV )           
	
	   DbSelectArea("VO1")
	   DbSetOrder(1)   
	   DbSeek( xFilial("VO1") + VOF->VOF_NUMOSV )
	   
	   Do While !Eof() .And. VO1->VO1_FILIAL+VO1->VO1_NUMOSV == xFilial("VO1")+VOF->VOF_NUMOSV
                
			// Levanta prisma por OS                                         
         If VO1->VO1_CODCOR+VO1->VO1_PRISMA == VOF->VOF_CODCOR+VOF->VOF_PRISMA
                                                  
			   DbSelectArea("VV1")
			   DbSetOrder(1)   
			   DbSeek( xFilial("VV1") + VO1->VO1_CHAINT )
	
			   DbSelectArea("SA1")
			   DbSetOrder(1)   
			   DbSeek( xFilial("SA1") + VO1->VO1_PROVEI + VO1->VO1_LOJPRO )
	
				Aadd( aPrisma[1] , { .f. , VOF->VOF_SITBOX , VO1->VO1_NUMOSV , VV1->VV1_CHASSI , VO1->VO1_PROVEI , VO1->VO1_LOJPRO , SA1->A1_NOME } )
         
			EndIf

			// Levanta prisma por Servicos
		   DbSelectArea("VO2")
		   DbSetOrder(1)   
		   DbSeek( xFilial("VO2") + VO1->VO1_NUMOSV + "S" )
		   
		   Do While !Eof() .and. VO2->VO2_FILIAL+VO2->VO2_NUMOSV+VO2->VO2_TIPREQ == xFilial("VO2") + VO1->VO1_NUMOSV + "S"

			   DbSelectArea("VO4")
			   DbSetOrder(1)   
			   DbSeek( xFilial("VO4") + VO2->VO2_NOSNUM )
			      
			   Do While !Eof() .And. VO4->VO4_FILIAL == xFilial("VO4") .And. VO4->VO4_FILIAL+VO4->VO4_NOSNUM == xFilial("VO4")+VO2->VO2_NOSNUM
			                              
			      If Empty(VO4->VO4_DATDIS) .And. VO4->VO4_CODCOR+VO4->VO4_PRISMA == VOF->VOF_CODCOR+VOF->VOF_PRISMA
			                               
					   DbSelectArea("VO6")
					   DbSetOrder(1)   
					   DbSeek( xFilial("VO6") + VO4->VO4_SERINT )
		
						// Servicos	   
			         If Len(aPrisma[2]) == 0 .Or. (Len(aPrisma[2]) != 0 .And. Ascan(aPrisma[2],{|x| x[3]+x[8]+x[9]+x[10]+x[12] == VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+VO4->VO4_GRUSER+VO4->VO4_CODSER+VO4->VO4_TIPSER }) == 0 )
		
				         Aadd(aPrisma[2],{ .f. , VOF->VOF_SITBOX , VO1->VO1_NUMOSV , VV1->VV1_CHASSI , VO1->VO1_PROVEI , VO1->VO1_LOJPRO , SA1->A1_NOME , VO4->VO4_TIPTEM , VO4->VO4_GRUSER , VO4->VO4_CODSER , VO6->VO6_DESSER , VO4->VO4_TIPSER } )
		
			         EndIf      
			         
			      EndIf
			         
			      DbSelectArea("VO4")
			      DbSkip()
			
			   EndDo                                                          
	      
		      DbSelectArea("VO2")
		      DbSkip()
			
		   EndDo                                                          

	      DbSelectArea("VO1")
	      DbSkip()
	
	   EndDo   
	   
   EndIf

	DbSelectArea("VOF")
	DbSkip()

EndDo

Return( aPrisma )
      
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_TICK   บAutor  ณFabio               บ Data ณ  08/03/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณMarca vetor                                                 บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_TICK( lFlagCheck , nLinha )
                         
Local nVet := 0 

If nLinha # NIL

	If !Empty( aPrisma[oFolder:nOption][nLinha,3] )
	      
		aPrisma[oFolder:nOption][nLinha,1] := lFlagCheck 
	
	EndIf	
   
Else

	For nVet := 1 to Len( aPrisma[oFolder:nOption] )
	
		If !Empty( aPrisma[oFolder:nOption][nVet,3] )

			aPrisma[oFolder:nOption,nVet,1]	:= lFlagCheck
	   
		EndIf
	
	Next

EndIf

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_LIBPRISบAutor  ณFabio               บ Data ณ  08/03/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณGrava Liberacao/Transferencia de Prisma                     บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_LIBPRISMA()

Local nPrisma := 0

Begin Transaction
    
	// Libera/Transf OS
	For nPrisma := 1 to Len( aPrisma[1] )
	 
		If aPrisma[1,nPrisma,1] 
	      
			// Levanta prisma por OS                                         
		   DbSelectArea("VO1")
		   DbSetOrder(1)   
		   If DbSeek( xFilial("VO1") + aPrisma[1,nPrisma,3]  )
		                   
			   FG_MARCABOX( , M->VSN_CODCOR , M->VSN_PRISMA , VO1->VO1_NUMOSV , .T. )
	      
		      RecLock("VO1" , .f.)  
		                
		      VO1->VO1_CODCOR := M->VSN_NOVCOR
		      VO1->VO1_PRISMA := M->VSN_NOVPRI
		      
		      MsUnLock()
		      
	         FG_MARCABOX(,VO1->VO1_CODCOR,VO1->VO1_PRISMA,VO1->VO1_NUMOSV)
		   
			EndIf                 
	
		EndIf
	      
	Next
	
	// Libera/Transf Servicos
	For nPrisma := 1 to Len( aPrisma[2] )
	 
		If aPrisma[2,nPrisma,1] 
	
			// Levanta prisma por OS                                         
		   DbSelectArea("VO1")
		   DbSetOrder(1)   
		   DbSeek( xFilial("VO1") + aPrisma[2,nPrisma,3]  )
	
		   FG_MARCABOX( , M->VSN_CODCOR , M->VSN_PRISMA , VO1->VO1_NUMOSV , .t. )
	
		   DbSelectArea("VO2")
		   DbSetOrder(1)   
		   DbSeek( xFilial("VO2") + VO1->VO1_NUMOSV + "S" )
		   
		   Do While !Eof() .and. VO2->VO2_FILIAL+VO2->VO2_NUMOSV+VO2->VO2_TIPREQ == xFilial("VO2") + VO1->VO1_NUMOSV + "S"
	
			   DbSelectArea("VO4")
			   DbSetOrder(1)   
			   DbSeek( xFilial("VO4") + VO2->VO2_NOSNUM )
			   
			   Do While !Eof() .and. VO4->VO4_FILIAL+VO4->VO4_NOSNUM == xFilial("VO2") + VO2->VO2_NOSNUM
		   
	            If aPrisma[2,nPrisma,3]+aPrisma[2,nPrisma,8]+aPrisma[2,nPrisma,9]+aPrisma[2,nPrisma,10]+aPrisma[2,nPrisma,12] == VO1->VO1_NUMOSV+VO4->VO4_TIPTEM+VO4->VO4_GRUSER+VO4->VO4_CODSER+VO4->VO4_TIPSER 
	
				      RecLock("VO4" , .f.)  
				                
				      VO4->VO4_CODCOR := M->VSN_NOVCOR
				      VO4->VO4_PRISMA := M->VSN_NOVPRI
				      
				      MsUnLock()
	            
	            EndIf
	
		      	DbSelectArea("VO4")
	   	   	DbSkip()
	         
	         EndDo   
	           
	      	DbSelectArea("VO2")
	      	DbSkip()
	      
			EndDo
	      
		   FG_MARCABOX( , M->VSN_NOVCOR , M->VSN_NOVPRI , VO1->VO1_NUMOSV )
	
		EndIf
	      
	Next
      
End Transaction

FS_PCHA230( "N" ) 
FS_PCHA230( "S" )                     

Return( .t. )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_NOVPRISบAutor  ณFabio               บ Data ณ  08/06/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณValida novo Prisma                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/                    
Function FS_NOVPRISMA()
            
Local cSele := Alias() , aArea := {} , lRet := .f.

aArea := sGetArea(aArea , Alias())
aArea := sGetArea(aArea , "VSN")
aArea := sGetArea(aArea , "VOF")

DbSelectArea("VSN")
DbSetOrder(1)
DbSeek( xFilial("VSN") + M->VSN_NOVCOR + M->VSN_NOVPRI )

DbSelectArea("VOF")
DbSetOrder(3)
DbSeek( xFilial("VOF") + VSN->VSN_CODCOR + VSN->VSN_PRISMA )
            
If VOF->VOF_SITBOX == "D"

	lRet := .t.
	
EndIf   

sRestArea(aArea)
DbSelectArea(cSele)

Return( lRet )

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_DESSEC บAutor  ณFabio / Emilton     บ Data ณ  09/21/00   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function FS_FILBROWSEP(cParam,cCorPrisma,lMensagem)
           
Local lRet := .f. 

If lMensagem == Nil
   lMensagem := .f.
EndIf

dbSelectArea("VOF")
dbSetOrder(3)
dbSeek(xFilial("VOF")+cCorPrisma)

While cCorPrisma == VOF_CODCOR+VOF_PRISMA .And. VOF->VOF_FILIAL == xFilial("VOF") .And. !Eof()  

	If empty(VOF_SITBOX)
	   VOF->(dbSkip())
	   Loop
	EndIf                 
	If cParam == "O"
       If VOF_SITBOX != "D"
	      lRet := .t.
       EndIf
    Else
      If VOF_SITBOX == "D"
         lRet := .t.
      Else
         lRet := .f.
         If lMensagem
            Help("  ",1,"M190BOXOCU")
         EndIf         
      EndIf
    EndIf
    VOF->(dbSkip())
EndDo

dbSelectArea("VSN")
return lRet

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณFS_PCHA230บAutor  ณMicrosiga           บ Data ณ  04/20/01   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณRefresh na mBrowse                                          บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Oficina                                                    บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function FS_PCHA230(cFiltra)

dbSelectArea("VSN")

If cFiltra == "S"

	cIndVSN := CriaTrab(Nil, .F.)
	cChave  := IndexKey()
	cCond   := "FS_FILBROWSEP('O',VSN->VSN_CODCOR+VSN->VSN_PRISMA)"        // Box Ocupado
	
	IndRegua("VSN",cIndVSN,cChave,,cCond,OemToAnsi(STR0020) ) //Selecionando Registros...
	
	DbSelectArea("VSN")
	nIndVSN := RetIndex("VSN")
	#IFNDEF TOP
	   dbSetIndex(cIndVSN+ordBagExt())
	#ENDIF
	dbSetOrder(nIndVSN+1)
	
Else
	
	RetIndex()
	
	#IFNDEF TOP
	   If File(cIndVSN+OrdBagExt())
	      fErase(cIndVSN+OrdBagExt())
	   Endif
	#ENDIF

EndIf

Return

/*
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFun…o    ณOFIOM23LE  ณ Autor ณ Alexandre            ณ Data ณ 22/11/04 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescri…o ณ Cria uma janela contendo a legenda da mBrowse              ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณ Uso      ณOFIOM23LE                                                   ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIOM23LE()
Local aLegenda :=       {{'BR_VERDE'  ,STR0022},;	//'Servico em andamento'
                        {'BR_VERMELHO',STR0023},; 		//'Servico com tempo estourado'
                        {'BR_AMARELO' ,STR0024}}		//'Servico parado'
BrwLegenda(cCadastro, STR0021 ,aLegenda) //Legenda

Return .T.

Static Function MenuDef()
Local aRotina := {{STR0001, "AxPesqui",0,1},; //"Pesquisar"
                 {STR0002, "OFIOM230L",0,2},; //"Liberar"
                 {STR0003, "OFIOM230L",0,3},; //"Transferir"
                 {STR0021, "OFIOM23LE",0,4,0,.f.}} //"Legenda"
Return aRotina
