#Include "OFIIA300.CH"
#Include "Protheus.ch"
#Include "Fileio.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑฺฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤยฤฤฤฤฤฤยฤฤฤฤฤฤฤฤฤฤฟฑฑ
ฑฑณFuno    ณ OFIIA300 ณ Autor ณ Manoel Filho          ณ Data ณ 12/06/03 ณฑฑ
ฑฑรฤฤฤฤฤฤฤฤฤฤลฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤดฑฑ
ฑฑณDescriao ณ Gera arquivo intermediario de informacoes de faturamento deณฑฑ
ฑฑณ          ณ Veiculos SCANIA                                            ณฑฑ
ฑฑภฤฤฤฤฤฤฤฤฤฤมฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤูฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function OFIIA300(cCodMar,dDataIni,dDataFin)
                              
Private lA1_IBGE := If(SA1->(FieldPos("A1_IBGE"))>0,.t.,.f.)

DbSelectArea("SX3")
dbSeek("VIN")

aCampos := {}

While !eof() .and. x3_arquivo == "VIN"
   If X3USO(x3_usado).and.cNivel>=x3_nivel
      aadd(aCampos,x3_campo)
   EndIf
      
   dbskip()
   
Enddo
                              
Private aRotina := MenuDef()
Private cCadastro := OemToAnsi(STR0001)
Private cPerg:="OIA300"
Private lAuto := .f.

If lAuto
     
	DbSelectArea("VIN")

	Processa( {|| IA300IMP() } )

Else

	aCores := {{'VIN->VIN_TIPMOV == "NF"','BR_VERDE'},;
               {'VIN->VIN_TIPMOV == "XF"','BR_VERMELHO'},;
               {'VIN->VIN_TIPMOV == "DV"','BR_AMARELO'},;
               {'VIN->VIN_TIPMOV == "CF"','BR_AZUL'}}

	mBrowse( 6, 1,22,75,"VIN",,,,,,aCores)

EndIf


Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIA300IMP  บAutor  ณManoel Filho        บ Data ณ  12/06/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP5                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function IA300IMP()


// INICIO 

If lAuto 

	Pergunte("OIA300", .F. )

Else

	If !Pergunte("OIA300", .T. ) 
	   Return
	EndIf

EndIf

DbSelectArea("VV0")
DbSetOrder(2)
DbSeek( xFilial("VV0") + "0" + Dtos(Mv_par01),.t. )
                    
ProcRegua( reccount() ) 
        
Begin Transaction

   Do While !Eof() .And. VV0->VV0_FILIAL == xFilial("VV0") ;
				   .And. VV0->VV0_DATMOV >= Mv_Par01 .and. VV0->VV0_DATMOV <= Mv_Par02


	  If  !(VV0->VV0_OPEMOV) $ "04"
	  	  DbSkip()
	  	  Loop
	  Else	 
		  If VV0->VV0_OPEMOV == "0"
			 If VV0->VV0_EXPVEI == "1"
			    DbSkip()
			    Loop
			 Endif
		  Endif
	  Endif
		
      If  VV0->VV0_SITNFI=="1" .and. VV0->VV0_TIPFAT=="0" .and. !Empty(VV0->VV0_NUMNFI) 
      
	      DbSelectArea("VVA")                     //ITENS DA SAIDA
          DbSeek(xFilial("VVA")+VV0->VV0_NUMTRA)

	      DbSelectArea("VIN")
		  DbSeek( xFilial("VIN")+Dtos(VV0->VV0_DATMOV)+VVA->VVA_CHASSI )
				
	      DbSelectArea("SA1")
	      DbSeek(xFilial("SA1")+VV0->VV0_CODCLI+VV0->VV0_LOJA)
	
	      DbSelectArea("SA3")
          DbSeek(xFilial("SA3")+VV0->VV0_CODVEN)

			If lA1_IBGE
				VAM->(DbSetOrder(1))	
				VAM->(Dbseek(xFilial("VAM")+SA1->A1_IBGE))
      	EndIf
      	
	      DbSelectArea("VIN")
	
	      If !RecLock("VIN", !Found() )
	         Help("  ",1,"REGNLOCK")
	         lRet := .f.
	         DisarmTransaction()
	         Break               
	      EndIf      
	      
          // Agente Financeiro devera estar cadastrado no SA1 (Clientes)
		  cAgeFin := VV0->VV0_CLIALI+VV0->VV0_LOJALI	   
		  
		  If  VV0->VV0_OPEMOV == "0" // Faturamento
		      VIN->VIN_FILIAL := xFilial("VIN")
		      VIN->VIN_TIPMOV := If(VV0->VV0_OPEMOV=="0","NF","DV")  // Ver Tab01   A   2
		      VIN->VIN_CHASSI := VVA->VVA_CHASSI //								    AN   25
		      VIN->VIN_NUMNFI := VV0->VV0_NUMNFI // 								 C   6
		      VIN->VIN_SERNFI := VV0->VV0_SERNFI //									 C   4
		      VIN->VIN_DATMOV := VV0->VV0_DATMOV //	            				  	 A   8
		      VIN->VIN_ALIENA := If(VV0->VV0_TIPVEN=="SR","NA","AL") // AL-C/Reserva - NA-S/Reserva    A   2
		      VIN->VIN_VLRTOT := VVA->VVA_VALVDA // Valor Total Nota      			 N	 13
		      VIN->VIN_VLRICM := VVA->VVA_ICMVEN // Valor ICMS          			 N	 13
		      VIN->VIN_VLRCOF := VVA->VVA_COFVEN // Valor COFINS        			 N	 13
		      VIN->VIN_VLRPIS := VVA->VVA_PISVEN // Valor PIS           			 N	 13
		      VIN->VIN_VLRMER := 0				  // Valor de Mercadorias			 N	 13
		      VIN->VIN_DOCVEN := SA3->A3_CGC     // Cpf Vendedor         			 C	 14
		      VIN->VIN_PERCLI := "CL"            // CL-Cliente/AF-Agente Financ      A   2
		      VIN->VIN_NOME   := SA1->A1_NOME
		      VIN->VIN_TIPPES := If(Len(Alltrim(SA1->A1_CGC))>12,"J","F")// F-Fisica / J-Juridica          A   1
		      VIN->VIN_ENDERE := SA1->A1_END
		      VIN->VIN_COMPLM := SA1->A1_BAIRRO
				If lA1_IBGE
			      VIN->VIN_CODMUN := StrZero(VAM->VAM_IBGE,11)		 // Tabela IBGE			     C   11
			 	EndIf
		      VIN->VIN_ESTADO := VV0->VV0_ESTCLI
		      VIN->VIN_CEPCLI := SA1->A1_CEP
		      VIN->VIN_FONCOM := Val(Right(Alltrim(SA1->A1_TEL),8))
		      VIN->VIN_FAXCOM := Val(Right(Alltrim(SA1->A1_FAX),8))
		      VIN->VIN_EMAIL  := SA1->A1_EMAIL
		      VIN->VIN_INSEST := SA1->A1_INSCR   //									AN   20
		      VIN->VIN_INSMUN := SA1->A1_INSCRM  //									AN   20
		      VIN->VIN_INSSUF := SA1->A1_SUFRAMA // 								AN   20
		      VIN->VIN_DTVLSU := Ctod("") // Data Validade SUFRAMA		 			AN   8
		      VIN->VIN_DNCONC := FS_CONCES()	    // 			     				 N   5
		      VIN->VIN_AGEFIN := cAgeFin		    //								 C   8
	
		  Else  //VV0->VV0_OPEMOV == "4" // Devolucao       
		  
		      VIN->VIN_FILIAL := xFilial("VIN")
		      VIN->VIN_TIPMOV := If(VV0->VV0_OPEMOV=="0","NF","DV")  // Ver Tab01   A   2
		      VIN->VIN_CHASSI := VVA->VVA_CHASSI //								    AN   25
		      VIN->VIN_NUMNFI := VV0->VV0_NUMNFI // 								 C   6
		      VIN->VIN_SERNFI := VV0->VV0_SERNFI //									 C   4
		      VIN->VIN_DATMOV := VV0->VV0_DATMOV //	            				  	 A   8
		      VIN->VIN_ALIENA := If(VV0->VV0_TIPVEN=="SR","NA","AL") // AL-C/Reserva - NA-S/Reserva    A   2
		      VIN->VIN_VLRTOT := VVA->VVA_VALVDA // Valor Total Nota      			 N	 13
		      VIN->VIN_VLRICM := VVA->VVA_ICMVEN // Valor ICMS          			 N	 13
		      VIN->VIN_VLRCOF := VVA->VVA_COFVEN // Valor COFINS        			 N	 13
		      VIN->VIN_VLRPIS := VVA->VVA_PISVEN // Valor PIS           			 N	 13
		      VIN->VIN_VLRMER := 0				  // Valor de Mercadorias			 N	 13
		      VIN->VIN_DOCVEN := SA3->A3_CGC     // Cpf Vendedor         			 C	 14
		      VIN->VIN_PERCLI := "CL"            // CL-Cliente/AF-Agente Financ      A   2
		      VIN->VIN_NOME   := SA1->A1_NOME
		      VIN->VIN_TIPPES := If(Len(Alltrim(SA1->A1_CGC))>12,"J","F")// F-Fisica / J-Juridica          A   1
		      VIN->VIN_ENDERE := SA1->A1_END
		      VIN->VIN_COMPLM := SA1->A1_BAIRRO
				If lA1_IBGE
			      VIN->VIN_CODMUN := VAM->VAM_IBGE		 // Tabela IBGE			     C   11
			 	EndIf
		      VIN->VIN_ESTADO := VV0->VV0_ESTCLI
		      VIN->VIN_CEPCLI := SA1->A1_CEP
		      VIN->VIN_FONCOM := Val(Right(Alltrim(SA1->A1_TEL),8))
		      VIN->VIN_FAXCOM := Val(Right(Alltrim(SA1->A1_FAX),8))
		      VIN->VIN_EMAIL  := SA1->A1_EMAIL
		      VIN->VIN_INSEST := SA1->A1_INSCR   //									AN   20
		      VIN->VIN_INSMUN := SA1->A1_INSCRM  //									AN   20
		      VIN->VIN_INSSUF := SA1->A1_SUFRAMA // 								AN   20
		      VIN->VIN_DTVLSU := Ctod("") // Data Validade SUFRAMA		 			AN   8
		      VIN->VIN_DNCONC := FS_CONCES()	    // 			     				 N   5
		      VIN->VIN_AGEFIN := cAgeFin		    //								 C   8
		  Endif		  
	      MsUnlock()

	      DbSelectArea("VV0")
	      If !RecLock("VV0",.F.)
	         Help("  ",1,"REGNLOCK")
	         lRet := .f.
	         DisarmTransaction()
	         Break               
	      EndIf
	   
	      VV0->VV0_EXPVEI := "1"
	      MsUnlock()

      EndIf

      IncProc()   
      
   	  DbSelectArea("VV0")
      DbSkip()

   EndDo

End Transaction

Return


//////////////////////////////////////
// Retorna o Codigo do Concessionario
// junto a SCANIA
Static Function FS_CONCES()

If VIN->VIN_FILIAL == "01" 
   Return(93)
ElseIf VIN->VIN_FILIAL == "04" 
   Return(210)
ElseIf VIN->VIN_FILIAL == "05" 
   Return(211)      
ElseIf VIN->VIN_FILIAL == "06" 
   Return(221)      
Endif   


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIA300V    บAutor  ณManoel Filho        บ Data ณ  16/06/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Visualiza dados do Faturamento                             บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculos                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function IA300V(cAlias,nReg,nOpc)

DbSelectArea("VIN")

AxVisual(cAlias,nReg,nOpc,aCampos)

Return


/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณIA300V    บAutor  ณManoel Filho        บ Data ณ  16/06/03   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Altera dados do Faturamento                                บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Veiculos                                                   บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Function IA300A(cAlias,nReg,nOpc)


DbSelectArea("VIN")

AxAltera(cAlias,nReg,nOpc,aCampos)

Return


//////////////////////
Function FS_Legenda()

Local aLegenda := {}

alegenda := {{'BR_VERDE'  ,STR0008},;
             {'BR_VERMELHO',STR0009},;
             {'BR_AMARELO' ,STR0010},;
             {'BR_AZUL'    ,STR0011}}

BrwLegenda(STR0007,STR0006,aLegenda)

Return

Static Function MenuDef()
Local aRotina := { { STR0002  ,"axPesqui", 0 , 1},;
                      { STR0003 ,"IA300V",0 , 2},;
                      { STR0004 ,"Processa( {|| IA300IMP() } )",0 , 3},;
                      { STR0005 ,"IA300A",0 , 4},;
                      { STR0006 ,"FS_Legenda",0 , 0, 2,.f.}}
Return aRotina
