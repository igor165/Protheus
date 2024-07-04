#Include "PROTHEUS.CH"
/*/
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Programa  ³DCIPSC    ³ Autor ³Cleber Stenio Alves    ³ Data ³19.11.2008³±±                                                 
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡…o ³Preparacao do meio-magnetico para a DCIP - SC               ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Retorno   ³Array tabela temporária para preenchimento do DCIPSC.ini    ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³Nenhum                                                      ³±±
±±³          ³                                                            ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³   DATA   ³ Programador   ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³          ³               ³                                            ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
/*/
Function DCIPSC ()
	Local   nI          := 0
	Local	aTrb		:= {}
	Local	cTrb		:= ""
	Local	aApICMMe	:= {} 
	Local	aApST	    := {}
	Local   aTMP        := {}
	//
	aAdd (aTrb, {"TRB_TIPREG"   ,	"C",	03,	0})
	aAdd (aTrb, {"TRB_TIPCRE"   ,	"C",	03,	0})
	aAdd (aTrb, {"TRB_VALCRE"   ,	"N",	17,	2})
	aAdd (aTrb, {"TRB_NUMSAT"   ,	"C",	15,	0})
	//
	cTrb	:=	CriaTrab (aTrb)
	DbUseArea (.T., __LocalDriver, cTrb, "TRB")
	IndRegua ("TRB", cTrb, "TRB_TIPREG+TRB_TIPCRE+TRB_NUMSAT")
	
	AADD(aTMP,{cTrb,"TRB"})
	
	//Leitura da Apuracao                          
	aApICMMe := FisApur ("IC", Year (MV_PAR02), Month (MV_PAR02), 2, 0, "*", .F., {}, 1, .F., "")    
	
	aApST	 :=	FisApur ("ST", Year (MV_PAR02), Month (MV_PAR02), 2, 0, "*", .F., {}, 1, .F., "")    
	
	For nI := 1 To Len (aApICMMe) 
	
	    If "006"$aApICMMe[nI][4] .And. aApICMMe[nI][3]>0
             //Montagem Reg 040
	    	If Substr(aApICMMe[nI][2],1,3)=="040" 
	    		//
	    		If !(TRB->(DbSeek("040"+Substr(aApICMMe[nI][2],4,3)+Substr(aApICMMe[nI][2],7,15))))
					//
					RecLock ("TRB", .T.)
						TRB->TRB_TIPREG  :=	"040"
						TRB->TRB_TIPCRE  :=	Substr(aApICMMe[nI][2],4,3)
						TRB->TRB_VALCRE  :=	aApICMMe[nI][3]
						TRB->TRB_NUMSAT  :=	Substr(aApICMMe[nI][2],7,15)
					MsUnLock ()	
				EndIf
			EndIf
            //Montagem Reg 060			
			If Substr(aApICMMe[nI][2],1,3)=="060" 
	    		//
	    		If !(TRB->(DbSeek("060"+Substr(aApICMMe[nI][2],4,3)+Substr(aApICMMe[nI][2],7,15))))
					//
					RecLock ("TRB", .T.)
						TRB->TRB_TIPREG  :=	"060"
						TRB->TRB_TIPCRE  :=	Substr(aApICMMe[nI][2],4,3)
						TRB->TRB_VALCRE  :=	aApICMMe[nI][3]
						TRB->TRB_NUMSAT  :=	Substr(aApICMMe[nI][2],7,15)
					MsUnLock ()	
				EndIf
			EndIf
            //Montagem Reg 100
			If Substr(aApICMMe[nI][2],1,3)=="100"
	    		//
	    		If !(TRB->(DbSeek("100"+Substr(aApICMMe[nI][2],4,3)+Substr(aApICMMe[nI][2],7,15))))
					//
					RecLock ("TRB", .T.)
						TRB->TRB_TIPREG  :=	"100"
						TRB->TRB_TIPCRE  :=	Substr(aApICMMe[nI][2],4,3)
						TRB->TRB_VALCRE  :=	aApICMMe[nI][3]
						TRB->TRB_NUMSAT  :=	Substr(aApICMMe[nI][2],7,15)
					MsUnLock ()	
				EndIf
			EndIf			
		ElseIf "007"$aApICMMe[nI][4] .And. aApICMMe[nI][3]>0
		//Montagem Reg 080
			If Substr(aApICMMe[nI][2],1,3)=="080"
	    		//
	    		If !(TRB->(DbSeek("080"+Substr(aApICMMe[nI][2],4,3)+Substr(aApICMMe[nI][2],7,15))))
					//
					RecLock ("TRB", .T.)
						TRB->TRB_TIPREG  :=	"080"
						TRB->TRB_TIPCRE  :=	Substr(aApICMMe[nI][2],4,3)
						TRB->TRB_VALCRE  :=	aApICMMe[nI][3]
						TRB->TRB_NUMSAT  :=	Substr(aApICMMe[nI][2],7,15)
					MsUnLock ()	
				EndIf
			EndIf
		EndIf
	Next
	
	
	For nI := 1 To Len (aApST)   
		If Substr(aApST[nI][1],1,3)=="007" .And. Substr(aApST[nI][4],1,6) <> "007.00"
		   	If !(TRB->(DbSeek("140"+Substr(aApST[nI][2],4,3)+Substr(aApST[nI][2],7,15))))
		  				RecLock ("TRB", .T.)
						TRB->TRB_TIPREG  :=	"140"
						TRB->TRB_TIPCRE  :=	Substr(aApST[nI][2],4,3)
						TRB->TRB_VALCRE  :=	aApST[nI][3]
						TRB->TRB_NUMSAT  :=	Substr(aApST[nI][2],7,15)
				   		MsUnLock ()	
		  	EndIf
		EndIf
	Next
	

Return(aTMP)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³DCIPDelSC   ºAutor  ³Cleber Stenio Alves º Data ³ 19.11.2008  º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Deleta os arquivos temporarios processados                    º±±
±±º          ³                                                              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³DCIPSC                                                        º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/         
Function DCIPDelSC(aDelArqs)
	Local aAreaDel := GetArea()
	Local nI := 0
	
	For nI:= 1 To Len(aDelArqs)
		If File(aDelArqs[nI,1]+GetDBExtension())
			dbSelectArea(aDelArqs[ni,2])
			dbCloseArea()
			Ferase(aDelArqs[nI,1]+GetDBExtension())
			Ferase(aDelArqs[nI,1]+OrdBagExt())
		Endif	
	Next
	
	RestArea(aAreaDel)
	
Return	

//-------------------------------------------------------------------
/*/{Protheus.doc} DCIPSC
Rotina para verificar se o campo D1_DCIPSC esta preenchido em algum item

@author Rene Julian
@since 07/10/2015
@version P11

/*/
//-------------------------------------------------------------------

Function DCIPSCMV()
Local cRetorno	:= ""
Local cChave	:= ""
Local cCampo   := SuperGetMv("MV_DCIPSC",,"")

If SD1->(DbSeek (xFilial ("SD1")+SF3->F3_NFISCAL+SF3->F3_SERIE+SF3->F3_CLIEFOR+SF3->F3_LOJA))
	cChave := SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA
	While cChave == SD1->D1_DOC + SD1->D1_SERIE + SD1->D1_FORNECE + SD1->D1_LOJA
		If SD1->(FieldPos(cCampo)) > 0
			If !Empty (&("SD1->"+cCampo))
				cRetorno := &("SD1->"+cCampo)
				Exit
			EndIf
		EndIf
		SD1->(DbSkip())
	EndDo
EndIf

Return cRetorno
