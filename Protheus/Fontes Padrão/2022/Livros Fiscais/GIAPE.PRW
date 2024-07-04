/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GIAPE     ºAutor  ³Microsiga           º Data ³  04/12/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Funcao para processamento do livro fiscal de ICMS das movi- º±±
±±º          ³ mentações interestaduais, para armazenar as informacoes em º±±
±±º          ³ um arquivo trabalho para posteriores leituras no .INI      º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ AP                                                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
Function GIAPE ()
Local	cDbf		:=	"F3_FILIAL='"+cFilAnt+"' .AND. DToS (F3_ENTRADA)>='"+DToS (MV_PAR01)+"' .AND. DToS (F3_ENTRADA)<='"+DToS (MV_PAR02)+"' .AND. (Substr(F3_CFO,1,1)=='2' .OR. Substr(F3_CFO,1,1)=='6') .AND. F3_TIPO <>'S' .And. Empty(F3_DTCANC) .And. Empty(F3_OBSERV)"
Local	cTop		:=	"F3_FILIAL='"+cFilAnt+"' AND F3_ENTRADA>='"+DToS (MV_PAR01)+"' AND F3_ENTRADA<='"+DToS (MV_PAR02)+"' AND (Substring(F3_CFO,1,1)='2' OR Substring(F3_CFO,1,1)='6') AND F3_TIPO <>'S' And F3_DTCANC=''"// And F3_OBSERV=''"
Local	aSF3		:=	{"SF3", ""}      
Local   cContrib    := ""                                                                           
 
//ÚÄÄÄÄÄÄÄÄÄÄÄ¿       	
//³Arquivo TXT³
//ÀÄÄÄÄÄÄÄÄÄÄÄÙ 
aCampos	:=	{}
AADD(aCampos,{"UF"			,"C"	,002,0})
AADD(aCampos,{"VCONTABIL"	,"N"	,011,0})
AADD(aCampos,{"VBASE"		,"N"	,011,0})
AADD(aCampos,{"OUTRASOP"	,"N"	,011,0})
AADD(aCampos,{"OUTROSPROD"	,"N"	,011,0})

cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"TBE")
IndRegua("TBE",cAls,"UF") 

aCampos	:=	{}
AADD(aCampos,{"UF"			,"C"	,002,0})
AADD(aCampos,{"VCONTNCONT"	,"N"	,011,0})
AADD(aCampos,{"VCONTCONT"	,"N"	,011,0})
AADD(aCampos,{"VBASENCONT"	,"N"	,011,0})
AADD(aCampos,{"VBASECONT"	,"N"	,011,0})
AADD(aCampos,{"OUTRASOP"	,"N"	,011,0})
AADD(aCampos,{"SUBSTTRIB"	,"N"	,011,0})

cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"TBS")
IndRegua("TBS",cAls,"UF") 


aCampos	:=	{}
AADD(aCampos,{"CFOP"	    ,"C"	,001,0})
AADD(aCampos,{"VCONTABIL"	,"N"	,011,0})
AADD(aCampos,{"VBASE"		,"N"	,011,0})
AADD(aCampos,{"OUTRASOP"	,"N"	,011,0})
AADD(aCampos,{"OUTROSPROD"	,"N"	,011,0})
AADD(aCampos,{"VCONTNCONT"	,"N"	,011,0})
AADD(aCampos,{"VCONTCONT"	,"N"	,011,0})
AADD(aCampos,{"VBASENCONT"	,"N"	,011,0})
AADD(aCampos,{"VBASECONT"	,"N"	,011,0})
AADD(aCampos,{"OUTRAS"	,"N"	,011,0})
AADD(aCampos,{"SUBSTTRIB"	,"N"	,011,0})

cAls	:=	CriaTrab(aCampos)
dbUseArea(.T.,__LocalDriver,cAls,"TBT")
IndRegua("TBT",cAls,"CFOP") 

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Processamento para alimentar os TRBs criados acima³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
DbSelectArea ("SF3")
SF3->(DbSetOrder (1))
FsQuery (aSF3, 1, cTop, cDbf, SF3->(IndexKey ()))

	SF3->(DbGoTop ())
	Do While !SF3->(Eof ()) 
		If !TBT->(DbSeek (Substr(SF3->F3_CFO,1,1))) 
			RecLock ("TBT", .T.)              
			TBT->CFOP		 := Substr(SF3->F3_CFO,1,1)
			TBT->VCONTABIL	 := Iif(Substr(SF3->F3_CFO,1,1)$"2",SF3->F3_VALCONT,0)
			TBT->VBASE		 := Iif(Substr(SF3->F3_CFO,1,1)$"2",SF3->F3_BASEICM,0)
			TBT->OUTRASOP    := Iif(Substr(SF3->F3_CFO,1,1)$"2",SF3->F3_OUTRICM+SF3->F3_ISENICM,0)
			TBT->OUTROSPROD  := Iif(Substr(SF3->F3_CFO,1,1)$"2",SF3->F3_ICMSRET,0)
			TBT->VCONTNCONT  := Iif(Substr(SF3->F3_CFO,1,1)$"6",IIF(Empty(Iif(SF3->F3_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)),SF3->F3_VALCONT,0),0)
			TBT->VCONTCONT   := Iif(Substr(SF3->F3_CFO,1,1)$"6",IIF(!Empty(Iif(SF3->F3_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)),SF3->F3_VALCONT,0),0)
			TBT->VBASENCONT  := Iif(Substr(SF3->F3_CFO,1,1)$"6",IIF(Empty(Iif(SF3->F3_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)),SF3->F3_BASEICM,0),0)					
			TBT->VBASECONT	 := Iif(Substr(SF3->F3_CFO,1,1)$"6",IIF(!Empty(Iif(SF3->F3_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)),SF3->F3_BASEICM,0),0)
			TBT->OUTRAS      := Iif(Substr(SF3->F3_CFO,1,1)$"6",SF3->F3_OUTRICM+SF3->F3_ISENICM,0)
			TBT->SUBSTTRIB   := Iif(Substr(SF3->F3_CFO,1,1)$"6",SF3->F3_ICMSRET,0)
		Else
			RecLock ("TBT", .F.)              
			TBT->VCONTABIL	 += Iif(Substr(SF3->F3_CFO,1,1)$"2",SF3->F3_VALCONT,0)
			TBT->VBASE		 += Iif(Substr(SF3->F3_CFO,1,1)$"2",SF3->F3_BASEICM,0)
			TBT->OUTRASOP    += Iif(Substr(SF3->F3_CFO,1,1)$"2",SF3->F3_OUTRICM+SF3->F3_ISENICM,0)
			TBT->OUTROSPROD  += Iif(Substr(SF3->F3_CFO,1,1)$"2",SF3->F3_ICMSRET,0)
			TBT->VCONTNCONT  += Iif(Substr(SF3->F3_CFO,1,1)$"6",IIF(Empty(Iif(SF3->F3_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)),SF3->F3_VALCONT,0),0)
			TBT->VCONTCONT   += Iif(Substr(SF3->F3_CFO,1,1)$"6",IIF(!Empty(Iif(SF3->F3_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)),SF3->F3_VALCONT,0),0)
			TBT->VBASENCONT  += Iif(Substr(SF3->F3_CFO,1,1)$"6",IIF(Empty(Iif(SF3->F3_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)),SF3->F3_BASEICM,0),0)					
			TBT->VBASECONT	 += Iif(Substr(SF3->F3_CFO,1,1)$"6",IIF(!Empty(Iif(SF3->F3_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)),SF3->F3_BASEICM,0),0)
			TBT->OUTRAS      += Iif(Substr(SF3->F3_CFO,1,1)$"6",SF3->F3_OUTRICM+SF3->F3_ISENICM,0)
			TBT->SUBSTTRIB   += Iif(Substr(SF3->F3_CFO,1,1)$"6",SF3->F3_ICMSRET,0) 
			MsUnLock()
		EndIf 

		If Substr(SF3->F3_CFO,1,1)$"2"                         
			If !TBE->(DbSeek (SF3->F3_ESTADO)) 
				RecLock ("TBE", .T.)
				TBE->UF  		 := SF3->F3_ESTADO			
				TBE->VCONTABIL	 := SF3->F3_VALCONT
				TBE->VBASE		 := SF3->F3_BASEICM						
				TBE->OUTRASOP   := SF3->F3_OUTRICM+SF3->F3_ISENICM
				TBE->OUTROSPROD := SF3->F3_ICMSRET												
			Else
				RecLock ("TBE", .F.)
				TBE->VCONTABIL	 += SF3->F3_VALCONT
				TBE->VBASE		 += SF3->F3_BASEICM						
				TBE->OUTRASOP   += SF3->F3_OUTRICM+SF3->F3_ISENICM
				TBE->OUTROSPROD += SF3->F3_ICMSRET																											    	
		EndIf
		MsUnLock()		                                                                                                                        
		
	Else
		DbSelectArea ("SA1")
		DbSelectArea ("SA2")
		SA1->(DbSetOrder (1))
		SA2->(DbSetOrder (1))
		If SF3->F3_TIPO$"DB"
			SA2->(DbSeek (xFilial ("SA2")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
		Else                                                              
			SA1->(DbSeek (xFilial ("SA1")+SF3->F3_CLIEFOR+SF3->F3_LOJA))
		Endif
		If ((ALLTRIM(SF3->F3_CFO)$"618/619/545/645/553/653/751/563/663") .Or. (ALLTRIM(SF3->F3_CFO)$"6107/6108/5258/6258/5307/6307/5357/6357").Or. Empty(Iif(SF3->F3_TIPO$"DB",SA2->A2_INSCR,SA1->A1_INSCR)))
	        cContrib := "NC"
		Else          
		    cContrib :=	"CO"
		EndIf
		    
		If !TBS->(DbSeek (SF3->F3_ESTADO)) 
			RecLock ("TBS", .T.)
			TBS->UF  		 := SF3->F3_ESTADO
			TBS->VCONTNCONT := IIF(cContrib ==	"NC",SF3->F3_VALCONT,0)
			TBS->VCONTCONT  := IIF(cContrib ==	"CO",SF3->F3_VALCONT,0)
			TBS->VBASENCONT := IIF(cContrib ==	"NC",SF3->F3_BASEICM,0)					
			TBS->VBASECONT	:= IIF(cContrib ==	"CO",SF3->F3_BASEICM,0)
			TBS->OUTRASOP   := SF3->F3_OUTRICM+SF3->F3_ISENICM
			TBS->SUBSTTRIB  := SF3->F3_ICMSRET												
		Else              
			RecLock ("TBS", .F.)
			TBS->VCONTNCONT += IIF(cContrib == "NC" ,SF3->F3_VALCONT,0)
			TBS->VCONTCONT  += IIF(cContrib ==	"CO" ,SF3->F3_VALCONT,0)
			TBS->VBASENCONT += IIF(cContrib ==	"NC" ,SF3->F3_BASEICM,0)					
			TBS->VBASECONT	+= IIF(cContrib ==	"CO" ,SF3->F3_BASEICM,0)
			TBS->OUTRASOP   += SF3->F3_OUTRICM+SF3->F3_ISENICM
			TBS->SUBSTTRIB  += SF3->F3_ICMSRET																							
		EndIf	
		MsUnLock()			                 
	EndIf                        
    SF3->(DbSkip ())
EndDo
FsQuery (aSF3, 2)

Return 