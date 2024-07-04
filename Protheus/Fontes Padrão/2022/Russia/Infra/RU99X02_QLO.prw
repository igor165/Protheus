#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWBROWSE.CH"
#INCLUDE "FWMVCDEF.CH"
#INCLUDE "RU99X02_QL.CH"

//In this source it is planned to place all the  that will be involved in the "query engine".
#DEFINE FIELDNAME_POS 1
#DEFINE TYPE_POS 2
#DEFINE SIZE_POS 3
#DEFINE DECIMAL_POS 4
#DEFINE TEXT_POS 5

#DEFINE FIELD_ORD 1
#DEFINE ORDER_ORD 2

#DEFINE FOR_QUERY 1
#DEFINE FOR_TOTAL 2

/*
#DEFINE STR0001		"Total"
#DEFINE STR0002		"Source document"
#DEFINE STR0003		"Accounting Entries"
#DEFINE STR0004		"Print"
#DEFINE STR0005		"Fixed Asset Query"
#DEFINE STR0006		"Fields"
#DEFINE STR0007		"Parameters"
#DEFINE STR0008		"From:"
#DEFINE STR0009		"To:"
#DEFINE STR0010		"Date"
#DEFINE STR0011		"Document"
#DEFINE STR0012		"In ocor:"
#DEFINE STR0013		"Selected Fields"
#DEFINE STR0014		"Others Fields"
#DEFINE STR0015		"Fixed Asset Movements"
#DEFINE STR0016		"Was grouped in selected line"
#DEFINE STR0017		"Accounting Entries are not exist"
#DEFINE STR0018		"Document not found"
#DEFINE STR0019		"You do not have fields on table "
#DEFINE STR0020		"to show."
#DEFINE STR0021		"Something wrong with Main query of fields"
#DEFINE STR0022		"In ocors:"
#DEFINE STR0023 	"Group by"
#DEFINE STR0024		"during the period:"
#DEFINE STR0025		"Filter"
#DEFINE STR0026		"Absence of VAT invoices for purchases "
#DEFINE STR0027		"Absence of VAT invoices for sales "
#DEFINE STR0028		"Selection of fields"
#DEFINE STR0029		"Without VAT invoices "
#DEFINE STR0030 	"Timeliness of issuing of VAT sales invoices"
*/

STATIC cMarkOccor as character

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description  for start "Query list of operations".
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
Function RU01R01()

Private aModColor 	as array
Private aButtons2 	as array
Private aButtons1 	as array
Private aMvPar 		as array
Private aTrigGroup 	as array
Private aOrder1 	as array
Private aMAliases	as array
Private aMorFields 	as array
Private aDefFields 	as array
Private aMVparFields as array
Private aCodeBloc 	as array

Private cDefField	as character
Private cExcept 	as character
Private c0Descr 	as character
Private cRutine 	as character
Private cPerg		as character
Private OccorTmpDB	as character

aMAliases:= {{{"SN4"}}}//alliase
aOrder1:={{"N4_CBASE",.T.},{"N4_ITEM",.F.},{"N4_TIPO",.F.},{"N4_OCORR",.F.},{"N4_VLROC1",.F.},{"",.F.}}//rule for sorting on first run (default empty)
cPerg:= "ATFREP" // name of pergunte
aMVparFields:={ {"N4_DATA","DtoS(aMvPar[1])"},{"N4_DATA","DtoS(aMvPar[2])"},{"N4_CBASE","aMvPar[3]"},{"N4_CBASE","aMvPar[4]"},{"N4_OCORR","FASetInQry(Alltrim(aMvPar[5]))"},{"000","Alltrim(aMvPar[6])"} } //pergunte rule for main query
aDefFields:={"N4_CBASE","N4_ITEM","N4_TIPO","N4_OCORR","N4_VLROC1"}//this fields will be showed on first run (default: will be showed fields from index "1")
aMorFields:={""} //More fields for keeping in SQL request.
cRutine:='RU01R01' //must be not more 7 simbols
c0Descr:= STR0005 // Title of main window
cDefField:="N4_FILIAL|N4_CBASE|N4_ITEM|N4_TIPO|N4_OCORR|N4_VLROC1|N4_DATA|N4_TPSALDO|N4_ORIUID|N4_SEQ|N4_UID|N4_CONTA|N4_SUBCTA|N4_CODBAIX|N4_NODIA|N4_IDMOV|N4_SEQREAV|"//fields for keeping in SQL request

aButtons1:={;
{STR0007,"{ || FAUpdatedata(.T.) }",STR0007,STR0007},;
{STR0006,"{ || FAMarkFields() }",STR0006,STR0006},;
{STR0002,"aBCMacr[1]",STR0002,STR0002},;
{STR0003,"aBCMacr[2]",STR0003,STR0003},;
{STR0025, "{ || FAOpenFilter(), GetFAInformation( aMAliases , (ArrToStr( a2Marked , ',' , lGroup, aMarked )) ,,lGroup) , BrRefresh() }",STR0025,STR0025},;
{STR0004,"{ || tReport_SQL(1) }",STR0004,STR0004} } 
//Buttons for first window

aButtons2:= { {STR0002,"a2BCMacr[1]",STR0002,STR0002},;
		{STR0003,"a2BCMacr[2]",STR0003,STR0003},;
		{STR0004,"{ || tReport_SQL(2) }",STR0004,STR0004} }
//Buttons for second window

aCodeBloc:={;
{ "", {"RUGetATFdo",1,""}, "" ,""},;
{ "", {"RU01R01ACE",2,""}, "", ""},;
}
//codeBlock for double click

Pergunte( cPerg , .T. )

aMvPar:={CTOD("01.01.2017"),CTOD("01.01.2017"),'','','',1}

aMvPar[1]:=MV_PAR01
aMvPar[2]:=MV_PAR02
aMvPar[3]:=MV_PAR03
aMvPar[4]:=MV_PAR04
aMvPar[5]:=MV_PAR05
aMvPar[6]:=MV_PAR06

if aMvPar[6]==Nil
	aMvPar[6]:=2
endif

GueryEngine()

Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/26-11-2018
@Description function for start "Query: Absence of VAT invoices for purchases" 4.3.1. 
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
Function RU09T01PUR()

Private aModColor 	as array
Private aButtons2 	as array
Private aButtons1 	as array
Private aMvPar 		as array
Private aTrigGroup 	as array
Private aOrder1 	as array
Private aMAliases	as array
Private aMorFields 	as array
Private aDefFields 	as array
Private aMVparFields as array
Private aCodeBloc 	as array

Private cDefField	as character
Private cExcept 	as character
Private c0Descr 	as character
Private cRutine 	as character
Private cPerg		as character
Private OccorTmpDB	as character

aMAliases:= {;
{ {"SF1","F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA","F1_FILIAL"},{"F37","F37_INVDOC","F37_INVSER","F37_FORNEC","F37_BRANCH","F37_FILIAL"} },;
{ {"F37","F1_DOC","F1_SERIE","F37_KEY","F37_FILIAL"},{"F38","F38_INVDOC","F38_INVSER","F38_KEY","F38_FILIAL"} },;
{ {"SF1","F1_FORNECE","F1_LOJA","'      '"},{"SA2","A2_COD","A2_LOJA","A2_FILIAL"} };
}//Tables and fields for query constructor

aOrder1:={{"F1_EMISSAO",.T.},{"",.F.},{"",.F.},{"",.F.},{"",.F.},{"",.F.}}//rule for sorting on first run (default empty)
cPerg:= "VATPUR" // name of pergunte
aMVparFields:={ {"F1_DTDIGIT","DtoS(aMvPar[1])"},{"F1_DTDIGIT","DtoS(aMvPar[2])"},{"F37_DOC","aMvPar[3]"} } //pergunte rule for main query
aDefFields:={"F1_FILIAL","F1_FORNECE","F1_LOJA","A2_NREDUZ","F1_SERIE","F1_DOC","F1_EMISSAO","F37_DOC","F37_PDATE"}//this fields will be showed on first run (default: will be showed fields from index "1")
aMorFields:={""}//using if need keep in SQL request more fields 
cRutine:='RU09PUR' //- using for ID of FILTER and for name of temp table - must be not more 7 simbols
c0Descr:= STR0036 // Title
cExcept:='F1_OBS|' //exceptions - fields that should not be in the request.
cDefField:='A2_NREDUZ|A2_COD|A2_LOJA|F37_PDATE|F37_DOC|F37_TYPE|F1_TIPO|F1_FILIAL|F1_FORNECE|F1_LOJA|A2_NREDUZ|F1_SERIE|F1_DOC|F1_EMISSAO|F37_KEY|F37_FILIAL|F1_FORMUL|'//Fields forr keep in SQL request.

aButtons1:={ {STR0007,"{ || FAUpdatedata(.T.) }",STR0007,STR0007},;
	{STR0006,"{ || FAMarkFields() }",STR0006,STR0006},;
	{STR0032,"aBCMacr[1]",STR0032,STR0032},;
	{STR0033,"aBCMacr[1]",STR0033,STR0033},;
	{STR0034,"aBCMacr[1]",STR0034,STR0034},;
	{STR0025, "{ || FAOpenFilter(), GetFAInformation( aMAliases , (ArrToStr( a2Marked , ',' , lGroup, aMarked )) ,,lGroup) , BrRefresh() }",STR0025,STR0025},;
	{STR0004,"{ || tReport_SQL(1) }",STR0004,STR0004} }
//buttons in first window

aButtons2:= { {STR0032,"a2BCMacr[1]",STR0032,STR0032},;
		{STR0033,"a2BCMacr[1]",STR0033,STR0033},;
		{STR0034,"a2BCMacr[1]",STR0034,STR0034},;
		{STR0004,"{ || tReport_SQL(2) }",STR0004,STR0004} }
//buttons for second window

aCodeBloc:={;
{ "", {"GetSuppMD",1,""}, "" ,"F1_FORNECE|F1_LOJA|"},;
{ "", {"GetComInv",1,""}, "", "F1_SERIE|F1_DOC|F1_EMISSAO|"},;
{ "", {"GetVATInv",1,""}, "", "F37_DOC|F37_PDATE|"},;
}
//Code block for double cklick

aModColor:={{"F37_DOC","RED",STR0028}}

OccorTmpDB	:= GetOccTmpDB()

Pergunte( cPerg , .T. )

aMvPar:={CTOD("01.01.2017"),CTOD("01.01.2017"),'','','',1}
aMvPar[1]:=MV_PAR01
aMvPar[2]:=MV_PAR02
aMvPar[3]:=MV_PAR03
aMvPar[6]:=MV_PAR04

//aTrigGroup:={"F1_FILIAL","F1_DOC","F1_SERIE","F1_FORNECE","F1_LOJA","F1_FORMUL"}

GueryEngine()

Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/26-11-2018
@Description function for start "Query: Absence of VAT invoices for sales" 4.3.2. 
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
Function RU09T01SAL()

Private aModColor 	as array
Private aButtons2 	as array
Private aButtons1 	as array
Private aMvPar 		as array
Private aTrigGroup 	as array
Private aOrder1 	as array
Private aMAliases	as array
Private aMorFields 	as array
Private aDefFields 	as array
Private aMVparFields as array
Private aCodeBloc 	as array

Private cDefField	as character
Private cExcept 	as character
Private c0Descr 	as character
Private cRutine 	as character
Private cPerg		as character
Private OccorTmpDB	as character

aMAliases:= {;
{ {"SF2","F2_DOC","F2_SERIE","F2_FILIAL"},{"F36","F36_INVDOC","F36_INVSER","F36_FILIAL"} },;
{ {"F36","F36_KEY","F2_CLIENTE","F2_LOJA","F2_FILIAL"},{"F35","F35_KEY","F35_CLIENT","F35_BRANCH","F35_FILIAL"} },;
{ {"SF2","F2_CLIENTE","F2_LOJA","'      '"},{"SA1","A1_COD","A1_LOJA","A1_FILIAL"} };
}//alliase

aOrder1:={{"F2_DTSAIDA",.T.},{"",.F.},{"",.F.},{"",.F.},{"",.F.},{"",.F.}}//rule for sorting on first run (default empty)
cPerg:= "VATSAL" // name of pergunte
aMVparFields:={ {"F2_EMISSAO","DtoS(aMvPar[1])"},{"F2_EMISSAO","DtoS(aMvPar[2])"},{"F35_DOC","aMvPar[3]"} } //pergunte rule for main query
aDefFields:={"F2_FILIAL","F2_CLIENTE","F2_LOJA","A1_NREDUZ","F2_SERIE","F2_DOC","F2_DTSAIDA","F35_DOC","F35_PDATE"}//this fields will be showed on first run (default: will be showed fields from index "1")
aMorFields:={""}
cRutine:='RU09SAL' //must be not more 7 simbols
c0Descr:= STR0037// Title
cDefField:='A1_NREDUZ|A1_COD|A1_LOJA|F35_PDATE|F35_DOC|F35_TYPE|F2_TIPO|F2_FILIAL|F2_FORNECE|F2_LOJA|A1_NREDUZ|F2_SERIE|F2_DOC|F2_EMISSAO|F35_KEY|F35_FILIAL|F2_CLIENTE|F2_DTSAIDA|F2_FORMUL|'

aButtons1:={ {STR0007,"{ || FAUpdatedata(.T.) }",STR0007,STR0007},;
	{STR0006,"{ || FAMarkFields() }",STR0006,STR0006},;
	{STR0032,"aBCMacr[1]",STR0032,STR0032},;
	{STR0033,"aBCMacr[1]",STR0033,STR0033},;
	{STR0034,"aBCMacr[1]",STR0034,STR0034},;
	{STR0025, "{ || FAOpenFilter(), GetFAInformation( aMAliases , (ArrToStr( a2Marked , ',' , lGroup, aMarked )) ,,lGroup) , BrRefresh() }",STR0025,STR0025},;
	{STR0004,"{ || tReport_SQL(1) }",STR0004,STR0004} }

aButtons2:= { {STR0032,"a2BCMacr[1]",STR0032,STR0032},;
		{STR0033,"a2BCMacr[1]",STR0033,STR0033},;
		{STR0034,"a2BCMacr[1]",STR0034,STR0034},;
		{STR0004,"{ || tReport_SQL(2) }",STR0004,STR0004} }

aCodeBloc:={;
{ "", {"GetSuppMD",1,""}, "" ,"F2_CLIENTE|F2_LOJA|"},;
{ "", {"GetComInvs",1,""}, "", "F2_SERIE|F2_DOC|F2_DTSAIDA|"},;
{ "", {"GetVATInv",1,""}, "", "F35_DOC|F35_PDATE|"},;
}

aModColor:={{"F35_DOC","RED",STR0028}}//legend

OccorTmpDB	:= GetOccTmpDB()

Pergunte( cPerg , .T. )

aMvPar:={CTOD("01.01.2017"),CTOD("01.01.2017"),'','','',1}
aMvPar[1]:=MV_PAR01
aMvPar[2]:=MV_PAR02
aMvPar[3]:=MV_PAR03
aMvPar[6]:=MV_PAR04

//aTrigGroup:={"F2_FILIAL","F2_DOC","F2_SERIE","F2_CLIENTE","F2_LOJA"}//keeping Group by

GueryEngine()

Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/26-11-2018
@Description function for start "Query: Timeliness of issuing of VAT sales invoices". 4.3.3. 
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
Function RU09T01INV()

Private aModColor 	as array
Private aButtons2 	as array
Private aButtons1 	as array
Private aMvPar 		as array
Private aTrigGroup 	as array
Private aOrder1 	as array
Private aMAliases	as array
Private aMorFields 	as array
Private aDefFields 	as array
Private aMVparFields as array
Private aCodeBloc 	as array

Private cDefField	as character
Private cExcept 	as character
Private c0Descr 	as character
Private cRutine 	as character
Private cPerg		as character
Private OccorTmpDB	as character

aMAliases:= {;
{ {"SF2","F2_DOC","F2_SERIE","F2_FILIAL"},{"F36","F36_INVDOC","F36_INVSER","F36_FILIAL"} },;
{ {"F36","F36_KEY","F2_CLIENTE","F2_LOJA","F2_FILIAL"},{"F35","F35_KEY","F35_CLIENT","F35_BRANCH","F35_FILIAL"} },;
{ {"SF2","F2_CLIENTE","F2_LOJA","'      '"},{"SA1","A1_COD","A1_LOJA","A1_FILIAL"} };
}//alliase

aOrder1:={{"V_F35F2DAT",.F.},{"",.F.},{"",.F.},{"",.F.},{"",.F.},{"",.F.}}//rule for sorting on first run (default empty)
cPerg:= "VATSIN" // name of pergunte
aMVparFields:={ {"F2_EMISSAO","DtoS(aMvPar[1])"},{"F2_EMISSAO","DtoS(aMvPar[2])"},{"F35_DOC","aMvPar[3]"} } //pergunte rule for main query
aDefFields:={"F2_FILIAL","F2_CLIENTE","F2_LOJA","A1_NREDUZ","F2_SERIE","F2_DOC","F2_DTSAIDA","F35_DOC","F35_PDATE","V_F35F2DAT"}//this fields will be showed on first run (default: will be showed fields from index "1")
aMorFields:={""}
cRutine:='RU09INV' //must be not more 7 simbols
c0Descr:=STR0037 // Title
cDefField:='A1_NREDUZ|A1_COD|A1_LOJA|F35_PDATE|F35_DOC|F35_TYPE|F2_TIPO|F2_FILIAL|F2_FORNECE|F2_LOJA|A1_NREDUZ|F2_SERIE|F2_DOC|F2_EMISSAO|F35_KEY|F35_FILIAL|F2_CLIENTE|F2_DTSAIDA|F2_FORMUL|F2_DTSAIDA|V_F35F2DAT|A1_FILIAL|'

aButtons1:={ {STR0007,"{ || FAUpdatedata(.T.) }",STR0007,STR0007},;
	{STR0006,"{ || FAMarkFields() }",STR0006,STR0006},;
	{STR0032,"aBCMacr[1]",STR0032,STR0032},;
	{STR0033,"aBCMacr[1]",STR0033,STR0033},;
	{STR0034,"aBCMacr[1]",STR0034,STR0034},;
	{STR0025, "{ || FAOpenFilter(), GetFAInformation( aMAliases , (ArrToStr( a2Marked , ',' , lGroup, aMarked )) ,,lGroup) , BrRefresh() }",STR0025,STR0025},;
	{STR0004,"{ || tReport_SQL(1) }",STR0004,STR0004} }

aButtons2:= { {STR0032,"a2BCMacr[1]",STR0032,STR0032},;
		{STR0033,"a2BCMacr[1]",STR0033,STR0033},;
		{STR0034,"a2BCMacr[1]",STR0034,STR0034},;
		{STR0004,"{ || tReport_SQL(2) }",STR0004,STR0004} }

aCodeBloc:={;
{ "", {"GetSuppMD",1,""}, "" ,"F2_CLIENTE|F2_LOJA|"},;
{ "", {"GetComInvs",1,""}, "", "F2_SERIE|F2_DOC|F2_DTSAIDA|"},;
{ "", {"GetVATInv",1,""}, "", "F35_DOC|F35_PDATE|"},;
}

aModColor:={{"V_F35F2DAT","RED",STR0028}}

OccorTmpDB	:= GetOccTmpDB()

Pergunte( cPerg , .T. ) 

aMvPar:={CTOD("01.01.2017"),CTOD("01.01.2017"),'','','',1,1}
aMvPar[1]:=MV_PAR01
aMvPar[2]:=MV_PAR02
aMvPar[3]:=MV_PAR03
aMvPar[6]:=MV_PAR04
aMvPar[7]:=MV_PAR05

GueryEngine()

Return


/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/14-01-2019
@Description function for start "Query: Inflow VAT movements analyses". 4.3.4. 
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
Function RU09T01IVA()

Private aModColor 	as array
Private aButtons2 	as array
Private aButtons1 	as array
Private aMvPar 		as array
Private aTrigGroup 	as array
Private aOrder1 	as array
Private aMAliases	as array
Private aMorFields 	as array
Private aDefFields 	as array
Private aMVparFields as array
Private aCodeBloc 	as array

Private cDefField	as character
Private cExcept 	as character
Private c0Descr 	as character
Private cRutine 	as character
Private cPerg		as character
Private OccorTmpDB	as character
 
aMAliases:= { { {"F34","'      '","F34_SUPPL","F34_SUPUN"},{"SA2","A2_FILIAL","A2_COD","A2_LOJA"} } }//alliase
aOrder1:={{"F34_FILIAL",.T.},{"",.F.},{"",.F.},{"",.F.},{"",.F.},{"",.F.}}//rule for sorting on first run (default empty)
cPerg:= "VATIVA" // name of pergunte

aMVparFields:={ {"F34_DATE","DtoS(aMvPar[1])"},{"F34_DATE","DtoS(aMvPar[2])"} } //pergunte rule for main query

aDefFields:={"F34_FILIAL","F34_SUPPL","F34_SUPUN","A2_NREDUZ","F34_TYPE","F34_VATRT","F34_VATCOD","F34_VATCD2","F34_DOC","F34_PDATE","F34_KEY","F34_DATE","F34_BOOK","F34_VATXV1","F34_VALUV1","F34_VATXV2","F34_VALUV2"}//this fields will be showed on first run (default: will be showed fields from index "1")
aMorFields:={""}

cRutine:='RU09IVA' //must be not more 7 simbols

c0Descr:=STR0038 // Title

cDefField:='A2_COD|A2_LOJA|F34_FILIAL|F34_SUPPL|F34_SUPUN|F34_TYPE|F34_VATRT|F34_VATCOD|F34_VATCD2|F34_BOOKEY|F34_KEY|A2_FILIAL|' //A2_NREDUZ

aButtons1:={ {STR0007,"{ || FAUpdatedata(.T.) }",STR0007,STR0007},;
	{STR0006,"{ || FAMarkFields() }",STR0006,STR0006},;
	{STR0032,"aBCMacr[1]",STR0032,STR0032},;
	{STR0033,"aBCMacr[1]",STR0033,STR0033},;
	{STR0034,"aBCMacr[1]",STR0034,STR0034},;
	{STR0025, "{ || FAOpenFilter(), GetFAInformation( aMAliases , (ArrToStr( a2Marked , ',' , lGroup, aMarked )) ,,lGroup) , BrRefresh() }",STR0025,STR0025},;
	{STR0004,"{ || tReport_SQL(1) }",STR0004,STR0004} }

aButtons2:= { {STR0032,"a2BCMacr[1]",STR0032,STR0032},;
		{STR0033,"a2BCMacr[1]",STR0033,STR0033},;
		{STR0034,"a2BCMacr[1]",STR0034,STR0034},;
		{STR0004,"{ || tReport_SQL(2) }",STR0004,STR0004} }

aCodeBloc:={;
{ "", {"GetSuppMD",1,""}, "" ,"F2_CLIENTE|F2_LOJA|"},;
{ "", {"GetComInvs",1,""}, "", "F2_SERIE|F2_DOC|F2_DTSAIDA|"},;
{ "", {"GetVATInv",1,""}, "", "F35_DOC|F35_PDATE|"},;
}

OccorTmpDB	:= GetOccTmpDB()

Pergunte( cPerg , .T. )

aMvPar:={CTOD("01.01.2017"),CTOD("01.01.2017"),'','','',1}
aMvPar[1]:=MV_PAR01
aMvPar[2]:=MV_PAR02
aMvPar[3]:=MV_PAR03
aMvPar[6]:=MV_PAR04

GueryEngine()
//need clone in virtual this fields F34_VATCOD, F34_VATBS, F34_VALUE,F34_DATE
Return


/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/14-01-2019
@Description function for start "Query: Outflow VAT movements analyses". 4.3.5. 
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
Function RU09T01OVA()

Private aModColor 	as array
Private aButtons2 	as array
Private aButtons1 	as array
Private aMvPar 		as array
Private aTrigGroup 	as array
Private aOrder1 	as array
Private aMAliases	as array
Private aMorFields 	as array
Private aDefFields 	as array
Private aMVparFields as array
Private aCodeBloc 	as array

Private cDefField	as character
Private cExcept 	as character
Private c0Descr 	as character
Private cRutine 	as character
Private cPerg		as character
Private OccorTmpDB	as character

aMAliases:= {;
{ {"F54","'      '","F54_CLIENT","F54_TYPE"},{"SA1","A1_FILIAL","A1_COD","A1_LOJA"} },;
{ {"F54","F54_VATCOD"},{"F31","F31_CODE"} };
}//alliase
 
aOrder1:={{"F54_FILIAL",.T.},{"",.F.},{"",.F.},{"",.F.},{"",.F.},{"",.F.}}//rule for sorting on first run (default empty)
cPerg:= "VATOVA" // name of pergunte

aMVparFields:={ {"F54_DATE","DtoS(aMvPar[1])"},{"F54_DATE","DtoS(aMvPar[2])"} } //pergunte rule for main query

aDefFields:={"F54_FILIAL","F54_CLIENT","F54_CLIBRA","A1_NREDUZ","F54_TYPE","F54_VATRT","F54_VATCOD","F31_OPCODE","F54_DOC","F54_PDATE","F54_KEY","F54_DATE","F54_REGDOC","F54_VALUV1","F54_VATXV1","F54_VALUV2","F54_VATXV2"}//this fields will be showed on first run (default: will be showed fields from index "1")
aMorFields:={""}

cRutine:='RU09OVA' //must be not more 7 simbols

c0Descr:=STR0039 // Title

cDefField:='A1_FILIAL|A1_COD|A1_LOJA|F54_FILIAL|F54_CLIENT|F54_TYPE|F54_VATRT|F54_VATCOD|F54_CLIBRA|A1_NREDUZ|F54_DOC|F54_PDATE|F54_KEY|F54_DATE|F54_REGDOC|F54_VATBS|F54_VALUE|F54_DIRECT|F31_OPCODE|F54_VALUV1|F54_VATXV1|F54_VALUV2|F54_VATXV2|F54_REGKEY|F31_FILIAL|F31_CODE|' //A2_NREDUZ

aButtons1:={ {STR0007,"{ || FAUpdatedata(.T.) }",STR0007,STR0007},;
	{STR0006,"{ || FAMarkFields() }",STR0006,STR0006},;
	{STR0032,"aBCMacr[1]",STR0032,STR0032},;
	{STR0033,"aBCMacr[1]",STR0033,STR0033},;
	{STR0034,"aBCMacr[1]",STR0034,STR0034},;
	{STR0025, "{ || FAOpenFilter(), GetFAInformation( aMAliases , (ArrToStr( a2Marked , ',' , lGroup, aMarked )) ,,lGroup) , BrRefresh() }",STR0025,STR0025},;
	{STR0004,"{ || tReport_SQL(1) }",STR0004,STR0004} }

aButtons2:= { {STR0032,"a2BCMacr[1]",STR0032,STR0032},;
		{STR0033,"a2BCMacr[1]",STR0033,STR0033},;
		{STR0034,"a2BCMacr[1]",STR0034,STR0034},;
		{STR0004,"{ || tReport_SQL(2) }",STR0004,STR0004} }

aCodeBloc:={;
{ "", {"GetSuppMD",1,""}, "" ,"F2_CLIENTE|F2_LOJA|"},;
{ "", {"GetComInvs",1,""}, "", "F2_SERIE|F2_DOC|F2_DTSAIDA|"},;
{ "", {"GetVATInv",1,""}, "", "F35_DOC|F35_PDATE|"},;
}

OccorTmpDB	:= GetOccTmpDB()

Pergunte( cPerg , .T. )

aMvPar:={CTOD("01.01.2017"),CTOD("01.01.2017"),'','','',1}
aMvPar[1]:=MV_PAR01
aMvPar[2]:=MV_PAR02
aMvPar[3]:=MV_PAR03
aMvPar[6]:=MV_PAR04

GueryEngine()

Return


/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/14-01-2019
@Description function for start "Query: Inflow VAT turnover sheet". 4.3.6. 
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
Function RU09T01IVT() 

Private aModColor 	as array
Private aButtons2 	as array
Private aButtons1 	as array
Private aMvPar 		as array
Private aTrigGroup 	as array
Private aOrder1 	as array
Private aMAliases	as array
Private aMorFields 	as array
Private aDefFields 	as array
Private aMVparFields as array
Private aCodeBloc 	as array

Private cDefField	as character
Private cExcept 	as character
Private c0Descr 	as character
Private cRutine 	as character
Private cPerg		as character
Private OccorTmpDB	as character

aMAliases:= {;
{ {"F34","'      '","F34_SUPPL","F34_SUPUN"},{"SA2","A2_FILIAL","A2_COD","A2_LOJA"} },;
{ {"F34","F34_FILIAL","F34_VATCOD","F34_VATCD2","F34_KEY"},{"F32","F32_FILIAL","F32_VATCOD","F32_VATCD2","F32_KEY"} };
}//alliase
aOrder1:={{"F34_FILIAL",.T.},{"",.F.},{"",.F.},{"",.F.},{"",.F.},{"",.F.}}//rule for sorting on first run (default empty)
cPerg:= "VATIVT" // name of pergunte

aMVparFields:={ {"F34_DATE","DtoS(aMvPar[1])"},{"F34_DATE","DtoS(aMvPar[2])"} } //pergunte rule for main query

aDefFields:={"F34_FILIAL","F34_VATRT","F34_VATCOD","F34_SUPPL","F34_SUPUN","A2_NREDUZ","F34_DOC","F34_PDATE","F34_KEY","F32_INIBS","F32_INIBAL","F34_VATXV1","F34_VALUV1","F34_VATXV2","F34_VALUV2","VAT_T_V1","VAL_T_V1","F34_TYPE"}//this fields will be showed on first run (default: will be showed fields from index "1")
aMorFields:={""}

cRutine:='RU09IVT' //must be not more 7 simbols

c0Descr:= STR0040 // Title

cDefField:='A2_COD|A2_LOJA|F34_FILIAL|F34_SUPPL|F34_SUPUN|F34_TYPE|F34_VATRT|F34_VATCOD|F34_VATCD2|F34_DOC|F34_PDATE|F34_KEY|A2_NREDUZ|F34_VATBS|F34_VALUE|F34_BOOKEY|'

aButtons1:={ {STR0007,"{ || FAUpdatedata(.T.) }",STR0007,STR0007},;
	{STR0006,"{ || FAMarkFields() }",STR0006,STR0006},;
	{STR0032,"aBCMacr[1]",STR0032,STR0032},;
	{STR0033,"aBCMacr[1]",STR0033,STR0033},;
	{STR0034,"aBCMacr[1]",STR0034,STR0034},;
	{STR0025, "{ || FAOpenFilter(), GetFAInformation( aMAliases , (ArrToStr( a2Marked , ',' , lGroup, aMarked )) ,,lGroup) , BrRefresh() }",STR0025,STR0025},;
	{STR0004,"{ || tReport_SQL(1) }",STR0004,STR0004} }

aButtons2:= { {STR0032,"a2BCMacr[1]",STR0032,STR0032},;
		{STR0033,"a2BCMacr[1]",STR0033,STR0033},;
		{STR0034,"a2BCMacr[1]",STR0034,STR0034},;
		{STR0004,"{ || tReport_SQL(2) }",STR0004,STR0004} }

aCodeBloc:={;
{ "", {"GetSuppMD",1,""}, "" ,"F2_CLIENTE|F2_LOJA|"},;
{ "", {"GetComInvs",1,""}, "", "F2_SERIE|F2_DOC|F2_DTSAIDA|"},;
{ "", {"GetVATInv",1,""}, "", "F35_DOC|F35_PDATE|"},;
}

OccorTmpDB	:= GetOccTmpDB()

Pergunte( cPerg , .T. )

aMvPar:={CTOD("01.01.2017"),CTOD("01.01.2017"),'','','',1}
aMvPar[1]:=MV_PAR01
aMvPar[2]:=MV_PAR02
aMvPar[3]:=MV_PAR03
aMvPar[6]:=MV_PAR04

GueryEngine()

Return


/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/14-01-2019
@Description function for start "Query: Negative balances of inflow VAT". 4.3.7. 
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/
Function RU09T01NBV()

Private aModColor 	as array
Private aButtons2 	as array
Private aButtons1 	as array
Private aMvPar 		as array
Private aTrigGroup 	as array
Private aOrder1 	as array
Private aMAliases	as array
Private aMorFields 	as array
Private aDefFields 	as array
Private aMVparFields as array
Private aCodeBloc 	as array

Private cDefField	as character
Private cExcept 	as character
Private c0Descr 	as character
Private cRutine 	as character
Private cPerg		as character
Private OccorTmpDB	as character
 
aMAliases:= { { {"F34","'      '","F34_SUPPL","F34_SUPUN"},{"SA2","A2_FILIAL","A2_COD","A2_LOJA"} } }//alliase
aOrder1:={{"F34_FILIAL",.T.},{"",.F.},{"",.F.},{"",.F.},{"",.F.},{"",.F.}}//rule for sorting on first run (default empty)
cPerg:= "VATNBV" // name of pergunte

aMVparFields:={ {"F34_DATE","DtoS(aMvPar[1])"},{"F34_DATE","DtoS(aMvPar[2])"} } //pergunte rule for main query

aDefFields:={"F34_FILIAL","F34_VATRT","F34_VATCOD","F34_SUPPL","F34_SUPUN","A2_NREDUZ","F34_DOC","F34_PDATE","F34_KEY"}//this fields will be showed on first run (default: will be showed fields from index "1")
aMorFields:={""}

cRutine:='RU09NBV' //must be not more 7 simbols

c0Descr:= STR0041 // Title

cDefField:='A2_COD|A2_LOJA|F34_FILIAL|F34_SUPPL|F34_SUPUN|F34_TYPE|F34_VATRT|F34_VATCOD|F34_VATCD2|F34_DOC|F34_PDATE|F34_KEY|F34_BOOKEY|A2_FILIAL|' //A2_NREDUZ

aButtons1:={ {STR0007,"{ || FAUpdatedata(.T.) }",STR0007,STR0007},;
	{STR0006,"{ || FAMarkFields() }",STR0006,STR0006},;
	{STR0032,"aBCMacr[1]",STR0032,STR0032},;
	{STR0033,"aBCMacr[1]",STR0033,STR0033},;
	{STR0034,"aBCMacr[1]",STR0034,STR0034},;
	{STR0025, "{ || FAOpenFilter(), GetFAInformation( aMAliases , (ArrToStr( a2Marked , ',' , lGroup, aMarked )) ,,lGroup) , BrRefresh() }",STR0025,STR0025},;
	{STR0004,"{ || tReport_SQL(1) }",STR0004,STR0004} }

aButtons2:= { {STR0032,"a2BCMacr[1]",STR0032,STR0032},;
		{STR0033,"a2BCMacr[1]",STR0033,STR0033},;
		{STR0034,"a2BCMacr[1]",STR0034,STR0034},;
		{STR0004,"{ || tReport_SQL(2) }",STR0004,STR0004} }

aCodeBloc:={;
{ "", {"GetSuppMD",1,""}, "" ,"F2_CLIENTE|F2_LOJA|"},;
{ "", {"GetComInvs",1,""}, "", "F2_SERIE|F2_DOC|F2_DTSAIDA|"},;
{ "", {"GetVATInv",1,""}, "", "F35_DOC|F35_PDATE|"},;
}

OccorTmpDB	:= GetOccTmpDB()

Pergunte( cPerg , .T. )

aMvPar:={CTOD("01.01.2017"),CTOD("01.01.2017"),'','','',1}
aMvPar[1]:=MV_PAR01
aMvPar[2]:=MV_PAR02
aMvPar[3]:=MV_PAR03
aMvPar[6]:=MV_PAR04

GueryEngine()

Return


/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description guery engine.
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

Function GueryEngine()

Local aArea as array
Local aAuxArea as array
Local cKeepFil as character

Private oBrowse 	as object
Private otBrowse 	as object
Private oOccorTmpTable as object
Private o2MainDlg 	as object
Private o3MainDlg 	as object
Private oFWFilter 	as object

Private aGetField	as array
Private aMarked		as array
Private aSelected 	as array
Private aOthersFields as array
Private aFilter1	as array
Private aFilter2 	as array
Private a2Marked 	as array
Private a3Marked	as array
Private aMFiltStr 	as array
Private aBCMacr 	as array
Private a2BCMacr 	as array
Private aMFieldsF2 	as array
Private aSelFil 	as array
Private aTableNameCur as array
Private aTranslation as array

Private cSN4TmpAlias as character
Private cSN4Tmp2Alias as character
Private cAlias4Fields as character
Private cMark 		as character
Private cOccList 	as character
Private cFilter 	as character
Private cSeleField 	as character
Private cQLPorder 	as character
Private cNewTable 	as character
Private cQuery 		as character
Private c2Query 	as character
Private cDescr 		as character
Private cSelec3 	as character
Private c2DefField 	as character

Private lGroup 		as Logical

Default cExcept:=''
Default cDescrF:=''

aArea := SM0->( GetArea() )
aAuxArea := GetArea()

cKeepFil := cFilant //need for correcting open source documents in situations when user selected a lot of filials
lGroup:=.F.
aSelFil := {}

If aMvPar[6]== 1	// Filter by branches  
	aSelFil := AdmGetFil()
Elseif aMvPar[6]==3
	DbSelectArea( "SM0" )
	SM0->( DbGoTop() )
	DbSeek(cEmpAnt)
	While SM0->( !Eof() ) .AND. SM0->M0_CODIGO = cEmpAnt
      	AAdd( aSelFil, SM0->M0_CODFIL )
     	SM0->(DbSkip()) 
	EndDo
	RestArea( aArea )
	RestArea( aAuxArea )
else

EndIf

If aDefFields!=nil
	aFilter2:=aDefFields
Endif

cNewTable := CriaTrab(,.F.) 

If StartGetFields(aMAliases) // creating temp table with data for structure of fields

	cMark 		:= GetMark()
	cMarkOccor	:= GetMark()
	cOccList	:= ''
	OccorTmpDB	:= GetOccTmpDB()
	cFilter		:= ''
	
	BuildArrFields() // Based on Main Query from StartGetFields(), we create array with Markable Possible fields
	
	cSN4TmpAlias := CriaTrab(,.F.)
	cSN4Tmp2Alias:= CriaTrab(,.F.)
	Build_Screen()

Else
	HELP(' ',1,STR0021)
Endif

If Select(OccorTmpDB) > 0
	oOccorTmpTable:Delete()
Endif
cFilant:= cKeepFil
Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description Get index in array (required for default values)
@Return array
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC function GetMIndArr(cIndexNum as character,aDefFields as array)
local aIndex as array
local cCutIndex as character
local nX as numeric

aIndex:= StrTokArr( (aMAliases[1][1][1])->(IndexKey(1)),"+")

For nX:=1 to len(aIndex)
	If AT("(",aIndex[nX])>0
		cCutIndex:= SUBSTR(aIndex[nX],AT("(",aIndex[nX])+1,len(aIndex[nX]))
		cCutIndex:= SUBSTR(cCutIndex,1,AT(")",cCutIndex)-1)
		aIndex[nX]:=cCutIndex
	Endif
Next nX

Return aIndex

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description Get all fields for structur
@Return logical (.T./.F.)
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function StartGetFields( aMainAlias as array )

Local lReturn as Logical
Local cQuery as character
Local nX as numeric
local aNormalize as array

local cChecking as character

Default aMainAlias := aMAliases

cAlias4Fields:= CriaTrab(,.F.)

aNormalize:={}
aTableNameCur:={}
aTranslation:={}

aNormalize:=RU99X02002_GetDiffDataFromArr(aMainAlias)

For nX:=1 to len(aNormalize)
	RU99X02001_ArrCon(aTableNameCur,FWSX3Util():GetAllFields(aNormalize[nX]))
Next nX

cQuery := " SELECT DISTINCT(XXK_CAMPO),XXK_TEXT"
cQuery += " FROM XXK" + substr(RetSQLName("SA2"),4,3)
cQuery += " WHERE"
cQuery += " XXK_CAMPO  IN ("
For nX:=1 To Len(aTableNameCur)
	if nX==Len(aTableNameCur)
    	cQuery += " '" + AllTrim(aTableNameCur[nX]) + "'"
	else
		cQuery += " '" + AllTrim(aTableNameCur[nX]) + "',"
	endif
Next nX
cQuery += ") AND XXK_IDIOM = 'ru'"
cQuery += " AND XXK_ATTRIB = 'X3_TITULO'"
cQuery += " AND XXK_CODFLA = 'TRANSL'"
cQuery += " AND D_E_L_E_T_ = ' '"
cQuery += " ORDER BY XXK_CAMPO" 

cQuery:=Changequery(cQuery)

dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQuery) , cAlias4Fields ,.T.,.F.)

lReturn := !(cAlias4Fields)->(EOF())

(cAlias4Fields)->( dbGoTop() )
nX:=0
cChecking:=''
While !(cAlias4Fields)->( EOF() )
	nX+=1
	If cChecking!=Alltrim((cAlias4Fields)->(XXK_CAMPO))
		AADD(aTranslation,{(cAlias4Fields)->(XXK_CAMPO),(cAlias4Fields)->(XXK_TEXT)})
	Endif
	cChecking:=Alltrim((cAlias4Fields)->(XXK_CAMPO))
	(cAlias4Fields)->( dbSkip() )
EndDo

aTranslation:=RU99X02003_ArrReSort(aTranslation,aTableNameCur)

Return lReturn

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/15-07-2019
@Description array/array resorter
@Return Array
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

Function RU99X02003_ArrReSort(aArray1,aArray2)//
Local nX as numeric
Local nX2 as numeric
Local aTempArr as array
local nLenAr as numeric

nLenAr:=Len(aArray1)
aTempArr:={}

For nX:=1 to nLenAr
	For nX2:=1 to nLenAr
		If aArray2[nX]==aArray1[nX2][1]
			Aadd(aTempArr,{aArray1[nX2][1],aArray1[nX2][2]})
		Endif
	Next nX2
Next nX

Return(aTempArr)


/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/15-07-2019
@Description array connector
@Return Array
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

Function RU99X02001_ArrCon(aArray1,aArray2)
Local nX as numeric
Local nLenAr1 as numeric
Local nLenAr2 as numeric

nLenAr1:=Len(aArray1)
nLenAr2:=Len(aArray2)

ASIZE(aArray1, nLenAr1+nLenAr2)

For nX:=1 to nLenAr2
	aArray1[nX+nLenAr1]:=PadR(aArray2[nX], 10, " ") //aArray2[nX]
Next nX

Return(aArray1)


/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/15-07-2019
@Description get different data frome array
@Return Array
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

Function RU99X02002_GetDiffDataFromArr(aArray)
Local aNormalize as array
Local nX as numeric

aNormalize:={}
 
If !empty(aArray)
	For nX:=1 to len(aArray)
		If ASCAN(aNormalize,aArray[nX][1][1])==0
			aadd(aNormalize,aArray[nX][1][1])
		Endif
		If len(aArray)>1 .and. ASCAN(aNormalize,aArray[nX][2][1])==0
			aadd(aNormalize,aArray[nX][2][1])
		Endif
	Next nX
Endif

Return(aNormalize)



/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/15-07-2019
@Description get special data from array to character
@Return Character
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

Function RU99X02004_ArrSpecialToStr(aArray as array,cSep as character,nNumTarget as numeric,nNumArr as numeric)
Local nX1 as numeric
Local nX2 as numeric
Local nX3 as numeric
Local cChaArr as character

If !Empty(aArray)

	cChaArr:=''
	If nNumArr==NIL
		if nNumTarget==NIL
			For nX1:=1 to len(aArray)
				cChaArr+=aArray[nX1]+cSep
			Next nX1
		Else
			For nX1:=1 to len(aArray)
				cChaArr+=aArray[nX1][nNumTarget]+cSep
			Next nX1
		endif

	Elseif nNumArr==3
			For nX1:=1 to len(aArray)
				For nX2:=1 to len(aArray[nX1])
					cChaArr+=aArray[nX1][nX2][nNumTarget]+cSep
				Next nX2
			Next nX1
	
	Elseif nNumArr==4

		For nX1:=1 to len(aArray)
			For nX2:=1 to len(aArray[nX1])
				For nX3:=1 to len(aArray[nX1][nX2])
					cChaArr+=aArray[nX1][nX2][nX3][nNumTarget]+cSep
				Next nX3
			Next nX2
		Next nX1
	Else
		Conout('No variants in function RU99X02004_ARRTOSTR')
	Endif
Endif
Return(cChaArr)

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/15-07-2019
@Description get special data from array to array
@Return Character
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

Function RU99X02005_ArrSpecialToArr(aArray as array,nSep as numeric,nNumTarget as numeric,nNumArr as numeric)
Local nX1 as numeric
Local nX2 as numeric
Local nX3 as numeric
Local aRezArr as array

If !Empty(aArray)

if nSep!=nil
	aRezArr:={}
	If nNumArr==NIL
		if nNumTarget==NIL
			For nX1:=1 to len(aArray)
				AADD(aRezArr,Padr(aArray[nX1],nSep))
			Next nX1
		Else
			For nX1:=1 to len(aArray)
				AADD(aRezArr,Padr(aArray[nX1][nNumTarget],nSep))
			Next nX1
		endif

	Elseif nNumArr==3
			For nX1:=1 to len(aArray)
				For nX2:=1 to len(aArray[nX1])
					AADD(aRezArr,Padr(aArray[nX1][nX2][nNumTarget],nSep))
				Next nX2
			Next nX1
	
	Elseif nNumArr==4

		For nX1:=1 to len(aArray)
			For nX2:=1 to len(aArray[nX1])
				For nX3:=1 to len(aArray[nX1][nX2])
					AADD(aRezArr,Padr(aArray[nX1][nX2][nX3][nNumTarget],nSep))
				Next nX3
			Next nX2
		Next nX1
	Else
		Conout('No variants in function RU99X02004_ARRTOSTR')
	Endif
else
	aRezArr:={}
	If nNumArr==NIL
		if nNumTarget==NIL
			For nX1:=1 to len(aArray)
				AADD(aRezArr,aArray[nX1])
			Next nX1
		Else
			For nX1:=1 to len(aArray)
				AADD(aRezArr,aArray[nX1][nNumTarget])
			Next nX1
		endif

	Elseif nNumArr==3
			For nX1:=1 to len(aArray)
				For nX2:=1 to len(aArray[nX1])
					AADD(aRezArr,aArray[nX1][nX2][nNumTarget])
				Next nX2
			Next nX1
	
	Elseif nNumArr==4

		For nX1:=1 to len(aArray)
			For nX2:=1 to len(aArray[nX1])
				For nX3:=1 to len(aArray[nX1][nX2])
					AADD(aRezArr,aArray[nX1][nX2][nX3][nNumTarget])
				Next nX3
			Next nX2
		Next nX1
	Else
		Conout('No variants in function RU99X02004_ARRTOSTR')
	Endif
Endif
Endif
Return(aRezArr)

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description get structur array and selectable unselectable fields
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function BuildArrFields( cFilterFields as character )

Local aPosField as array
Local aPosText as array
Local aPosOrder as array
Local aPosType as array
Local aPosSize as array
Local aPosDecimal as array
Local aPosPicture as array
Local aPosF3 as array
Local aPosArquivo as array
Local cFiltCut as character
Local nX as numeric
Local nX2 as numeric
Local nCheck as numeric

If empty(aFilter2) .or. empty(cFilterFields)
	aFilter1:={}
	AADD(aFilter1,(GetMIndArr("1"))[1])
	For nX:=1 to len(aMVparFields)
		AADD(aFilter1,aMVparFields[nX][1]) 
	Next nX
Endif

If empty(aFilter2)
	aFilter2:={}
	For nX:=2 to Len(aFilter1)

		If nX!=len(aFilter1) .and. aFilter1[nX]==aFilter1[nX+1]
			nX+=1
		Endif

		AADD(aFilter2,aFilter1[nX])

	Next nX
Endif

If empty(cFilterFields)
	cFilterFields:=""
	For nX:=1 to Len(aFilter2)
		cFilterFields += aFilter2[nX] + "|"
	Next nX
Endif

aPosField	:={}
aPosText	:={}
aPosOrder	:={}
aPosType	:={}
aPosSize	:={}
aPosDecimal	:={}
aPosPicture	:={}
aPosF3 :={}
aPosArquivo:={}
nCheck:=0

aGetField	:= {}
aMarked		:= {}
aSelected	:= {}
aOthersFields:= {}
a2Marked	:={}
a3Marked	:={}
aMFiltStr	:={}

nX:=0
For nX2=1 to len(aTableNameCur)
	If X3Usado(aTableNameCur[nX2]) .and. !(alltrim(aTableNameCur[nX2]) $ cExcept) .or. (alltrim(aTableNameCur[nX2]) $ cDefField)// checking using fields
	

		If FwisincallStack("RU09T01OVA")

			if alltrim(aTableNameCur[nX2]) == "F54_VATBS"

				Aadd(aPosField,("F54_VATXV1")) 
				Aadd(aPosText,( alltrim(aTranslation[nX2][2])+" + "))
				Aadd(aPosSize,GetSx3Cache(aTableNameCur[nX2],"X3_TAMANHO"))
				Aadd(aPosDecimal,GetSx3Cache(aTableNameCur[nX2],"X3_DECIMAL"))
				Aadd(aPosOrder,GetSx3Cache(aTableNameCur[nX2],"X3_ORDEM"))
				Aadd(aPosType,GetSx3Cache(aTableNameCur[nX2],"X3_TIPO"))
				Aadd(aPosPicture,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosF3,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosArquivo,GetSx3Cache(aTableNameCur[nX2],"X3_ARQUIVO"))

				Aadd(aPosField,("F54_VATXV2")) 
				Aadd(aPosText,( alltrim(aTranslation[nX2][2])+" - "))
				Aadd(aPosSize,GetSx3Cache(aTableNameCur[nX2],"X3_TAMANHO"))
				Aadd(aPosDecimal,GetSx3Cache(aTableNameCur[nX2],"X3_DECIMAL"))
				Aadd(aPosOrder,GetSx3Cache(aTableNameCur[nX2],"X3_ORDEM"))
				Aadd(aPosType,GetSx3Cache(aTableNameCur[nX2],"X3_TIPO"))
				Aadd(aPosPicture,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosF3,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosArquivo,GetSx3Cache(aTableNameCur[nX2],"X3_ARQUIVO"))
			
			elseif alltrim(aTableNameCur[nX2]) == "F54_VALUE"
			
				Aadd(aPosField,("F54_VALUV1"))
				Aadd(aPosText,( alltrim(aTranslation[nX2][2])+" + "))
				Aadd(aPosSize,GetSx3Cache(aTableNameCur[nX2],"X3_TAMANHO"))
				Aadd(aPosDecimal,GetSx3Cache(aTableNameCur[nX2],"X3_DECIMAL"))
				Aadd(aPosOrder,GetSx3Cache(aTableNameCur[nX2],"X3_ORDEM"))
				Aadd(aPosType,GetSx3Cache(aTableNameCur[nX2],"X3_TIPO"))
				Aadd(aPosPicture,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosF3,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosArquivo,GetSx3Cache(aTableNameCur[nX2],"X3_ARQUIVO"))

				Aadd(aPosField,("F54_VALUV2")) 
				Aadd(aPosText,(alltrim(aTranslation[nX2][2])+" - "))
				Aadd(aPosSize,GetSx3Cache(aTableNameCur[nX2],"X3_TAMANHO"))
				Aadd(aPosDecimal,GetSx3Cache(aTableNameCur[nX2],"X3_DECIMAL"))
				Aadd(aPosOrder,GetSx3Cache(aTableNameCur[nX2],"X3_ORDEM"))
				Aadd(aPosType,GetSx3Cache(aTableNameCur[nX2],"X3_TIPO"))
				Aadd(aPosPicture,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosF3,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosArquivo,GetSx3Cache(aTableNameCur[nX2],"X3_ARQUIVO"))
			else
				Aadd(aPosField,(aTableNameCur[nX2]))
				Aadd(aPosText,(aTranslation[nX2][2]))
				Aadd(aPosSize,GetSx3Cache(aTableNameCur[nX2],"X3_TAMANHO"))
				Aadd(aPosDecimal,GetSx3Cache(aTableNameCur[nX2],"X3_DECIMAL"))
				Aadd(aPosOrder,GetSx3Cache(aTableNameCur[nX2],"X3_ORDEM"))
				Aadd(aPosType,GetSx3Cache(aTableNameCur[nX2],"X3_TIPO"))
				Aadd(aPosPicture,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosF3,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosArquivo,GetSx3Cache(aTableNameCur[nX2],"X3_ARQUIVO"))
			endif


		elseif (FwisincallStack("RU09T01IVA") .or. FwisincallStack("RU09T01IVT") /*.or. FwisincallStack("RU09T01NBV")*/)//4.3.4
			if alltrim(aTableNameCur[nX2]) == "F34_VATBS"

				Aadd(aPosField,("F34_VATXV1")) 
				Aadd(aPosText,( alltrim(aTranslation[nX2][2])+" + "))
				Aadd(aPosSize,GetSx3Cache(aTableNameCur[nX2],"X3_TAMANHO"))
				Aadd(aPosDecimal,GetSx3Cache(aTableNameCur[nX2],"X3_DECIMAL"))
				Aadd(aPosOrder,GetSx3Cache(aTableNameCur[nX2],"X3_ORDEM"))
				Aadd(aPosType,GetSx3Cache(aTableNameCur[nX2],"X3_TIPO"))
				Aadd(aPosPicture,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosF3,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosArquivo,GetSx3Cache(aTableNameCur[nX2],"X3_ARQUIVO"))

				Aadd(aPosField,("F34_VATXV2")) 
				Aadd(aPosText,( alltrim(aTranslation[nX2][2])+" - "))
				Aadd(aPosSize,GetSx3Cache(aTableNameCur[nX2],"X3_TAMANHO"))
				Aadd(aPosDecimal,GetSx3Cache(aTableNameCur[nX2],"X3_DECIMAL"))
				Aadd(aPosOrder,GetSx3Cache(aTableNameCur[nX2],"X3_ORDEM"))
				Aadd(aPosType,GetSx3Cache(aTableNameCur[nX2],"X3_TIPO"))
				Aadd(aPosPicture,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosF3,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosArquivo,GetSx3Cache(aTableNameCur[nX2],"X3_ARQUIVO"))

				if FwisincallStack("RU09T01IVT")
					Aadd(aPosField,("VAT_T_V1")) 
					Aadd(aPosText,(alltrim(aTranslation[nX2][2])+" - "))
					Aadd(aPosSize,GetSx3Cache(aTableNameCur[nX2],"X3_TAMANHO"))
					Aadd(aPosDecimal,GetSx3Cache(aTableNameCur[nX2],"X3_DECIMAL"))
					Aadd(aPosOrder,GetSx3Cache(aTableNameCur[nX2],"X3_ORDEM"))
					Aadd(aPosType,GetSx3Cache(aTableNameCur[nX2],"X3_TIPO"))
					Aadd(aPosPicture,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
					Aadd(aPosF3,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
					Aadd(aPosArquivo,GetSx3Cache(aTableNameCur[nX2],"X3_ARQUIVO"))
				endif
			
			elseif alltrim(aTableNameCur[nX2]) == "F34_VALUE"
			
				Aadd(aPosField,("F34_VALUV1"))
				Aadd(aPosText,( alltrim(aTranslation[nX2][2])+" + "))
				Aadd(aPosSize,GetSx3Cache(aTableNameCur[nX2],"X3_TAMANHO"))
				Aadd(aPosDecimal,GetSx3Cache(aTableNameCur[nX2],"X3_DECIMAL"))
				Aadd(aPosOrder,GetSx3Cache(aTableNameCur[nX2],"X3_ORDEM"))
				Aadd(aPosType,GetSx3Cache(aTableNameCur[nX2],"X3_TIPO"))
				Aadd(aPosPicture,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosF3,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosArquivo,GetSx3Cache(aTableNameCur[nX2],"X3_ARQUIVO"))

				Aadd(aPosField,("F34_VALUV2")) 
				Aadd(aPosText,(alltrim(aTranslation[nX2][2])+" - "))
				Aadd(aPosSize,GetSx3Cache(aTableNameCur[nX2],"X3_TAMANHO"))
				Aadd(aPosDecimal,GetSx3Cache(aTableNameCur[nX2],"X3_DECIMAL"))
				Aadd(aPosOrder,GetSx3Cache(aTableNameCur[nX2],"X3_ORDEM"))
				Aadd(aPosType,GetSx3Cache(aTableNameCur[nX2],"X3_TIPO"))
				Aadd(aPosPicture,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosF3,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosArquivo,GetSx3Cache(aTableNameCur[nX2],"X3_ARQUIVO"))

				if FwisincallStack("RU09T01IVT")
					Aadd(aPosField,("VAL_T_V1")) 
					Aadd(aPosText,(alltrim(aTranslation[nX2][2])+" - "))
					Aadd(aPosSize,GetSx3Cache(aTableNameCur[nX2],"X3_TAMANHO"))
					Aadd(aPosDecimal,GetSx3Cache(aTableNameCur[nX2],"X3_DECIMAL"))
					Aadd(aPosOrder,GetSx3Cache(aTableNameCur[nX2],"X3_ORDEM"))
					Aadd(aPosType,GetSx3Cache(aTableNameCur[nX2],"X3_TIPO"))
					Aadd(aPosPicture,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
					Aadd(aPosF3,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
					Aadd(aPosArquivo,GetSx3Cache(aTableNameCur[nX2],"X3_ARQUIVO"))
				endif

			else
				Aadd(aPosField,(aTableNameCur[nX2]))
				Aadd(aPosText,(aTranslation[nX2][2]))
				Aadd(aPosSize,GetSx3Cache(aTableNameCur[nX2],"X3_TAMANHO"))
				Aadd(aPosDecimal,GetSx3Cache(aTableNameCur[nX2],"X3_DECIMAL"))
				Aadd(aPosOrder,GetSx3Cache(aTableNameCur[nX2],"X3_ORDEM"))
				Aadd(aPosType,GetSx3Cache(aTableNameCur[nX2],"X3_TIPO"))
				Aadd(aPosPicture,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosF3,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosArquivo,GetSx3Cache(aTableNameCur[nX2],"X3_ARQUIVO"))
			endif


		elseif FwisincallStack("RU09T01INV")

			IF alltrim(aTableNameCur[nX2]) == "F35_PDATE"
				Aadd(aPosField,(aTableNameCur[nX2]))
				Aadd(aPosText,(aTranslation[nX2][2]))
				Aadd(aPosSize,GetSx3Cache(aTableNameCur[nX2],"X3_TAMANHO"))
				Aadd(aPosDecimal,GetSx3Cache(aTableNameCur[nX2],"X3_DECIMAL"))
				Aadd(aPosOrder,GetSx3Cache(aTableNameCur[nX2],"X3_ORDEM"))
				Aadd(aPosType,GetSx3Cache(aTableNameCur[nX2],"X3_TIPO"))
				Aadd(aPosPicture,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosF3,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosArquivo,GetSx3Cache(aTableNameCur[nX2],"X3_ARQUIVO"))

				Aadd(aPosField,("V_F35F2DAT"))
				Aadd(aPosText,( Alltrim(aTranslation[nX2][2])+" !Test! " ))
				Aadd(aPosSize,GetSx3Cache(aTableNameCur[nX2],"X3_TAMANHO"))
				Aadd(aPosDecimal,GetSx3Cache(aTableNameCur[nX2],"X3_DECIMAL"))
				Aadd(aPosOrder,GetSx3Cache(aTableNameCur[nX2],"X3_ORDEM"))
				Aadd(aPosType,GetSx3Cache(aTableNameCur[nX2],"X3_TIPO"))
				Aadd(aPosPicture,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosF3,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosArquivo,GetSx3Cache(aTableNameCur[nX2],"X3_ARQUIVO"))
			else
				Aadd(aPosField,(aTableNameCur[nX2]))
				Aadd(aPosText,(aTranslation[nX2][2]))
				Aadd(aPosSize,GetSx3Cache(aTableNameCur[nX2],"X3_TAMANHO"))
				Aadd(aPosDecimal,GetSx3Cache(aTableNameCur[nX2],"X3_DECIMAL"))
				Aadd(aPosOrder,GetSx3Cache(aTableNameCur[nX2],"X3_ORDEM"))
				Aadd(aPosType,GetSx3Cache(aTableNameCur[nX2],"X3_TIPO"))
				Aadd(aPosPicture,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosF3,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
				Aadd(aPosArquivo,GetSx3Cache(aTableNameCur[nX2],"X3_ARQUIVO"))
			endif
		else
			Aadd(aPosField,(aTableNameCur[nX2]))
			Aadd(aPosText,(aTranslation[nX2][2]))
			Aadd(aPosSize,GetSx3Cache(aTableNameCur[nX2],"X3_TAMANHO"))
			Aadd(aPosDecimal,GetSx3Cache(aTableNameCur[nX2],"X3_DECIMAL"))
			Aadd(aPosOrder,GetSx3Cache(aTableNameCur[nX2],"X3_ORDEM"))
			Aadd(aPosType,GetSx3Cache(aTableNameCur[nX2],"X3_TIPO"))
			Aadd(aPosPicture,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
			Aadd(aPosF3,GetSx3Cache(aTableNameCur[nX2],"X3_PICTURE"))
			Aadd(aPosArquivo,GetSx3Cache(aTableNameCur[nX2],"X3_ARQUIVO"))
		endif
	Endif
next nX2

c2DefField:=""

For nX:=1 to len(aFilter2)
	cFiltCut := aFilter2[nX]
	For nX2:=1 to len(aPosField)
		If Alltrim( aPosField[nX2] ) == cFiltCut
			Aadd(aMarked , { aPosField[nX2] , aPosType[nX2] , aPosSize[nX2], aPosDecimal[nX2], aPosText[nX2],aPosArquivo[nX2] } )
			c2DefField+=alltrim(aPosField[nX2])+"|"	
			Aadd(aSelected, ( aPosField[nX2] + ' - ' + aPosText[nX2]) )
			Aadd(aMFiltStr, {aPosField[nX2],aPosText[nX2],aPosType[nX2],aPosSize[nX2],aPosDecimal[nX2],aPosPicture[nX2],,aPosF3[nX2]})
			If aPosType[nX2]!='N'
				if FWisincallstack("RU09T01INV") .and. aPosField[nX2]=='V_F35F2DAT'
				else
					Aadd(a3Marked , { aPosField[nX2] , aPosType[nX2] , aPosSize[nX2], aPosDecimal[nX2], aPosText[nX2],aPosArquivo[nX2] } )
				endif
			Endif
			nX2:=len(aPosField)
		Endif
	Next nX2
Next nX

For nX2:=1 to len(aPosField)
	If Alltrim(aPosField[nX2]) $ cFilterFields
		Aadd(aGetField , { cMark , aPosField[nX2] , aPosText[nX2] , aPosOrder[nX2] } )
	Else
		Aadd(aGetField, { "" , aPosField[nX2] , aPosText[nX2] , aPosOrder[nX2] } )
		Aadd(aOthersFields, ( aPosField[nX2] + ' - ' + aPosText[nX2] ) )
	Endif

	If Alltrim(aPosField[nX2]) $ c2DefField .or. Alltrim(aPosField[nX2]) $ cDefField 
		Aadd(a2Marked , { aPosField[nX2] , aPosType[nX2] , aPosSize[nX2], aPosDecimal[nX2], aPosText[nX2],aPosArquivo[nX2] } )
	Endif

Next nX2
aMFieldsF2:={}

cFiltCut:=""
For nX:=1 to len(aDefFields)
	cFiltCut:=aDefFields[nX]+"|"
Next nX

For nX2:=1 to len(aPosField)
	If Alltrim( aPosField[nX2] ) == cFiltCut .or. Alltrim(aPosField[nX2]) $ cDefField
		Aadd(aMFieldsF2 , { aPosField[nX2] , aPosType[nX2] , aPosSize[nX2], aPosDecimal[nX2], aPosText[nX2],aPosArquivo[nX2] } )
	Endif
Next nX2

Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description get query for data (main window)
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function GetFAInformation( aStdTable as character , aFieldsQuery as array , cWhere as character , lGroup as Logical)

Local cIniDate as character
Local cEndDate as character
//Local cIniAsset as character
Local cEndAsset as character
Local cN4_Occor as character
Local cInOccor as character
Local cFAGroupSN as character
Local nX as numeric
local nX2 as numeric
local nX3 as numeric
Local cStdTable as numeric
Local cFilials as character

Default cWhere := ""
Default cOrder := ""

cIniDate 	:= DtoS(aMvPar[1])
cEndDate 	:= DtoS(aMvPar[2])
//cIniAsset 	:= aMvPar[3]
cEndAsset 	:= aMvPar[4]
cN4_Occor	:= Alltrim( aMvPar[5] )
cInOccor	:= aMvPar[6]

//Main title

cDescr:= c0Descr + (PadR(" ", (round(((FWGetDialogSize(oMainWnd))[4])/30,0)) , " "))//indent, taking into account the screen resolution.

//message after title (date from... to..., document name from... to...)
if !empty(cIniDate) .and. !empty(cEndDate)
	cDescr+= " " + STR0024 + ((substr((DtoS(aMvPar[1])),7,2)) + "." + (substr((DtoS(aMvPar[1])),5,2)) + "." + (substr((DtoS(aMvPar[1])),1,4)))
	cDescr+= ' - ' + ((substr((DtoS(aMvPar[2])),7,2)) + "." + (substr((DtoS(aMvPar[2])),5,2)) + "." + (substr((DtoS(aMvPar[2])),1,4)))
Elseif !empty(cIniDate) .and. empty(cEndDate)
	cDescr+= STR0010
	cDescr+= " " + STR0008 + ((substr((DtoS(aMvPar[1])),7,2)) + "." + (substr((DtoS(aMvPar[1])),5,2)) + "." + (substr((DtoS(aMvPar[1])),1,4)))
Elseif empty(cIniDate) .and. !empty(cEndDate)
	cDescr+= STR0010
	cDescr+= ', '+ STR0009 + ((substr((DtoS(aMvPar[2])),7,2)) + "." + (substr((DtoS(aMvPar[2])),5,2)) + "." + (substr((DtoS(aMvPar[2])),1,4)))
Endif

cFilials:=""
if aSelFil!=Nil .and. len(aSelFil)>=1
	For nX:=1 to Len(aSelFil)
		if nX==1
			cFilials+= "'"+aSelFil[nX]+"'"
		else
			cFilials+= ",'"+aSelFil[nX]+"'"
		Endif
	Next nX
Else
cFilials+= "'"+ Alltrim(xFilial(aStdTable[1][1][1])) + "'"
Endif

//main query
If !Empty(aFieldsQuery[FOR_QUERY])
	cQuery := " SELECT " + IIF(FWisincallstack("RU09T01SAL") .or. FWisincallstack("RU09T01PUR"),"DISTINCT ","")
	cQuery+= alltrim(aFieldsQuery[FOR_QUERY]) 

	If FWisincallstack("RU09T01OVA")
		if !lGroup
			cQuery:= SUBSTR(cQuery,1,AT("F54_VALUV1",cQuery,1)-1) + "CASE WHEN F54_DIRECT='+' THEN F54_VALUE ELSE 0 END AS F54_VALUV1" + SUBSTR(cQuery,AT("F54_VALUV1",cQuery,1)+10,len(cQuery))
			cQuery:= SUBSTR(cQuery,1,AT("F54_VATXV1",cQuery,1)-1) + "CASE WHEN F54_DIRECT='+' THEN F54_VATBS ELSE 0 END AS F54_VATXV1" + SUBSTR(cQuery,AT("F54_VATXV1",cQuery,1)+10,len(cQuery))
			cQuery:= SUBSTR(cQuery,1,AT("F54_VALUV2",cQuery,1)-1) + "CASE WHEN F54_DIRECT='-' THEN F54_VALUE ELSE 0 END AS F54_VALUV2" + SUBSTR(cQuery,AT("F54_VALUV2",cQuery,1)+10,len(cQuery))
			cQuery:= SUBSTR(cQuery,1,AT("F54_VATXV2",cQuery,1)-1) + "CASE WHEN F54_DIRECT='-' THEN F54_VATBS ELSE 0 END AS F54_VATXV2" + SUBSTR(cQuery,AT("F54_VATXV2",cQuery,1)+10,len(cQuery))
		else
			cQuery:= SUBSTR(cQuery,1,AT("F54_VALUV1",cQuery,1)-1) + "CASE WHEN F54_DIRECT='+' THEN F54_VALUE ELSE 0 END " + SUBSTR(cQuery,AT("F54_VALUV1",cQuery,1)+10,len(cQuery))
			cQuery:= SUBSTR(cQuery,1,AT("F54_VATXV1",cQuery,1)-1) + "CASE WHEN F54_DIRECT='+' THEN F54_VATBS ELSE 0 END " + SUBSTR(cQuery,AT("F54_VATXV1",cQuery,1)+10,len(cQuery))
			cQuery:= SUBSTR(cQuery,1,AT("F54_VALUV2",cQuery,1)-1) + "CASE WHEN F54_DIRECT='-' THEN F54_VALUE ELSE 0 END " + SUBSTR(cQuery,AT("F54_VALUV2",cQuery,1)+10,len(cQuery))
			cQuery:= SUBSTR(cQuery,1,AT("F54_VATXV2",cQuery,1)-1) + "CASE WHEN F54_DIRECT='-' THEN F54_VATBS ELSE 0 END " + SUBSTR(cQuery,AT("F54_VATXV2",cQuery,1)+10,len(cQuery))
		endif
	elseIf (FWisincallstack("RU09T01IVA") .or. FWisincallstack("RU09T01IVT") /*.or. FWisincallstack("RU09T01NBV")*/)
		If !lGroup
			cQuery:= SUBSTR(cQuery,1,AT("F34_VALUV1",cQuery,1)-1) + "CASE WHEN F34_TYPE IN ('01','04') THEN F34_VALUE ELSE 0 END AS F34_VALUV1" + SUBSTR(cQuery,AT("F34_VALUV1",cQuery,1)+10,len(cQuery))
			cQuery:= SUBSTR(cQuery,1,AT("F34_VATXV1",cQuery,1)-1) + "CASE WHEN F34_TYPE IN ('01','04') THEN F34_VATBS ELSE 0 END AS F34_VATXV1" + SUBSTR(cQuery,AT("F34_VATXV1",cQuery,1)+10,len(cQuery))
			cQuery:= SUBSTR(cQuery,1,AT("F34_VALUV2",cQuery,1)-1) + "CASE WHEN F34_TYPE IN ('02','03') THEN F34_VALUE ELSE 0 END AS F34_VALUV2" + SUBSTR(cQuery,AT("F34_VALUV2",cQuery,1)+10,len(cQuery))
			cQuery:= SUBSTR(cQuery,1,AT("F34_VATXV2",cQuery,1)-1) + "CASE WHEN F34_TYPE IN ('02','03') THEN F34_VATBS ELSE 0 END AS F34_VATXV2" + SUBSTR(cQuery,AT("F34_VATXV2",cQuery,1)+10,len(cQuery))

			cQuery:= SUBSTR(cQuery,1,AT("VAT_T_V1",cQuery,1)-1) + "(CASE WHEN F34_TYPE IN ('01','04') THEN F34_VATBS ELSE 0 end-CASE WHEN F34_TYPE IN ('02','03') THEN F34_VATBS ELSE 0 end+F32_INIBS) as VAT_T_V1" + SUBSTR(cQuery,AT("VAT_T_V1",cQuery,1)+8,len(cQuery))
			cQuery:= SUBSTR(cQuery,1,AT("VAL_T_V1",cQuery,1)-1) + "(CASE WHEN F34_TYPE IN ('01','04') THEN F34_VALUE ELSE 0 end-CASE WHEN F34_TYPE IN ('02','03') THEN F34_VALUE ELSE 0 END+F32_INIBAL) as VAL_T_V1" + SUBSTR(cQuery,AT("VAL_T_V1",cQuery,1)+8,len(cQuery))
		else
			cQuery:= SUBSTR(cQuery,1,AT("F34_VALUV1",cQuery,1)-1) + "CASE WHEN F34_TYPE IN ('01','04') THEN F34_VALUE ELSE 0 END " + SUBSTR(cQuery,AT("F34_VALUV1",cQuery,1)+10,len(cQuery))
			cQuery:= SUBSTR(cQuery,1,AT("F34_VATXV1",cQuery,1)-1) + "CASE WHEN F34_TYPE IN ('01','04') THEN F34_VATBS ELSE 0 END " + SUBSTR(cQuery,AT("F34_VATXV1",cQuery,1)+10,len(cQuery))
			cQuery:= SUBSTR(cQuery,1,AT("F34_VALUV2",cQuery,1)-1) + "CASE WHEN F34_TYPE IN ('02','03') THEN F34_VALUE ELSE 0 END " + SUBSTR(cQuery,AT("F34_VALUV2",cQuery,1)+10,len(cQuery))
			cQuery:= SUBSTR(cQuery,1,AT("F34_VATXV2",cQuery,1)-1) + "CASE WHEN F34_TYPE IN ('02','03') THEN F34_VATBS ELSE 0 END " + SUBSTR(cQuery,AT("F34_VATXV2",cQuery,1)+10,len(cQuery))

			cQuery:= SUBSTR(cQuery,1,AT("VAT_T_V1",cQuery,1)-1) + "(CASE WHEN F34_TYPE IN ('01','04') THEN F34_VATBS ELSE 0 end-CASE WHEN F34_TYPE IN ('02','03') THEN F34_VATBS ELSE 0 end+F32_INIBS)" + SUBSTR(cQuery,AT("VAT_T_V1",cQuery,1)+8,len(cQuery))
			cQuery:= SUBSTR(cQuery,1,AT("VAL_T_V1",cQuery,1)-1) + "(CASE WHEN F34_TYPE IN ('01','04') THEN F34_VALUE ELSE 0 end-CASE WHEN F34_TYPE IN ('02','03') THEN F34_VALUE ELSE 0 END+F32_INIBAL)" + SUBSTR(cQuery,AT("VAL_T_V1",cQuery,1)+8,len(cQuery))
		endif
	elseif FWisincallstack("RU09T01INV")
		cQuery:= SUBSTR(cQuery,1,AT("V_F35F2DAT,' ')::character(8)",cQuery,1)-1) + "DATE_PART('day',TO_TIMESTAMP(F35_PDATE,'YYYYMMDD')-TO_TIMESTAMP(F2_DTSAIDA,'YYYYMMDD')),0)::FLOAT8" + SUBSTR(cQuery,AT("V_F35F2DAT,' ')::character(8)",cQuery,1)+29,len(cQuery))
	Endif
	
	cQuery+= " FROM " + RetSqlName(aStdTable[1][1][1]) //+ CRLF

	c2Query:= " SELECT "+ alltrim(aFieldsQuery[FOR_TOTAL])

	If FWisincallstack("RU09T01OVA")
		c2Query+= ",'' as F54_DIRECT"
		c2Query:= SUBSTR(c2Query,1,AT("F54_VALUV1)",c2Query,1)-1) + "F54_VALUE)" + SUBSTR(c2Query,AT("F54_VALUV1)",c2Query,1)+11,len(c2Query))
		c2Query:= SUBSTR(c2Query,1,AT("F54_VATXV1)",c2Query,1)-1) + "F54_VATBS)" + SUBSTR(c2Query,AT("F54_VATXV1)",c2Query,1)+11,len(c2Query))
		c2Query:= SUBSTR(c2Query,1,AT("F54_VALUV2)",c2Query,1)-1) + "F54_VALUE)" + SUBSTR(c2Query,AT("F54_VALUV2)",c2Query,1)+11,len(c2Query))
		c2Query:= SUBSTR(c2Query,1,AT("F54_VATXV2)",c2Query,1)-1) + "F54_VATBS)" + SUBSTR(c2Query,AT("F54_VATXV2)",c2Query,1)+11,len(c2Query))
	elseIf (FWisincallstack("RU09T01IVA") .or. FWisincallstack("RU09T01IVT") /*.or. FWisincallstack("RU09T01NBV")*/)
		//c2Query+= ",'' as F54_DIRECT"
		c2Query:= SUBSTR(c2Query,1,AT("F34_VALUV1)",c2Query,1)-1) + "F34_VALUE)" + SUBSTR(c2Query,AT("F34_VALUV1)",c2Query,1)+11,len(c2Query))
		c2Query:= SUBSTR(c2Query,1,AT("F34_VATXV1)",c2Query,1)-1) + "F34_VATBS)" + SUBSTR(c2Query,AT("F34_VATXV1)",c2Query,1)+11,len(c2Query))
		c2Query:= SUBSTR(c2Query,1,AT("F34_VALUV2)",c2Query,1)-1) + "F34_VALUE)" + SUBSTR(c2Query,AT("F34_VALUV2)",c2Query,1)+11,len(c2Query))
		c2Query:= SUBSTR(c2Query,1,AT("F34_VATXV2)",c2Query,1)-1) + "F34_VATBS)" + SUBSTR(c2Query,AT("F34_VATXV2)",c2Query,1)+11,len(c2Query))
	elseif FWisincallstack("RU09T01INV")
		//c2Query:= SUBSTR(c2Query,1,AT("V_F35F2DAT)",c2Query,1)-1) + "V_F35F2DAT)" + SUBSTR(c2Query,AT("V_F35F2DAT)",c2Query,1)+11,len(c2Query))
	Endif

	c2Query+= " FROM " + RetSqlName(aStdTable[1][1][1]) //+ CRLF

If len(aStdTable[1])>=2// If len(aStdTable)>=2

	For nX:=1 to Len(aStdTable)
		cQuery+= " LEFT JOIN " + RetSqlName(aStdTable[nX][2][1])
		c2Query+= " LEFT JOIN " + RetSqlName(aStdTable[nX][2][1])

		For nX2:=2 to len(aStdTable[nX][1])
			If nX2==2
 				cQuery+= " ON " + aStdTable[nX][1][nX2] + " = " + aStdTable[nX][2][nX2]
				c2Query+= " ON " + aStdTable[nX][1][nX2] + " = " + aStdTable[nX][2][nX2]
			Else
				cQuery+= " AND " + aStdTable[nX][1][nX2] + " = " + aStdTable[nX][2][nX2] //+ CRLF
				c2Query+= " AND " + aStdTable[nX][1][nX2] + " = " + aStdTable[nX][2][nX2] //+ CRLF
			Endif
		Next nX2
		cQuery+= " AND " + RetSqlName(aStdTable[nX][2][1]) + ".D_E_L_E_T_ = ' '" //+ CRLF
		c2Query+= " AND " + RetSqlName(aStdTable[nX][2][1]) + ".D_E_L_E_T_ = ' '" //+ CRLF
	Next
Endif

	If Empty(cWhere)
		cWhere += " WHERE " + aFilter1[1] + " IN (" + cFilials + ") " //+ CRLF 

		for nX:=1 to len(aMVparFields)
			If nX!=len(aMVparFields) .and. aMVparFields[nX][1]==aMVparFields[nX+1][1]
				cWhere += " AND " +  aMVparFields[nX][1]
				cWhere += " BETWEEN '" + &(aMVparFields[nX][2]) + "' AND '" + &(aMVparFields[nX+1][2]) + "'" //+ CRLF
				nX+=1
			Else
				If !Empty( &(aMVparFields[nX][2]) )
					if FwIsInCallStack("RU09T01PUR") .or. FwIsInCallStack("RU09T01SAL") .or. FwIsInCallStack("RU09T01INV") .or. FwIsInCallStack("RU09T01IVA") .or. FwIsInCallStack("RU09T01OVA") .or. FwIsInCallStack("RU09T01IVT") .or. FwIsInCallStack("RU09T01NBV")
						If nX==3
							If aMvPar[3]==1
								cWhere += " AND " + aMVparFields[nX][1] + " != ''"
							Elseif aMvPar[3]==2
								cWhere += " AND " + aMVparFields[nX][1] + " IS NULL"
							Else
							Endif
						Else
							cWhere += " AND " + aMVparFields[nX][1] + " IN ("+ &( aMVparFields[nX][2] ) +")" //+ CRLF
						Endif
					Else
						cWhere += " AND " + aMVparFields[nX][1] + " IN ("+ &( aMVparFields[nX][2] ) +")" //+ CRLF
					Endif
				Endif
			Endif
		Next
		
		if FWisincallstack("RU09T01INV")
			if aMvPar[7]==1
				cWhere += "AND (COALESCE(DATE_PART('DAY',TO_TIMESTAMP(F35_PDATE,'YYYYMMDD')-TO_TIMESTAMP(F2_DTSAIDA,'YYYYMMDD')),0) AS FLOAT8)>=4"
			elseif aMvPar[7]==2
				cWhere += "AND (COALESCE(DATE_PART('DAY',TO_TIMESTAMP(F35_PDATE,'YYYYMMDD')-TO_TIMESTAMP(F2_DTSAIDA,'YYYYMMDD')),0) AS FLOAT8)<4"
			endif
		endif

		cWhere += " AND " + RetSqlName(aStdTable[1][1][1]) + ".D_E_L_E_T_ = ' '" //+ CRLF

		If !Empty(cFilter)
			cWhere += ' AND '+cFilter //+ CRLF
		Endif
	Endif

	cQuery += cWhere
	c2Query+= cWhere

	cFAGroupSN:= alltrim(FAGroupSN4())
	If lGroup .and. !empty(cFAGroupSN)
		cQuery += " GROUP BY "+ cFAGroupSN //+ CRLF
	Endif

	If !Empty(cQLPorder)
		cQuery += " ORDER BY " + cQLPorder
	Endif

Else
	HELP(" ",1,STR0019+aStdTable[1][1][1]+STR0020)
Endif

cQuery:= changequery(cQuery)
//main query 
 If select(cSN4TmpAlias)>0
	(cSN4TmpAlias)->(dbCloseArea())
	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQuery) , cSN4TmpAlias ,.T.,.F.)
else
	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQuery) , cSN4TmpAlias ,.T.,.F.)
endif
//total query
c2Query:= changequery(c2Query)
If select(cSN4Tmp2Alias)>0
	(cSN4Tmp2Alias)->(dbCloseArea())
	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, c2Query) , cSN4Tmp2Alias ,.T.,.F.)
else
	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, c2Query) , cSN4Tmp2Alias ,.T.,.F.)
endif

Return 

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description: controls the order of the data in the array which is used to sort
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function RuQLPOrder(nNx as numeric)

Local aOrder2 as array
Local lhaveit as Logical
Local cOrd1 as character
Local nX as numeric
Local n1Xx as numeric
Local nNumbOrd as numeric

Default nNx:= 0
Default cSeleField:='  '
Default lGroup:=.F.

cOrd1:=""
nNumbOrd:=0
aOrder2:={{"",.F.},{"",.F.},{"",.F.},{"",.F.},{"",.F.},{"",.F.}}
lhaveit:=.F.

If nNx!=0
	cQLPorder:=aMarked[nNx][FIELDNAME_POS]

	//get number of field in order how choised in argument of function
	For nX:=1 to len(aOrder1)
		If Alltrim(aMarked[nNx][FIELDNAME_POS])==Alltrim(aOrder1[nX][FIELD_ORD])
			nNumbOrd:=nX
			nX:=len(aOrder1)
		Endif
	Next nX

	If nNumbOrd!=0
		If aOrder1[nNumbOrd][ORDER_ORD]==.F.
			aOrder1[nNumbOrd][ORDER_ORD]:=.T.
		else
			aOrder1[nNumbOrd][ORDER_ORD]:=.F.
			cSeleField:=cQLPorder
		Endif
	Endif
	
	//coppy for bacup in feature
	For nX:=1 to len(aOrder1)
		aOrder2[nX][FIELD_ORD]:=aOrder1[nX][FIELD_ORD]
		aOrder2[nX][ORDER_ORD]:=aOrder1[nX][ORDER_ORD]
	Next nX

	//movieng field with priority
	For nX:=1 to len(aOrder1)
		If alltrim(aOrder1[nX][FIELD_ORD])==Alltrim(aMarked[nNx][FIELDNAME_POS])
			lhaveit:=.T.
			n1Xx:=nX
			//move to down and write new on 1 plase
			while n1Xx!=0
				If n1Xx>=2
					//move it to down
					aOrder1[n1Xx][FIELD_ORD]:=aOrder1[n1Xx-1][FIELD_ORD]
					aOrder1[n1Xx][ORDER_ORD]:=aOrder1[n1Xx-1][ORDER_ORD]
				else
					//wright current on first plase
					aOrder1[1][FIELD_ORD]:=aMarked[nNx][FIELDNAME_POS]
					aOrder1[1][ORDER_ORD]:=aOrder2[nX][ORDER_ORD]
				Endif
				n1Xx:=n1Xx-1
			EndDo
		Elseif nX==len(aOrder1) .and. !lhaveit
			//movie all to down
			For n1Xx:=2 to len(aOrder1)
				aOrder1[n1Xx][FIELD_ORD]:=aOrder2[n1Xx-1][FIELD_ORD]
				aOrder1[n1Xx][ORDER_ORD]:=aOrder2[n1Xx-1][ORDER_ORD] 
			Next n1Xx
			//wright new on first plase
			aOrder1[1][FIELD_ORD]:=aMarked[nNx][FIELDNAME_POS]
			aOrder1[1][ORDER_ORD]:=.F.
		Endif
	Next nX

	ChPictForButtons()
Endif

//create order character for query
For nX:=1 to len(aOrder1)
	For n1Xx:=1 to len(aMarked)
		If Alltrim(aMarked[n1Xx][FIELDNAME_POS])==Alltrim(aOrder1[nX][FIELD_ORD])
			If !empty(cOrd1)
				cOrd1:= cOrd1+ ", " + alltrim(aOrder1[nX][FIELD_ORD]) + (IIF((aOrder1[nX][ORDER_ORD]),' ASC', ' DESC'))
			else
				cOrd1:= alltrim(aOrder1[nX][FIELD_ORD]) + (IIF((aOrder1[nX][ORDER_ORD]),' ASC', ' DESC'))
			Endif
			n1Xx:=len(aMarked)
		Endif
	Next n1Xx
Next nX
cQLPorder:=cOrd1

GetFAInformation( aMAliases , (ArrToStr( a2Marked , ',' , lGroup, aMarked )) ,,lGroup)
 
return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description: controls the state of the buttons according to the sort order.
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function ChPictForButtons()
Local nX1 as numeric
Local nX2 as numeric

//change picture for all buttons
For nX1:=1 to len(aMarked)

If aModColor==nil 
	oBrowse:SetHeaderImage(nX1,"VCRIGHT") //make all buttons "VCRIGHT"
	For nX2:=1 to len(aOrder1)
		If Alltrim(aMarked[nX1][FIELDNAME_POS])==Alltrim(aOrder1[nX2][FIELD_ORD])
			oBrowse:SetHeaderImage(nX1,(IIF((aOrder1[nX2][ORDER_ORD]),'VCUP','VCDOWN'))) //make to "UP" or "DOWN" (aMarked)buttons how exist in aOrder1
			nX2:=len(aOrder1)
		Endif
	Next nX2
Elseif !lGroup
	oBrowse:SetHeaderImage(nX1+1,"VCRIGHT") //make all buttons "VCRIGHT"
	For nX2:=1 to len(aOrder1)
		If Alltrim(aMarked[nX1][FIELDNAME_POS])==Alltrim(aOrder1[nX2][FIELD_ORD])
			oBrowse:SetHeaderImage(nX1+1,(IIF((aOrder1[nX2][ORDER_ORD]),'VCUP','VCDOWN'))) //make to "UP" or "DOWN" (aMarked)buttons how exist in aOrder1
			nX2:=len(aOrder1)
		Endif
	Next nX2
Else
	oBrowse:SetHeaderImage(nX1,"VCRIGHT") //make all buttons "VCRIGHT"
	For nX2:=1 to len(aOrder1)
		If Alltrim(aMarked[nX1][FIELDNAME_POS])==Alltrim(aOrder1[nX2][FIELD_ORD])
			oBrowse:SetHeaderImage(nX1,(IIF((aOrder1[nX2][ORDER_ORD]),'VCUP','VCDOWN'))) //make to "UP" or "DOWN" (aMarked)buttons how exist in aOrder1
			nX2:=len(aOrder1)
		Endif
	Next nX2
endif

Next nX1

return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description Get GROUP for main QUERY
@Return Character
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function FAGroupSN4()

Local cGroup as character
Local cFieldName as character
Local nCount as numeric
Local nX as numeric
Local cModGroup as character

cGroup := ""

For nCount:=1  to len(aMarked)
	cFieldName := aMarked[nCount][FIELDNAME_POS]
	If !( aMarked[nCount][TYPE_POS] $ 'M|L|N' ) .and. cFieldName <> 'N4DESC'
		If nCount > 1 .and. nCount <= Len(aMarked) .and. !empty(cGroup)
			cGroup += ','
		Endif
		cGroup += Alltrim(aMarked[nCount][FIELDNAME_POS])
	Endif
Next nCount

cModGroup:=StrTran(cGroup,",","|")

If aTrigGroup!=Nil
	For nX:=1 to len(aTrigGroup) 
		If !(aTrigGroup[nX] $ cModGroup)
			cGroup += "," + aTrigGroup[nX]
		endif
	Next nX
Endif

Return cGroup

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description Function that create and display main screen
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function Build_Screen()

Local oSay 		as object
Local aSizes	as array
Local aStruc	as array
Local lOk 		as Logical
Local nX 		as numeric
Local nX2 		as numeric
Local nX3 		as numeric
Local cMacrS1 	as character
Local cCadastro	as character
Local aButtons as array
Local aCode as array
local cTemp1 as character

aSizes	:= FWGetDialogSize( oMainWnd )
aStruc := {}
aCode := {}
cCadastro	:= STR0005

Define MsDialog o3MainDlg Title cCadastro From aSizes[1], aSizes[2] To aSizes[3], aSizes[4] Pixel

	oTFont := TFont():New('Courier new',,16,.T.)

	//position first window in main window (with data)
	oPanel1:= tPanel():Create(o3MainDlg,28,0,"",oTFont,.T.,,,,round(aSizes[4]*0.495,0),round(aSizes[3]*0.462,0)-28) 
	oPanel1:Align := CONTROL_ALIGN_ALLCLIENT // corecting position for 2 windows 

	//position second window in main window (with TOTAL)  
	oPanel2:= tPanel():Create(o3MainDlg,round(aSizes[3]*0.493,0)-28,0,"",oTFont,.F.,,,,round(aSizes[4]*0.495,0),28)
	oPanel2:Align := CONTROL_ALIGN_BOTTOM // corecting position for 2 windows

	//Get structure from aMarked
	For nX := 1 To Len(aMarked)
		If aMarked[nX][FIELDNAME_POS] == 'N4DESC'
			aadd( aStruc, { aMarked[nX][TEXT_POS] , &("{ || " + aMarked[nX][FIELDNAME_POS] + " }") ,  aMarked[nX][TYPE_POS], '', 0, aMarked[nX][SIZE_POS] , aMarked[nX][DECIMAL_POS],,,,,,,,,,alltrim(aMarked[nX][FIELDNAME_POS])})	
		Elseif FwisincallStack("RU09T01OVA") .and. aMarked[nX][FIELDNAME_POS] $ "F54_VALUV1|F54_VATXV1|F54_VALUV2|F54_VATXV2|"
			aadd( aStruc, { Alltrim(aMarked[nX][TEXT_POS]),;
			IIF(aMarked[nX][FIELDNAME_POS] $ "F54_VALUV1|F54_VATXV1|",&("{ || IIF(F54_DIRECT=='+',"+aMarked[nX][FIELDNAME_POS]+",nil) }"),&("{ || IIF(F54_DIRECT=='-',"+aMarked[nX][FIELDNAME_POS]+",nil) }")),;
			aMarked[nX][TYPE_POS],;
			IIF(aMarked[nX][TYPE_POS]=="D","   ","@E 9,999,999,999,999.99"),;
			IIF(aMarked[nX][TYPE_POS]=="C", "LEFT",IIF(aMarked[nX][TYPE_POS]=="N","RIGHT" , 0 )),;
			aMarked[nX][SIZE_POS] ,;
			aMarked[nX][DECIMAL_POS],,,,,,,,,,Alltrim(aMarked[nX][FIELDNAME_POS])})

		Elseif (FwisincallStack("RU09T01IVA") .or. FwisincallStack("RU09T01IVT")/* .or. FwisincallStack("RU09T01NBV")*/) .and. aMarked[nX][FIELDNAME_POS] $ "F34_VALUV1|F34_VATXV1|F34_VALUV2|F34_VATXV2|"
			aadd( aStruc, { Alltrim(aMarked[nX][TEXT_POS]),;
			IIF(aMarked[nX][FIELDNAME_POS] $ "F34_VALUV1|F34_VATXV1|",&("{ || IIF((F34_TYPE=='01' .or. F34_TYPE=='04'),"+aMarked[nX][FIELDNAME_POS]+",nil) }"),&("{ || IIF((F34_TYPE=='02' .or. F34_TYPE=='03'),"+aMarked[nX][FIELDNAME_POS]+",nil) }")),;
			aMarked[nX][TYPE_POS],;
			IIF(aMarked[nX][TYPE_POS]=="D","   ","@E 9,999,999,999,999.99"),;
			IIF(aMarked[nX][TYPE_POS]=="C", "LEFT",IIF(aMarked[nX][TYPE_POS]=="N","RIGHT" , 0 )),;
			aMarked[nX][SIZE_POS] ,;
			aMarked[nX][DECIMAL_POS],,,,,,,/*15*/,,,Alltrim(aMarked[nX][FIELDNAME_POS])})

		Elseif FwisincallStack("RU09T01IVT") .and. alltrim(aMarked[nX][FIELDNAME_POS]) == "F34_TYPE" //need for rule insight browse (for example: F34_TYPE=='01' .or. F34_TYPE=='04')
			
			aadd( aStruc, { Alltrim(aMarked[nX][TEXT_POS]),;
			&("{ || " + aMarked[nX][FIELDNAME_POS] + " }") ,;
			aMarked[nX][TYPE_POS],;
			IIF(aMarked[nX][TYPE_POS]=="D","   ",GetSx3Cache( aMarked[nX][FIELDNAME_POS] , "x3_picture" )),;
			IIF(aMarked[nX][TYPE_POS]=="C", "LEFT",IIF(aMarked[nX][TYPE_POS]=="N","RIGHT" , 0 )),;
			aMarked[nX][SIZE_POS] ,;
			aMarked[nX][DECIMAL_POS],,,,,,,.T.,,,Alltrim(aMarked[nX][FIELDNAME_POS])})

		else
			aadd( aStruc, { Alltrim(RetTitle(aMarked[nX][FIELDNAME_POS])),;
			&("{ || " + aMarked[nX][FIELDNAME_POS] + " }") ,;
			aMarked[nX][TYPE_POS],;
			IIF(aMarked[nX][TYPE_POS]=="D","   ",GetSx3Cache( aMarked[nX][FIELDNAME_POS] , "x3_picture" )),;
			IIF(aMarked[nX][TYPE_POS]=="C", "LEFT",IIF(aMarked[nX][TYPE_POS]=="N","RIGHT" , 0 )),;
			aMarked[nX][SIZE_POS] ,;
			aMarked[nX][DECIMAL_POS],,,,,,,,,,Alltrim(aMarked[nX][FIELDNAME_POS])})
		Endif
	Next nX

	aCode:= GetListArr(aCodeBloc)
	aBCMacr:={}
	If lGroup
		cMacrS1:='' 
		For nX:=1 to len(a3Marked)
			If empty(cMacrS1)
				cMacrS1:= "{ (cSN4TmpAlias)->(" + alltrim(a3Marked[nX][FIELDNAME_POS]) + ")"
			else
				cMacrS1+= " , " + "(cSN4TmpAlias)->(" + alltrim(a3Marked[nX][FIELDNAME_POS]) + ")"
			endif
		Next nX
		cMacrS1+= " }"

		For nX:=1 to len(aCode)
			AADD(aBCMacr,"{ || R01MovLine(oBrowse:at()), BSecondWin(a3Marked,"+ cMacrS1 +"," + str(nX) + ") }" )
		Next nX 

	else
		cMacrS1:=''
		For nX:=1 to len(a2Marked)
			If empty(cMacrS1)
				cMacrS1:= "{ (cSN4TmpAlias)->(" + alltrim(a2Marked[nX][FIELDNAME_POS]) + ")"
			else
				cMacrS1+= " , " + "(cSN4TmpAlias)->(" + alltrim(a2Marked[nX][FIELDNAME_POS]) + ")"
			endif
		Next nX
		cMacrS1+= " }"
		
		For nX:=1 to len(aCode)
			AADD(aBCMacr,"{ || R01MovLine(oBrowse:at()), BSecondWin(a2Marked,"+ cMacrS1 +"," + str(nX) + ") }" )
		Next nX 

	endif

	oBrowse:=FWFormBrowse():New()
	oBrowse:SetDetails(.F.)
	oBrowse:SetDataQuery()
	oBrowse:SetAlias(cRutine+"TEMP")

		//Creating filter if not created
	If Type("oFWFilter")=='U'
		oFWFilter := FWFilter():New(oBrowse)
		oFWFilter:SetOwner(oBrowse)
		oFWFilter:SetSQLFilter()
		oFWFilter:DisableValid()
		oFWFilter:SetProfileID(cRutine+"FIL")
		oFWFilter:LoadFilter()
		oFWFilter:SetCleanFilter( {|| cFilter := ''} )
		oFWFilter:SetExecute({|| cFilter := FAGetFilters()  } )
	Endif
	oFWFilter:SetField(aMFiltStr)
	cFilter:= FAGetFilters() //get cuted SQL reguest from filter

	RuQLPOrder()//Sort and get query (private variable) also RuQLPOrder returning cDescr for SetDescription method.
	oBrowse:SetDescription(cDescr)

	oBrowse:SetFixedDetails(.T.)

	If !lGroup
		//Legend
		if aModColor!=Nil
			For nX:=1 to len(aModColor)
				IF FwIsInCallStack('RU09T01INV')
					oBrowse:AddLegend( "V_F35F2DAT>=4", aModColor[nX][2], aModColor[nX][3])// V_F35F2DAT oBrowse:AddLegend( "(STOD(F35_PDATE)-STOD(F2_DTSAIDA))>=4", aModColor[nX][2], aModColor[nX][3])
				else
					oBrowse:AddLegend( "Alltrim("+aModColor[nX][1]+")"+" == ''", aModColor[nX][2], aModColor[nX][3])
				endif
			Next nX
		Endif
	Endif

	oBrowse:SetColumns(aStruc)
	oBrowse:SetQuery(cQuery) 

	oBrowse:SetOwner(oPanel1)
	oBrowse:DisableReport()
	oBrowse:SetDoubleClick(&(aBCMacr[1]))
	oBrowse:AddButton(STR0025, { || FAOpenFilter(), GetFAInformation( aMAliases , (ArrToStr( a2Marked , ',' , lGroup, aMarked )) ,,lGroup) , BrRefresh() })//Filter button

	For nX:=1 to Len(aMarked)
		If aModColor==Nil
			bS3Macr := &("{ || RuQLPOrder("+alltrim(str(nX))+") , BrRefresh() }" ) 
			oBrowse:aColumns[nX]:SetHeaderClick( bS3Macr )
		Else
			if !lGroup
				if nX==1
					bS3Macr := {|| BrRefresh()}
					oBrowse:aColumns[nX]:SetHeaderClick( bS3Macr )
				Else
					bS3Macr := &("{ || RuQLPOrder("+alltrim(str(nX-1))+") , BrRefresh() }" ) 
					oBrowse:aColumns[nX]:SetHeaderClick( bS3Macr )

					bS3Macr := &("{ || RuQLPOrder("+alltrim(str(nX))+") , BrRefresh() }" ) 
					oBrowse:aColumns[nX+1]:SetHeaderClick( bS3Macr )
				Endif
			Else
				bS3Macr := &("{ || RuQLPOrder("+alltrim(str(nX))+") , BrRefresh() }" ) 
				oBrowse:aColumns[nX]:SetHeaderClick( bS3Macr )
			Endif
		Endif

	Next nX

	oBrowse:Activate()
	oBrowse:oBrowse:bKeyBlock := { || ScrollGo() }
	oBrowse:oBrowse:NHSCROLL := 0
	oBrowse:Refresh()
	oBrowse:oBrowse:Refresh()

	ChPictForButtons() //changing pictures for header of column

	otBrowse:=FWFormBrowse():New()
	otBrowse:SetDetails(.F.)
	otBrowse:SetDataQuery()
	otBrowse:SetAlias(CriaTrab(,.F.))

	If !lGroup
		//Legend
		if aModColor!=Nil
			otBrowse:AddColumn({"   ",{||},"C",,0,3,,})
		Endif
	Endif

	For nX:=1 to len(aStruc)
		If nX==1
			aStruc[nX][FIELDNAME_POS]:=PadR(STR0001, len(aStruc[nX][FIELDNAME_POS]), " ") //total
		Else
			aStruc[nX][FIELDNAME_POS]:=PadR("", len(aStruc[nX][FIELDNAME_POS]), " ")
		Endif
		aStruc[nx][2]
	Next nX

	otBrowse:SetQuery(c2Query)
	otBrowse:SetColumns(aStruc)
	otBrowse:SetOwner(oPanel2)
	otBrowse:DisableReport()
	otBrowse:SetVScroll(.F.)
	otBrowse:Activate()

	otBrowse:oBrowse:NHSCROLL := 1
	otBrowse:Refresh()
	aButtons:={}
	cTemp1:=""
	For nX:=1 to len(aButtons1)
		If SUBSTR(aButtons1[nX][2],1,8)=="aBCMacr["
			cTemp1:=&(aButtons1[nX][2])
			AADD(aButtons,{aButtons1[nX][1], &(cTemp1), aButtons1[nX][3], aButtons1[nX][4]})
		Else
			AADD(aButtons,{aButtons1[nX][1], &(aButtons1[nX][2]), aButtons1[nX][3], aButtons1[nX][4]})
		Endif
	Next

Activate MsDialog o3MainDlg ON INIT (EnchoiceBar(o3MainDlg,{||lOk:=.T.,o3MainDlg:End()},{||o3MainDlg:End()},,;
	aButtons ,,,.F.,.T.,.F.,.F.,.F.)) CENTERED
	
Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/23-11-2018
@Description Movieng Scroll on Total (if any key was pressed)
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function ScrollGo()
local nPosCol as numeric

nPosCol:=oBrowse:oBrowse:ColPos()//get number of column
otBrowse:SetFocus()
otBrowse:oBrowse:GoColumn(nPosCol)
oBrowse:SetFocus()

Return
/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description get source Accounting Entries
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function RU01R01ACE(cAlFor2Br as character)
Local oModel	as object
Local lRet		as Logical
Local cOcorr	as character
Local cAliHead	as character
Local cAliDet	as character
Local nIndHead	as numeric
Local nIndDet	as numeric

lRet	:= .T.
oModel  := FwModelActive()		
If ValType(oModel) <> 'O'
	oModel	:= FwLoadModel("RU01S01")
EndIf

If (cAlFor2Br)->(FieldPos('N4_OCORR')) > 0
	cOcorr:= (cAlFor2Br)->(N4_OCORR)
Endif

Do Case
Case	cOcorr == "61"	
	cAliHead	:=	"F4Q"
	nIndHead	:=	1
	cAliDet		:=	"F4R"
	nIndDet		:=	1
Case	cOcorr == "62"	
	cAliHead	:=	"F4U"
	nIndHead	:=	1
	cAliDet		:=	"F4V"
	nIndDet		:=	1
Case	cOcorr == "63"	
	cAliHead	:=	"F4S"
	nIndHead	:=	1
	cAliDet		:=	"F4T"
	nIndDet		:=	1
Otherwise
	lRet		:= .F.
EndCase
If lRet
	cSeek := (cAlFor2Br)->(N4_CBASE+N4_ITEM+N4_TIPO+N4_OCORR)
	dbSelectArea("SN4")
	SN4->(dbSetOrder(4))
	SN4->(dbSeek(xFilial("SN4") + cSeek))
	cCode	:= 	SN4->(N4_ORIUID)

	RU01S02RUS(cAliHead,cAliDet,nIndHead,nIndDet,.T., Iif(lRet,cCode,Nil) )
Else
	Help(" ",1,STR0017)	//"Accounting Entries are not exist"
EndIf

return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description Refresh for oBrowse
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function BrRefresh()
 
oBrowse:SetQuery(cQuery)
otBrowse:SetQuery(c2Query)
oBrowse:ExecuteFilter()
oBrowse:refresh()
otBrowse:refresh()

return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description Function for action restart
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function FAUpdatedata(lShowPergunte as Logical , lGroup as Logical )
local aArea as array
local aAuxArea as array

Default lShowPergunte := .T.



Pergunte(cPerg,lShowPergunte)

if FwIsInCallStack("RU09T01INV")
	If MV_PAR01!=Nil
		aMvPar[1]:=MV_PAR01
	endif
	If MV_PAR02!=Nil
		aMvPar[2]:=MV_PAR02
	endif
	If MV_PAR03!=Nil
		aMvPar[3]:=MV_PAR03
	endif
	If MV_PAR05!=Nil
		aMvPar[7]:=MV_PAR05
	endif
	If MV_PAR06!=Nil
		aMvPar[6]:=MV_PAR04
	endif
elseIf !(FwIsInCallStack("RU09T01SAL") .or. FwIsInCallStack("RU09T01PUR") .or. FwIsInCallStack("RU09T01IVA") .or. FwIsInCallStack("RU09T01OVA") .or. FwIsInCallStack("RU09T01IVT") )

	If MV_PAR01!=Nil
		aMvPar[1]:=MV_PAR01
	endif

	If MV_PAR02!=Nil
		aMvPar[2]:=MV_PAR02
	endif

	If MV_PAR03!=Nil
		aMvPar[3]:=MV_PAR03
	endif

	If MV_PAR04!=Nil
		aMvPar[4]:=MV_PAR04
	endif

	If MV_PAR05!=Nil
		aMvPar[5]:=MV_PAR05
	endif

	If MV_PAR06!=Nil
		aMvPar[6]:=MV_PAR06
	endif

else

	If MV_PAR01!=Nil
		aMvPar[1]:=MV_PAR01
	endif

	If MV_PAR02!=Nil
		aMvPar[2]:=MV_PAR02
	endif

	If MV_PAR03!=Nil
		aMvPar[3]:=MV_PAR03
	endif

	If MV_PAR06!=Nil
		aMvPar[6]:=MV_PAR04
	endif

endif

if lShowPergunte
	aArea := SM0->( GetArea() )
	aAuxArea := GetArea()
	aSelFil := {}
	If aMvPar[6]== 1	// Filter by branches  
		aSelFil := AdmGetFil()
	Elseif aMvPar[6]==3
		DbSelectArea( "SM0" )
		SM0->( DbGoTop() )
		DbSeek(cEmpAnt)
		While SM0->( !Eof() ) .AND. SM0->M0_CODIGO = cEmpAnt
    		AAdd( aSelFil, SM0->M0_CODFIL )
     		SM0->(DbSkip()) 
		EndDo
		RestArea( aArea )
		RestArea( aAuxArea )
	else

	EndIf
Endif


RestartBrow()

Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description close old main window and run Build_Screen
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function RestartBrow()

o3MainDlg:End()
o3MainDlg:=NIL
Build_Screen()

Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description get parts for Main QUERY and for total QUERY.
@Return array with fields for Query constructor
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function ArrToStr( aGetFields as array, cSep as character , lGroup as Logical, a2GetFields as array)

Local aReturn as array 
Local nCount as numeric

aReturn:={"",""}

nCount := 0 
If lGroup
	For nCount:=1 to Len(a2GetFields)
		If a2GetFields[nCount][FIELDNAME_POS]  <> 'N4DESC'
			If a2GetFields[nCount][6]==aMAliases[1][1][1] .and. a2GetFields[nCount][TYPE_POS] $ 'C|D'
				aReturn[FOR_QUERY] += If( nCount > 1 , cSep , "" ) +alltrim(a2GetFields[nCount][FIELDNAME_POS])
			Elseif  a2GetFields[nCount][6]==aMAliases[1][1][1] .and. a2GetFields[nCount][TYPE_POS] == 'N'
				aReturn[FOR_QUERY] += If( nCount > 1 , cSep , "" ) + "SUM("+ alltrim(a2GetFields[nCount][FIELDNAME_POS])+") AS "+a2GetFields[nCount][FIELDNAME_POS]
			Elseif a2GetFields[nCount][6]!=aMAliases[1][1][1] .and. a2GetFields[nCount][TYPE_POS] $ 'C|D'
				aReturn[FOR_QUERY] += If( nCount > 1 , cSep , "" ) + "CAST((COALESCE(" +alltrim(a2GetFields[nCount][FIELDNAME_POS]) +",' ')) AS CHAR("+Alltrim(STR(a2GetFields[nCount][SIZE_POS]))+")) AS " + alltrim(a2GetFields[nCount][FIELDNAME_POS])
			Elseif a2GetFields[nCount][6]!=aMAliases[1][1][1] .and. a2GetFields[nCount][TYPE_POS] == 'N'
				aReturn[FOR_QUERY] += If( nCount > 1 , cSep , "" ) + "COALESCE(SUM("+ alltrim(a2GetFields[nCount][FIELDNAME_POS])+"),0) AS "+a2GetFields[nCount][FIELDNAME_POS]
			Elseif a2GetFields[nCount][6]!=aMAliases[1][1][1]
				aReturn[FOR_QUERY] += If( nCount > 1 , cSep , "" ) + alltrim(a2GetFields[nCount][FIELDNAME_POS])
			Endif
		Endif
	Next
Else
	For nCount:=1 to Len(aGetFields)
		If aGetFields[nCount][FIELDNAME_POS]  <> 'N4DESC'
			If aGetFields[nCount][6]==aMAliases[1][1][1]
				aReturn[FOR_QUERY] += If( nCount > 1 , cSep , "" ) +alltrim(aGetFields[nCount][FIELDNAME_POS])
			Else
				if Alltrim(aGetFields[nCount][FIELDNAME_POS]) $ cDefField .or. Alltrim(aGetFields[nCount][FIELDNAME_POS]) $ c2DefField
					if aGetFields[nCount][6]!=aMAliases[1][1][1] .and. aGetFields[nCount][TYPE_POS] $ 'C|D'
						aReturn[FOR_QUERY] += If( nCount > 1 , cSep , "" ) + "CAST((COALESCE(" +alltrim(aGetFields[nCount][FIELDNAME_POS]) +",' ')) AS CHAR("+Alltrim(STR(aGetFields[nCount][SIZE_POS]))+")) AS " + alltrim(aGetFields[nCount][FIELDNAME_POS])
					Elseif aGetFields[nCount][6]!=aMAliases[1][1][1] .and. aGetFields[nCount][TYPE_POS] == 'N'
						aReturn[FOR_QUERY] += If( nCount > 1 , cSep , "" ) + "COALESCE(" +alltrim(aGetFields[nCount][FIELDNAME_POS]) +", 0 ) AS " + alltrim(aGetFields[nCount][FIELDNAME_POS])
					Elseif aGetFields[nCount][6]!=aMAliases[1][1][1]
						aReturn[FOR_QUERY] += If( nCount > 1 , cSep , "" ) +alltrim(aGetFields[nCount][FIELDNAME_POS])
					Endif
				Endif
			Endif
		Endif
	Next
Endif

For nCount:=1 to Len(a2GetFields)
	If a2GetFields[nCount][TYPE_POS] == 'C'
		aReturn[FOR_TOTAL] += If( nCount > 1 , cSep , "" ) + "' ' " + alltrim(a2GetFields[nCount][FIELDNAME_POS])
	Elseif a2GetFields[nCount][TYPE_POS] == 'N'
		aReturn[FOR_TOTAL] += If( nCount > 1 , cSep , "" ) + "COALESCE(SUM("+ alltrim(a2GetFields[nCount][FIELDNAME_POS])+"),0) as "+alltrim(a2GetFields[nCount][FIELDNAME_POS])
	Elseif !( a2GetFields[nCount][TYPE_POS] $ 'M|L|')
		aReturn[FOR_TOTAL] += If( nCount > 1 , cSep , "" ) + "' ' " + alltrim(a2GetFields[nCount][FIELDNAME_POS])
	Endif
Next nCount

Return aReturn

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description get clear character
@Return Character
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function FASetInQry( cN4_Occor as character )

Local cInClausule as character
Local cSepare 	as character
Local cTempOccor as character
Local cInOption as character
Local nCount 	as numeric
Local nPosition as numeric
Local nInitPos as numeric

cInClausule	:= ''
cInOption	:= ''
cTempOccor	:= Alltrim(cN4_Occor)
cSepare		:= WhatSepare(cN4_Occor)
nPosition	:= 0
nInitPos	:= 1

For nCount:=1 to Len(cN4_Occor)

	nPosition	:= At( cSepare , cTempOccor )
	If nPosition == 0
		cInOption 	:= SubStr( cN4_Occor , nInitPos )
		cTempOccor	:= ""
	Else
		cInOption 	:= SubStr( cN4_Occor , nInitPos , nPosition-1 )
		cTempOccor	:= SubStr( cTempOccor , nPosition + 1 )
	Endif
	cInClausule += "'" + cInOption + "'"
	nCount 		+= Len(cInOption)
	nInitPos 	:= nCount +1
	
	If  !Empty(cTempOccor)
		cInClausule += ","
	Endif

Next nCount

Return cInClausule

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description window and buttons for change and restructure field by user
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function FAMarkFields()

Local oDlg 	as object
Local oBkupList1 as object
Local oBkupList2 as object
Local oChkBox as object
Local oSay1 as object
Local oSay2 as object
Local oFont as object
Local aButtons as array
Local nList1 as numeric
Local nList2 as numeric
Local nOpc as numeric
Local nButtPos as numeric

Private oList1 as object
Private oList2 as object

nButtPos	:=0
nOpc 		:= 2
aButtons	:= {}

DEFINE DIALOG oDlg TITLE STR0015 FROM 180,180 TO 650,750 PIXEL

	oFont := TFont():New('Courier new',,-18,.T.)
	oSay1:= TSay():New(40,10,{||STR0013},oDlg,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)//selected fields
	oSay2:= TSay():New(40,160,{||STR0014},oDlg,,oFont,,,,.T.,CLR_RED,CLR_WHITE,200,20)//other fields

   	nList1 := 1
	nList2 := 1

	oList1 := TListBox():New(050,007,{|u|If(Pcount()>0,nList1:=u,nList1)},aSelected,120,150,,oDlg,,,,.T.,,{ || FAUPDFields(1,nList1,@oList1,oList2) } )
    oList2 := TListBox():New(050,157,{|u|If(Pcount()>0,nList2:=u,nList2)},aOthersFields,120,150,,oDlg,,,,.T.,,{ || FAUPDFields(2,nList2,@oList1,oList2) } )
	//buttonsZ
	nButtPos:=55
	TButton():New( nButtPos, 132, '//\\', oDlg, { || FAUPDFields(4,nList1,@oList1,oList1) }, 20, 10,,,.F.,.T.,.F.,,.F.,,,.F.)
	nButtPos+=15
	TButton():New( nButtPos, 132, '/\', oDlg, { || FAUPDFields(13,nList1,@oList1,oList1) }, 20, 10,,,.F.,.T.,.F.,,.F.,,,.F.)
	nButtPos+=15
	TButton():New( nButtPos, 132, '\/', oDlg, { || FAUPDFields(14,nList1,@oList1,oList1) }, 20, 10,,,.F.,.T.,.F.,,.F.,,,.F.)
	nButtPos+=15
	TButton():New( nButtPos, 132, '\\//', oDlg, { || FAUPDFields(3,nList1,@oList1,oList1) }, 20, 10,,,.F.,.T.,.F.,,.F.,,,.F.)
	nButtPos+=15
	TButton():New( nButtPos, 132, '<=', oDlg, { || FAUPDFields(22,,		@oList1,oList2) }, 20, 10,,,.F.,.T.,.F.,,.F.,,,.F.)
	nButtPos+=15
	TButton():New( nButtPos, 132, '<-', oDlg, { || FAUPDFields(2,nList2,	@oList1,oList2) }, 20, 10,,,.F.,.T.,.F.,,.F.,,,.F.)
	nButtPos+=15
	TButton():New( nButtPos, 132, '->', oDlg, { || FAUPDFields(1,nList1,	@oList1,oList2) }, 20, 10,,,.F.,.T.,.F.,,.F.,,,.F.)
	nButtPos+=15
	TButton():New( nButtPos, 132, '=>', oDlg, { || FAUPDFields(11,,		@oList1,oList2) }, 20, 10,,,.F.,.T.,.F.,,.F.,,,.F.)

    oBkupList1 := oList1
    oBkupList2 := oList2

	oChkBox := TCHECKBOX():Create(oDlg)
	oChkBox:cName 		:= "oChkBox"
	oChkBox:cCaption 	:= STR0023
	oChkBox:nLeft 		:= 020
	oChkBox:nTop  		:= 425
	oChkBox:nWidth 		:= 100
	oChkBox:nHeight 	:= 030
	oChkBox:lShowHint 	:= .F.
	oChkBox:Align 		:= 0
	oChkBox:cVariable 	:= "lGroup"
	oChkBox:bSetGet 	:= {|u| If(PCount()>0,lGroup:=u,lGroup) }
	oChkBox:lVisibleControl := .T.

ACTIVATE DIALOG oDlg CENTERED ON INIT EnchoiceBar(oDlg,{|| oDlg:end(), nOpc:=1 },{|| FABackupList(oBkupList1, oBkupList2) ,oDlg:end()},,aButtons,,,.F.,.F.,.F.,.T.,.F.)

If nOpc == 1
	FAConfirmFields(.F., lGroup)
Endif

Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description this function changing number of fields between 2 windows
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function FAUPDFields( nOption as numeric , nLine as numeric , oList1 as object , oList2 as object )

Local nCount as numeric
Local cTempA1 as character
local aTempA1 as array

aTempA1:={}
cTempA1:=''

If nOption == 1
	If Len(aSelected)>0 //->
		oList2:Add( aSelected[nLine] )
		oList1:select((nLine-1))
		oList1:Del( nLine )
	Endif
Elseif nOption == 2 //<-
	If Len(aOthersFields)>0
		oList1:Add( aOthersFields[nLine] )
		oList2:select((nLine-1))
		oList2:Del( nLine )
	Endif
Elseif nOption==11
	For nCount:=1 to Len(aSelected)
		oList2:Add( aSelected[1] )
		oList1:Del( 1 )
	Next
Elseif nOption==22
	For nCount:=1 to Len(aOthersFields)
		oList1:Add( aOthersFields[1] )
		oList2:Del( 1 )
	Next
Elseif nOption==13 //   /\
	If nLine!=1 .and. nLine!=0 //  /\ nLine!=0 - for variant when user choised second window and pressed on /\
		cTempA1:= oList1:AITEMS[nLine]  // x:=3
		oList1:Modify((oList1:AITEMS[nLine-1]), nLine) //3:=2
		oList1:select((nLine))
		oList1:Modify(cTempA1, nLine-1)	//
		oList1:select((nLine-1)) //fix for correct plase
	Endif 
Elseif nOption==14
	If nLine!=Len(aSelected) .and. nLine!=0 //  \/ nLine!=0 - for variant when user choise 2window and press on \/ 
		cTempA1 := oList1:AITEMS[nLine] //(5)
		oList1:Modify((oList1:AITEMS[nLine+1]), nLine) //5 := (6)
		oList1:select(nLine) //without this line chosed_line will be not correct.
		oList1:Modify(cTempA1, nLine+1) //6 := (5)
		oList1:select(nLine+1) //without this line chosed_line will be not correct.
	Endif
Elseif nOption==3 // 	\\//

	For nCount:=1 to len(aSelected)	
		AADD(aTempA1,oList1:AITEMS[nCount]) //backup all
	Next nCount

	oList1:Modify((oList1:AITEMS[nLine]), len(oList1:AITEMS)) //end := 3
	oList1:select(nLine)
	for nCount:=nLine to len(aSelected)

		If nCount!=len(oList1:AITEMS)
			oList1:Modify(aTempA1[nCount+1], nCount) //3:=4
			oList1:select(nLine)
		Endif
	Next nCount

Elseif nOption==4 // 	 //\\

	For nCount:=1 to len(aSelected)	
		AADD(aTempA1,oList1:AITEMS[nCount]) //backup all
	Next nCount

	oList1:Modify((oList1:AITEMS[nLine]), 1) //1 := 3
	oList1:select(nLine)
	for nCount:=2 to len(aSelected)
		If nCount!=nLine+1 
			oList1:Modify(aTempA1[nCount-1], nCount) //2:=1
			oList1:select(nLine)
		Else
			nCount:=len(aSelected)
		Endif
	Next nCount

Endif
oList1:refresh()
Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function FABackupList( oBkupList1 as object, oBkupList2 as object )

oList1 := oBkupList1
oList2 := oBkupList2

Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description for button
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function FAConfirmFields(lShowPergunte as Logical, lGroup as Logical)

Local nCount as numeric
Local c1Filter as character
Local cFieldSel as character

Default lShowPergunte := .T.

aFilter2:={}
c1Filter := ''

For nCount:=1 to Len(aSelected)
	cFieldSel 	:= SUBSTR( aSelected[nCount] , 1, 10)
	c1Filter 	+= Alltrim( cFieldSel ) + '|'
	aadd(aFilter2,(Alltrim( cFieldSel )))
Next nCount

BuildArrFields(c1Filter)
FAUpdatedata( lShowPergunte , lGroup )

Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description for supporting Standard-special queries (SX1)
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

Function FAGetMarkOccor() 

Return cMarkOccor

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description for supporting Standard-special queries (SX1)
@Return Object
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

Function GetOccTmpDB()

If Type("OccorTmpDB")<> 'C'
	OccorTmpDB := CriaTrab(,.F.)
Endif

Return OccorTmpDB

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description function for opening source document
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function RUGetATFdo(cAlFor2Br as character)

Local oModelOper	as object
Local oModel		as object
Local aArea			as array
Local aAreaSN4		as array
Local aAreaHead		as array
Local aAreaDet		as array
Local lNotWrtOff	as Logical
Local lRet			as Logical
Local cAliHead		as character
Local cAliDet		as character
Local cNameOper		as character
Local cQuerx		as character
Local cAliasTrb		as character
Local cCode			as character
Local cOcorr		as character
Local nX 			as numeric

Default lNotWrtOff	:= .T.
Default lRet	:= .F.
Default cCode	:= ""

aArea		:= GetArea()
aAreaSN4	:= SN4->(GetArea())
aAreaHead	:= {}
aAreaDet	:= {}

If (cAlFor2Br)->(FieldPos('N4_OCORR')) > 0
	cOcorr:= (cAlFor2Br)->(N4_OCORR)
Endif

Do Case
Case	cOcorr == "61"	
	cNameOper	:=	"RU01T01"
	cAliHead	:=	"F4Q"
	cAliDet		:=	"F4R"
	lRet 		:= .T.
Case	cOcorr == "62"	
	cNameOper	:=	"RU01T03"
	cAliHead	:=	"F4U"
	cAliDet		:=	"F4V"
	lRet 		:= .T.
Case	cOcorr == "63"	
	cNameOper	:=	"RU01T04"
	cAliHead	:=	"F4S"
	cAliDet		:=	"F4T"
	lRet 		:= .T.
EndCase

If lRet
	cSeek := (cAlFor2Br)->(N4_CBASE+N4_ITEM+N4_TIPO+N4_OCORR)
	dbSelectArea("SN4")
	SN4->(dbSetOrder(4))
	SN4->(dbSeek(xFilial("SN4") + cSeek))

	cCode	:= 	SN4->(N4_ORIUID)
	cQuerx		:= "SELECT * FROM " + RetSQLName(cAliDet) + " "+ cAliDet +" WHERE "+ cAliDet + "." + cAliDet + "_UID = '" + cCode + "'"
	cQuerx		:= ChangeQuery(cQuerx)

	cAliasTrb	:= RU01GETALS(cQuerx)
	cKeyDet		:= xFilial(cAliDet) + (cAliasTrb)->&(cAliDet + "_LOT") + (cAliasTrb)->&(cAliDet + "_ITEM")
	(cAliasTrb)->(dbCloseArea())

	DBSelectArea(cAliHead)
	&(cAliDet)->(DBSetOrder(1))
	If &(cAliDet)->(DBSeek(cKeyDet))
		DBSelectArea(cAliHead)
		cKeyMast	:=	 xFilial(cAliHead) + &(cAliDet + "->" + cAliDet + "_LOT")
		&(cAliHead)->(DBSetOrder(1))
		If &(cAliHead)->(DBSeek(cKeyMast))
			lRet := .T.
		Else 
			lRet := .F.
		EndIf
	Else 
		lRet := .F.
	EndIf
EndIf

If lRet
	oModelOper	:= FWLoadModel(cNameOper)
	FwExecView(, cNameOper, MODEL_OPERATION_VIEW,,{|| .T.},,,,,,,oModelOper)//open view of operation
Else
	lRet:=RUFAQ1()
	if !lRet
		Help(" ",1,STR0018)	//"Original document is not exist"
	endif
EndIf

RestArea(aAreaSN4)
RestArea(aArea)

Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description open base document
@Return Logical
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function RUFAQ1() 
Local aArea as Array
Local aAreaSN1 as Array
Local cSeek as character
local l1Ret as Logical
Local cTempKeep as character

cTempKeep:=cFilant
cFilant:=(cAlFor2Br)->(N4_FILIAL)

cSeek:=''

aArea := GetArea()
aAreaSN1 := SN1->(GetArea())
if (cAlFor2Br)->(FieldPos('N4_CBASE')) > 0 .and. !empty((cAlFor2Br)->(N4_CBASE))
	cSeek += cFilant
    cSeek += (cAlFor2Br)->(N4_CBASE)
    if (cAlFor2Br)->(FieldPos('N4_ITEM')) > 0 .and. !empty((cAlFor2Br)->(N4_ITEM))
        cSeek += (cAlFor2Br)->(N4_ITEM)
    EndIf
endif

dbSelectArea("SN1")
SN1->(dbSetOrder(1))
SN1->(DBGoTop())
If SN1->(dbSeek(cSeek))
    if (cAlFor2Br)->(FieldPos('N4_OCORR')) > 0
        if (cAlFor2Br)->(N4_OCORR)=='01'
            FwExecView('', "ATFA036", MODEL_OPERATION_VIEW, , {|| .T.})
			l1Ret:=.T.
        else
            FwExecView('', "ATFA012", MODEL_OPERATION_VIEW, , {|| .T.})
			l1Ret:=.T.
        endif
    else
        FwExecView('', "ATFA012", MODEL_OPERATION_VIEW, , {|| .T.})
		l1Ret:=.T.
    EndIf
Else
    //HELP(" ",1,STR0018)
	l1Ret:=.F.
EndIf

RestArea(aAreaSN1)
RestArea(aArea)
cFilant:=cTempKeep
Return l1Ret

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description move to line which was choisened in window with data
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/


STATIC Function R01MovLine(nNumOfLine as numeric)

Local nX as numeric

If select(cSN4TmpAlias)>0
	(cSN4TmpAlias)->(dbCloseArea())
	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQuery) , cSN4TmpAlias ,.T.,.F.)
else
	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cQuery) , cSN4TmpAlias ,.T.,.F.)
endif

(cSN4TmpAlias)->(dbGoTop())
For nX:=1 to nNumOfLine-1
	(cSN4TmpAlias)->( dbSkip() )
Next nX
 
Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description move to line which was choisened in window with data
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/


STATIC Function R02MovLine(nNumOfLine as numeric)

Local nX as numeric

(cAlFor2Br)->(dbGoTop())
For nX:=1 to nNumOfLine-1
	(cAlFor2Br)->( dbSkip() )
Next nX
 
Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/02-11-2018
@Description
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function BSecondWin(aMFieldsX as array, aDataFromLine as array, ntypeAct as numeric)

Local oPanel 	as object
Local oSay 		as object
Local o2Browse 	as object
Local aFilter3	as array
Local aSizes	as array
Local aStruc	as array
Local aPos2Field, aPos2Text, aPos2Size, aPos2Decimal, aPos2Order, aPos2Type, aPos2Picture, aPos2F3, aPos2Arquivo as array
Local cCadastro	as character
Local cMacrS2 	as character
Local cIniDate 	as character
Local cEndDate 	as character
//Local cIniAsset as character
Local cEndAsset as character
Local cN4_Occor	as character
Local cInOccor	as character
Local nX 		as numeric
Local nX2		as numeric
local a2Buttons as array
Local cCallF as character
local cTemp1 as character
local aCode as array

Private aMark2 as array
Private cAlFor2Br as character

If FWisincallstack("RU09T01INV")
	aMFieldsX:=ADEL(aMFieldsX, ASCAN(aMFieldsX,"V_F35F2DAT"))
	aMFieldsX:=ASIZE(aMFieldsX, len(aMFieldsX)-1)
endif

cIniDate 	:= DtoS(aMvPar[1])
cEndDate 	:= DtoS(aMvPar[2])
//cIniAsset 	:= aMvPar[3]
cEndAsset 	:= aMvPar[4]
cN4_Occor	:= Alltrim( aMvPar[5] )
cInOccor	:= aMvPar[6]

aPos2Field:={}
aPos2Text:={}
aPos2Order:={}
aPos2Type:={}
aPos2Size:={}
aPos2Decimal:={}
aPos2Picture:={}
aPos2F3:={}
aPos2Arquivo:={}
aFilter3:=aDefFields
aStruc := {}
aSizes	:= FWGetDialogSize( oMainWnd )
aMark2:={}
cSelec3:=""
cCadastro:= STR0016
cMacrS2:=''
cAlFor2Br := CriaTrab(,.F.)

nX:=1
dbSelectArea( cAlias4Fields )
(cAlias4Fields)->( dbGoTop() )

For nX:=1 to Len(aTranslation)
	If X3Usado(aTableNameCur[nX]) .and. !(alltrim(aTableNameCur[nX]) $ cExcept) .or. (alltrim(aTableNameCur[nX]) $ cDefField)// checking using fields
	
		If FwisincallStack("RU09T01OVA")

			if alltrim(aTableNameCur[nX]) == "F54_VATBS"

				Aadd(aPos2Field,("F54_VATXV1")) 
				Aadd(aPos2Text,( alltrim(aTranslation[nX])+" + "))
				Aadd(aPos2Size,GetSx3Cache(aTableNameCur[nX],"X3_TAMANHO"))
				Aadd(aPos2Decimal,GetSx3Cache(aTableNameCur[nX],"X3_DECIMAL"))
				Aadd(aPos2Order,GetSx3Cache(aTableNameCur[nX],"X3_ORDEM"))
				Aadd(aPos2Type,GetSx3Cache(aTableNameCur[nX],"X3_TIPO"))
				Aadd(aPos2Picture,GetSx3Cache(aTableNameCur[nX],"X3_PICTURE"))
				Aadd(aPos2F3,GetSx3Cache(aTableNameCur[nX],"X3_F3"))
				Aadd(aPos2Arquivo,GetSx3Cache(aTableNameCur[nX],"X3_ARQUIVO"))

				Aadd(aPos2Field,("F54_VATXV2")) 
				Aadd(aPos2Text,( alltrim(aTranslation[nX])+" - "))
				Aadd(aPos2Size,GetSx3Cache(aTableNameCur[nX],"X3_TAMANHO"))
				Aadd(aPos2Decimal,GetSx3Cache(aTableNameCur[nX],"X3_DECIMAL"))
				Aadd(aPos2Order,GetSx3Cache(aTableNameCur[nX],"X3_ORDEM"))
				Aadd(aPos2Type,GetSx3Cache(aTableNameCur[nX],"X3_TIPO"))
				Aadd(aPos2Picture,GetSx3Cache(aTableNameCur[nX],"X3_PICTURE"))
				Aadd(aPos2F3,GetSx3Cache(aTableNameCur[nX],"X3_F3"))
				Aadd(aPos2Arquivo,GetSx3Cache(aTableNameCur[nX],"X3_ARQUIVO"))
			
			elseif alltrim(aTableNameCur[nX]) == "F54_VALUE"
			
				Aadd(aPos2Field,("F54_VALUV1"))
				Aadd(aPos2Text,( alltrim(aTranslation[nX])+" + "))
				Aadd(aPos2Size,GetSx3Cache(aTableNameCur[nX],"X3_TAMANHO"))
				Aadd(aPos2Decimal,GetSx3Cache(aTableNameCur[nX],"X3_DECIMAL"))
				Aadd(aPos2Order,GetSx3Cache(aTableNameCur[nX],"X3_ORDEM"))
				Aadd(aPos2Type,GetSx3Cache(aTableNameCur[nX],"X3_TIPO"))
				Aadd(aPos2Picture,GetSx3Cache(aTableNameCur[nX],"X3_PICTURE"))
				Aadd(aPos2F3,GetSx3Cache(aTableNameCur[nX],"X3_F3"))
				Aadd(aPos2Arquivo,GetSx3Cache(aTableNameCur[nX],"X3_ARQUIVO"))

				Aadd(aPos2Field,("F54_VALUV2")) 
				Aadd(aPos2Text,(alltrim(aTranslation[nX])+" - "))
				Aadd(aPos2Size,GetSx3Cache(aTableNameCur[nX],"X3_TAMANHO"))
				Aadd(aPos2Decimal,GetSx3Cache(aTableNameCur[nX],"X3_DECIMAL"))
				Aadd(aPos2Order,GetSx3Cache(aTableNameCur[nX],"X3_ORDEM"))
				Aadd(aPos2Type,GetSx3Cache(aTableNameCur[nX],"X3_TIPO"))
				Aadd(aPos2Picture,GetSx3Cache(aTableNameCur[nX],"X3_PICTURE"))
				Aadd(aPos2F3,GetSx3Cache(aTableNameCur[nX],"X3_F3"))
				Aadd(aPos2Arquivo,GetSx3Cache(aTableNameCur[nX],"X3_ARQUIVO"))
			else
				Aadd(aPos2Field,(aTableNameCur[nX]))
				Aadd(aPos2Text,(aTranslation[nX]))
				Aadd(aPos2Size,GetSx3Cache(aTableNameCur[nX],"X3_TAMANHO"))
				Aadd(aPos2Decimal,GetSx3Cache(aTableNameCur[nX],"X3_DECIMAL"))
				Aadd(aPos2Order,GetSx3Cache(aTableNameCur[nX],"X3_ORDEM"))
				Aadd(aPos2Type,GetSx3Cache(aTableNameCur[nX],"X3_TIPO"))
				Aadd(aPos2Picture,GetSx3Cache(aTableNameCur[nX],"X3_PICTURE"))
				Aadd(aPos2F3,GetSx3Cache(aTableNameCur[nX],"X3_F3"))
				Aadd(aPos2Arquivo,GetSx3Cache(aTableNameCur[nX],"X3_ARQUIVO"))
			endif


		elseif (FwisincallStack("RU09T01IVA") .or. FwisincallStack("RU09T01IVT") /*.or. FwisincallStack("RU09T01NBV")*/)//4.3.4
			if alltrim(aTableNameCur[nX]) == "F34_VATBS"

				Aadd(aPos2Field,("F34_VATXV1")) 
				Aadd(aPos2Text,( alltrim(aTranslation[nX])+" + "))
				Aadd(aPos2Size,GetSx3Cache(aTableNameCur[nX],"X3_TAMANHO"))
				Aadd(aPos2Decimal,GetSx3Cache(aTableNameCur[nX],"X3_DECIMAL"))
				Aadd(aPos2Order,GetSx3Cache(aTableNameCur[nX],"X3_ORDEM"))
				Aadd(aPos2Type,GetSx3Cache(aTableNameCur[nX],"X3_TIPO"))
				Aadd(aPos2Picture,GetSx3Cache(aTableNameCur[nX],"X3_PICTURE"))
				Aadd(aPos2F3,GetSx3Cache(aTableNameCur[nX],"X3_F3"))
				Aadd(aPos2Arquivo,GetSx3Cache(aTableNameCur[nX],"X3_ARQUIVO"))

				Aadd(aPos2Field,("F34_VATXV2")) 
				Aadd(aPos2Text,( alltrim(aTranslation[nX])+" - "))
				Aadd(aPos2Size,GetSx3Cache(aTableNameCur[nX],"X3_TAMANHO"))
				Aadd(aPos2Decimal,GetSx3Cache(aTableNameCur[nX],"X3_DECIMAL"))
				Aadd(aPos2Order,GetSx3Cache(aTableNameCur[nX],"X3_ORDEM"))
				Aadd(aPos2Type,GetSx3Cache(aTableNameCur[nX],"X3_TIPO"))
				Aadd(aPos2Picture,GetSx3Cache(aTableNameCur[nX],"X3_PICTURE"))
				Aadd(aPos2F3,GetSx3Cache(aTableNameCur[nX],"X3_F3"))
				Aadd(aPos2Arquivo,GetSx3Cache(aTableNameCur[nX],"X3_ARQUIVO"))

				if FwisincallStack("RU09T01IVT")
					Aadd(aPos2Field,("VAT_T_V1")) 
					Aadd(aPos2Text,(alltrim(aTranslation[nX])+" - "))
					Aadd(aPos2Size,GetSx3Cache(aTableNameCur[nX],"X3_TAMANHO"))
					Aadd(aPos2Decimal,GetSx3Cache(aTableNameCur[nX],"X3_DECIMAL"))
					Aadd(aPos2Order,GetSx3Cache(aTableNameCur[nX],"X3_ORDEM"))
					Aadd(aPos2Type,GetSx3Cache(aTableNameCur[nX],"X3_TIPO"))
					Aadd(aPos2Picture,GetSx3Cache(aTableNameCur[nX],"X3_PICTURE"))
					Aadd(aPos2F3,GetSx3Cache(aTableNameCur[nX],"X3_F3"))
					Aadd(aPos2Arquivo,GetSx3Cache(aTableNameCur[nX],"X3_ARQUIVO"))
				endif
			
			elseif alltrim(aTableNameCur[nX]) == "F34_VALUE"
			
				Aadd(aPos2Field,("F34_VALUV1"))
				Aadd(aPos2Text,( alltrim(aTranslation[nX])+" + "))
				Aadd(aPos2Size,GetSx3Cache(aTableNameCur[nX],"X3_TAMANHO"))
				Aadd(aPos2Decimal,GetSx3Cache(aTableNameCur[nX],"X3_DECIMAL"))
				Aadd(aPos2Order,GetSx3Cache(aTableNameCur[nX],"X3_ORDEM"))
				Aadd(aPos2Type,GetSx3Cache(aTableNameCur[nX],"X3_TIPO"))
				Aadd(aPos2Picture,GetSx3Cache(aTableNameCur[nX],"X3_PICTURE"))
				Aadd(aPos2F3,GetSx3Cache(aTableNameCur[nX],"X3_F3"))
				Aadd(aPos2Arquivo,GetSx3Cache(aTableNameCur[nX],"X3_ARQUIVO"))

				Aadd(aPos2Field,("F34_VALUV2")) 
				Aadd(aPos2Text,(alltrim(aTranslation[nX])+" - "))
				Aadd(aPos2Size,GetSx3Cache(aTableNameCur[nX],"X3_TAMANHO"))
				Aadd(aPos2Decimal,GetSx3Cache(aTableNameCur[nX],"X3_DECIMAL"))
				Aadd(aPos2Order,GetSx3Cache(aTableNameCur[nX],"X3_ORDEM"))
				Aadd(aPos2Type,GetSx3Cache(aTableNameCur[nX],"X3_TIPO"))
				Aadd(aPos2Picture,GetSx3Cache(aTableNameCur[nX],"X3_PICTURE"))
				Aadd(aPos2F3,GetSx3Cache(aTableNameCur[nX],"X3_F3"))
				Aadd(aPos2Arquivo,GetSx3Cache(aTableNameCur[nX],"X3_ARQUIVO"))

				if FwisincallStack("RU09T01IVT")
					Aadd(aPos2Field,("VAL_T_V1")) 
					Aadd(aPos2Text,(alltrim(aTranslation[nX])+" - "))
					Aadd(aPos2Size,GetSx3Cache(aTableNameCur[nX],"X3_TAMANHO"))
					Aadd(aPos2Decimal,GetSx3Cache(aTableNameCur[nX],"X3_DECIMAL"))
					Aadd(aPos2Order,GetSx3Cache(aTableNameCur[nX],"X3_ORDEM"))
					Aadd(aPos2Type,GetSx3Cache(aTableNameCur[nX],"X3_TIPO"))
					Aadd(aPos2Picture,GetSx3Cache(aTableNameCur[nX],"X3_PICTURE"))
					Aadd(aPos2F3,GetSx3Cache(aTableNameCur[nX],"X3_F3"))
					Aadd(aPos2Arquivo,GetSx3Cache(aTableNameCur[nX],"X3_ARQUIVO"))
				endif

			else
				Aadd(aPos2Field,(aTableNameCur[nX]))
				Aadd(aPos2Text,(aTranslation[nX]))
				Aadd(aPos2Size,GetSx3Cache(aTableNameCur[nX],"X3_TAMANHO"))
				Aadd(aPos2Decimal,GetSx3Cache(aTableNameCur[nX],"X3_DECIMAL"))
				Aadd(aPos2Order,GetSx3Cache(aTableNameCur[nX],"X3_ORDEM"))
				Aadd(aPos2Type,GetSx3Cache(aTableNameCur[nX],"X3_TIPO"))
				Aadd(aPos2Picture,GetSx3Cache(aTableNameCur[nX],"X3_PICTURE"))
				Aadd(aPos2F3,GetSx3Cache(aTableNameCur[nX],"X3_F3"))
				Aadd(aPos2Arquivo,GetSx3Cache(aTableNameCur[nX],"X3_ARQUIVO"))
			endif


		elseif FwisincallStack("RU09T01INV")

			IF alltrim(aTableNameCur[nX]) == "F35_PDATE"
				Aadd(aPos2Field,(aTableNameCur[nX]))
				Aadd(aPos2Text,(aTranslation[nX]))
				Aadd(aPos2Size,GetSx3Cache(aTableNameCur[nX],"X3_TAMANHO"))
				Aadd(aPos2Decimal,GetSx3Cache(aTableNameCur[nX],"X3_DECIMAL"))
				Aadd(aPos2Order,GetSx3Cache(aTableNameCur[nX],"X3_ORDEM"))
				Aadd(aPos2Type,GetSx3Cache(aTableNameCur[nX],"X3_TIPO"))
				Aadd(aPos2Picture,GetSx3Cache(aTableNameCur[nX],"X3_PICTURE"))
				Aadd(aPos2F3,GetSx3Cache(aTableNameCur[nX],"X3_F3"))
				Aadd(aPos2Arquivo,GetSx3Cache(aTableNameCur[nX],"X3_ARQUIVO"))

				Aadd(aPos2Field,("V_F35F2DAT"))
				Aadd(aPos2Text,( Alltrim(aTranslation[nX])+" !Test! " ))
				Aadd(aPos2Size,GetSx3Cache(aTableNameCur[nX],"X3_TAMANHO"))
				Aadd(aPos2Decimal,GetSx3Cache(aTableNameCur[nX],"X3_DECIMAL"))
				Aadd(aPos2Order,GetSx3Cache(aTableNameCur[nX],"X3_ORDEM"))
				Aadd(aPos2Type,GetSx3Cache(aTableNameCur[nX],"X3_TIPO"))
				Aadd(aPos2Picture,GetSx3Cache(aTableNameCur[nX],"X3_PICTURE"))
				Aadd(aPos2F3,GetSx3Cache(aTableNameCur[nX],"X3_F3"))
				Aadd(aPos2Arquivo,GetSx3Cache(aTableNameCur[nX],"X3_ARQUIVO"))
			else
				Aadd(aPos2Field,(aTableNameCur[nX]))
				Aadd(aPos2Text,(aTranslation[nX]))
				Aadd(aPos2Size,GetSx3Cache(aTableNameCur[nX],"X3_TAMANHO"))
				Aadd(aPos2Decimal,GetSx3Cache(aTableNameCur[nX],"X3_DECIMAL"))
				Aadd(aPos2Order,GetSx3Cache(aTableNameCur[nX],"X3_ORDEM"))
				Aadd(aPos2Type,GetSx3Cache(aTableNameCur[nX],"X3_TIPO"))
				Aadd(aPos2Picture,GetSx3Cache(aTableNameCur[nX],"X3_PICTURE"))
				Aadd(aPos2F3,GetSx3Cache(aTableNameCur[nX],"X3_F3"))
				Aadd(aPos2Arquivo,GetSx3Cache(aTableNameCur[nX],"X3_ARQUIVO"))
			endif
		else
			Aadd(aPos2Field,(aTableNameCur[nX]))
			Aadd(aPos2Text,(aTranslation[nX]))
			Aadd(aPos2Size,GetSx3Cache(aTableNameCur[nX],"X3_TAMANHO"))
			Aadd(aPos2Decimal,GetSx3Cache(aTableNameCur[nX],"X3_DECIMAL"))
			Aadd(aPos2Order,GetSx3Cache(aTableNameCur[nX],"X3_ORDEM"))
			Aadd(aPos2Type,GetSx3Cache(aTableNameCur[nX],"X3_TIPO"))
			Aadd(aPos2Picture,GetSx3Cache(aTableNameCur[nX],"X3_PICTURE"))
			Aadd(aPos2F3,GetSx3Cache(aTableNameCur[nX],"X3_F3"))
			Aadd(aPos2Arquivo,GetSx3Cache(aTableNameCur[nX],"X3_ARQUIVO"))
		endif
		
	Endif
	
Next nX

For nX:=1 to len(aFilter3)
	For nX2:=1 to len(aPos2Field)
		If Alltrim( aPos2Field[nX2] ) == Alltrim(aFilter3[nX])
			Aadd(aMark2 , { aPos2Field[nX2] , aPos2Type[nX2] , aPos2Size[nX2], aPos2Decimal[nX2], aPos2Text[nX2] } )
			nX2:=len(aPos2Field)
		Endif
	Next nX2
Next nX

For nX:=1 to len(aFilter3)
	If nX==1
		cMacrS2:= "{ (cAlFor2Br)->" + alltrim(aFilter3[nX])
	else
		cMacrS2+= " , (cAlFor2Br)->" + alltrim(aFilter3[nX])
	endif
Next nX
cMacrS2+=" }"

For nX:=1 to Len(aMFieldsF2)
	If aMFieldsF2[nX][FIELDNAME_POS]  <> 'N4DESC'
		If aMFieldsF2[nX][TYPE_POS] $ 'C|D'
			cSelec3 += If( nX > 1 , "," , "" ) + "CAST((COALESCE(" +alltrim(aMFieldsF2[nX][FIELDNAME_POS]) +",' ')) AS CHAR("+Alltrim(STR(aMFieldsF2[nX][SIZE_POS]))+")) AS " + alltrim(aMFieldsF2[nX][FIELDNAME_POS])
		Elseif aMFieldsF2[nX][TYPE_POS] == 'N' 
			cSelec3 += If( nX > 1 , "," , "" ) + "COALESCE(" +alltrim(aMFieldsF2[nX][FIELDNAME_POS]) +", 0 ) AS " + alltrim(aMFieldsF2[nX][FIELDNAME_POS])
		Else
			cSelec3 += If( nX > 1 , "," , "" ) +alltrim(aMFieldsF2[nX][FIELDNAME_POS])
		Endif
	Endif
Next

cSelec3:= " SELECT " + IIF(FWisincallstack("RU09T01SAL") .or. FWisincallstack("RU09T01PUR"),"DISTINCT ","") + cSelec3



If aMorFields!=Nil .and. len(aMorFields)>=1 .and. !empty(aMorFields[1])
	cSelec3+=", " + aMorFields[1]
Endif



If FWisincallstack("RU09T01OVA")
		if !lGroup
			cSelec3:= SUBSTR(cSelec3,1,AT("F54_VALUV1",cSelec3,1)-1) + "CASE WHEN F54_DIRECT='+' THEN F54_VALUE ELSE 0 END AS F54_VALUV1" + SUBSTR(cSelec3,AT("F54_VALUV1",cSelec3,1)+10,len(cSelec3))
			cSelec3:= SUBSTR(cSelec3,1,AT("F54_VATXV1",cSelec3,1)-1) + "CASE WHEN F54_DIRECT='+' THEN F54_VATBS ELSE 0 END AS F54_VATXV1" + SUBSTR(cSelec3,AT("F54_VATXV1",cSelec3,1)+10,len(cSelec3))
			cSelec3:= SUBSTR(cSelec3,1,AT("F54_VALUV2",cSelec3,1)-1) + "CASE WHEN F54_DIRECT='-' THEN F54_VALUE ELSE 0 END AS F54_VALUV2" + SUBSTR(cSelec3,AT("F54_VALUV2",cSelec3,1)+10,len(cSelec3))
			cSelec3:= SUBSTR(cSelec3,1,AT("F54_VATXV2",cSelec3,1)-1) + "CASE WHEN F54_DIRECT='-' THEN F54_VATBS ELSE 0 END AS F54_VATXV2" + SUBSTR(cSelec3,AT("F54_VATXV2",cSelec3,1)+10,len(cSelec3))
		else
			cSelec3:= SUBSTR(cSelec3,1,AT("F54_VALUV1",cSelec3,1)-1) + "CASE WHEN F54_DIRECT='+' THEN F54_VALUE ELSE 0 END " + SUBSTR(cSelec3,AT("F54_VALUV1",cSelec3,1)+10,len(cSelec3))
			cSelec3:= SUBSTR(cSelec3,1,AT("F54_VATXV1",cSelec3,1)-1) + "CASE WHEN F54_DIRECT='+' THEN F54_VATBS ELSE 0 END " + SUBSTR(cSelec3,AT("F54_VATXV1",cSelec3,1)+10,len(cSelec3))
			cSelec3:= SUBSTR(cSelec3,1,AT("F54_VALUV2",cSelec3,1)-1) + "CASE WHEN F54_DIRECT='-' THEN F54_VALUE ELSE 0 END " + SUBSTR(cSelec3,AT("F54_VALUV2",cSelec3,1)+10,len(cSelec3))
			cSelec3:= SUBSTR(cSelec3,1,AT("F54_VATXV2",cSelec3,1)-1) + "CASE WHEN F54_DIRECT='-' THEN F54_VATBS ELSE 0 END " + SUBSTR(cSelec3,AT("F54_VATXV2",cSelec3,1)+10,len(cSelec3))
		endif
elseIf (FWisincallstack("RU09T01IVA") .or. FWisincallstack("RU09T01IVT") /*.or. FWisincallstack("RU09T01NBV")*/)
		If !lGroup
			cSelec3:= SUBSTR(cSelec3,1,AT("F34_VALUV1",cSelec3,1)-1) + "CASE WHEN F34_TYPE IN ('01','04') THEN F34_VALUE ELSE 0 END AS F34_VALUV1" + SUBSTR(cSelec3,AT("F34_VALUV1",cSelec3,1)+10,len(cSelec3))
			cSelec3:= SUBSTR(cSelec3,1,AT("F34_VATXV1",cSelec3,1)-1) + "CASE WHEN F34_TYPE IN ('01','04') THEN F34_VATBS ELSE 0 END AS F34_VATXV1" + SUBSTR(cSelec3,AT("F34_VATXV1",cSelec3,1)+10,len(cSelec3))
			cSelec3:= SUBSTR(cSelec3,1,AT("F34_VALUV2",cSelec3,1)-1) + "CASE WHEN F34_TYPE IN ('02','03') THEN F34_VALUE ELSE 0 END AS F34_VALUV2" + SUBSTR(cSelec3,AT("F34_VALUV2",cSelec3,1)+10,len(cSelec3))
			cSelec3:= SUBSTR(cSelec3,1,AT("F34_VATXV2",cSelec3,1)-1) + "CASE WHEN F34_TYPE IN ('02','03') THEN F34_VATBS ELSE 0 END AS F34_VATXV2" + SUBSTR(cSelec3,AT("F34_VATXV2",cSelec3,1)+10,len(cSelec3))

			cSelec3:= SUBSTR(cSelec3,1,AT("VAT_T_V1",cSelec3,1)-1) + "(CASE WHEN F34_TYPE IN ('01','04') THEN F34_VATBS ELSE 0 end-CASE WHEN F34_TYPE IN ('02','03') THEN F34_VATBS ELSE 0 end+F32_INIBS) as VAT_T_V1" + SUBSTR(cSelec3,AT("VAT_T_V1",cSelec3,1)+8,len(cSelec3))
			cSelec3:= SUBSTR(cSelec3,1,AT("VAL_T_V1",cSelec3,1)-1) + "(CASE WHEN F34_TYPE IN ('01','04') THEN F34_VALUE ELSE 0 end-CASE WHEN F34_TYPE IN ('02','03') THEN F34_VALUE ELSE 0 END+F32_INIBAL) as VAL_T_V1" + SUBSTR(cSelec3,AT("VAL_T_V1",cSelec3,1)+8,len(cSelec3))
		else
			cSelec3:= SUBSTR(cSelec3,1,AT("F34_VALUV1",cSelec3,1)-1) + "CASE WHEN F34_TYPE IN ('01','04') THEN F34_VALUE ELSE 0 END " + SUBSTR(cSelec3,AT("F34_VALUV1",cSelec3,1)+10,len(cSelec3))
			cSelec3:= SUBSTR(cSelec3,1,AT("F34_VATXV1",cSelec3,1)-1) + "CASE WHEN F34_TYPE IN ('01','04') THEN F34_VATBS ELSE 0 END " + SUBSTR(cSelec3,AT("F34_VATXV1",cSelec3,1)+10,len(cSelec3))
			cSelec3:= SUBSTR(cSelec3,1,AT("F34_VALUV2",cSelec3,1)-1) + "CASE WHEN F34_TYPE IN ('02','03') THEN F34_VALUE ELSE 0 END " + SUBSTR(cSelec3,AT("F34_VALUV2",cSelec3,1)+10,len(cSelec3))
			cSelec3:= SUBSTR(cSelec3,1,AT("F34_VATXV2",cSelec3,1)-1) + "CASE WHEN F34_TYPE IN ('02','03') THEN F34_VATBS ELSE 0 END " + SUBSTR(cSelec3,AT("F34_VATXV2",cSelec3,1)+10,len(cSelec3))

			cSelec3:= SUBSTR(cSelec3,1,AT("VAT_T_V1",cSelec3,1)-1) + "(CASE WHEN F34_TYPE IN ('01','04') THEN F34_VATBS ELSE 0 end-CASE WHEN F34_TYPE IN ('02','03') THEN F34_VATBS ELSE 0 end+F32_INIBS)" + SUBSTR(cSelec3,AT("VAT_T_V1",cSelec3,1)+8,len(cSelec3))
			cSelec3:= SUBSTR(cSelec3,1,AT("VAL_T_V1",cSelec3,1)-1) + "(CASE WHEN F34_TYPE IN ('01','04') THEN F34_VALUE ELSE 0 end-CASE WHEN F34_TYPE IN ('02','03') THEN F34_VALUE ELSE 0 END+F32_INIBAL)" + SUBSTR(cSelec3,AT("VAL_T_V1",cSelec3,1)+8,len(cSelec3))
		endif
elseif FWisincallstack("RU09T01INV")
		cSelec3:= SUBSTR(cSelec3,1,AT("V_F35F2DAT,' ')::character(8)",cSelec3,1)-1) + "DATE_PART('day',TO_TIMESTAMP(F35_PDATE,'YYYYMMDD')-TO_TIMESTAMP(F2_DTSAIDA,'YYYYMMDD')),0)::FLOAT8" + SUBSTR(cSelec3,AT("V_F35F2DAT,' ')::character(8)",cSelec3,1)+29,len(cSelec3))
Endif



cSelec3+= " FROM "+ RetSqlName(aMAliases[1][1][1])

If len(aMAliases)>=2
	For nX:=1 to Len(aMAliases)
		cSelec3+= " LEFT JOIN " + RetSqlName(aMAliases[nX][2][1])
		For nX2:=2 to len(aMAliases[nX][1])
			If nX2==2
 				cSelec3+= " ON " + aMAliases[nX][1][nX2] + " = " + aMAliases[nX][2][nX2]
			Else
				cSelec3+= " AND " + aMAliases[nX][1][nX2] + " = " + aMAliases[nX][2][nX2] //+ CRLF
			Endif
		Next nX2
		cSelec3+= " AND " + RetSqlName(aMAliases[nX][2][1]) + ".D_E_L_E_T_ = ' '" //+ CRLF
	Next
Endif

cSelec3+= " WHERE " + RetSqlName(aMAliases[1][1][1]) + ".D_E_L_E_T_=' ' "

for nX:=1 to len(aMVparFields)
	If nX!=len(aMVparFields) .and. aMVparFields[nX][1]==aMVparFields[nX+1][1]
		cSelec3 += " AND " +  aMVparFields[nX][1]
		cSelec3 += " BETWEEN '" + &(aMVparFields[nX][2]) + "' AND '" + &(aMVparFields[nX+1][2]) + "'" //+ CRLF
		nX+=1
	Else
		If (!Empty(&(aMVparFields[nX][2])))

			if FwIsInCallStack("RU09T01PUR") .or. FwIsInCallStack("RU09T01SAL") .or. FwIsInCallStack("RU09T01INV") .or. FwIsInCallStack("RU09T01IVA") .or. FwIsInCallStack("RU09T01OVA") .or. FwIsInCallStack("RU09T01IVT") .or. FwIsInCallStack("RU09T01NBV")
				If nX==3 .and. &(aMVparFields[nX][2])==2
					cSelec3 += " AND " + aMVparFields[nX][1] + " IS NULL" //+ CRLF
				Elseif nX==3 .and. &(aMVparFields[nX][2])==1
					cSelec3 += " AND " + aMVparFields[nX][1] + "!=''" //+ CRLF
				Elseif nX==3 .and. &(aMVparFields[nX][2])==3
				Else	
					cSelec3 += " AND " + aMVparFields[nX][1] + " IN ("+ &( aMVparFields[nX][2] ) +")" //+ CRLF
				Endif				
			else
				cSelec3 += " AND " + aMVparFields[nX][1] + " IN ("+ &( aMVparFields[nX][2] ) +")" //+ CRLF
			endif
		Endif
	Endif
Next

For nX:=1 to len(aMFieldsX) 
	if valType(aDataFromLine[nX])=='C' .and. empty(alltrim(aDataFromLine[nX])) .and. aMFieldsX[nX][6]!=aMAliases[1][1][1]
		cSelec3+= " AND " + alltrim(aMFieldsX[nX][FIELDNAME_POS]) + " IS NULL "
	Else
		cSelec3+= " AND " + alltrim(aMFieldsX[nX][FIELDNAME_POS]) + " = " + IIF( ValType(aDataFromLine[nX])=='N' , alltrim(str(aDataFromLine[nX])) , "'" + alltrim(aDataFromLine[nX]) + "'" ) //TEST9999 need enclude for [2]
	Endif
Next nX

If !Empty(cQLPorder)
	cSelec3 += " ORDER BY " + cQLPorder
Endif
	cSelec3:=Changequery(cSelec3)
If select(cAlFor2Br)>0
	(cAlFor2Br)->(dbCloseArea()) 
	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cSelec3) , cAlFor2Br ,.T.,.F.)
else
	dbUseArea( .T. , "TOPCONN" , TcGenQry( ,, cSelec3) , cAlFor2Br ,.T.,.F.)
endif

(cAlFor2Br)->( dbGoTop() )
nX:=0
While !(cAlFor2Br)->( EOF() )
	nX+=1
	(cAlFor2Br)->( dbSkip() )
EndDo
(cAlFor2Br)->( dbGoTop() )

If nX==1 
	bS2Macr:=&("{ || R02MovLine(1), RunFunc(1, oBrowse:oBrowse:ColPos(), cAlFor2Br, &(cMacrS2), ntypeAct, aMarked) }" )
	Eval(bS2Macr, 1)
elseif nX==0

else
	//x,y coordinates for window
	aSizes[1]:=Round( (aSizes[1]+aSizes[3])/20 , 0)
	aSizes[2]:=Round( (aSizes[2]+aSizes[4])/20 , 0)
	aSizes[3]:=Round( aSizes[3]/1.6 , 0)
	aSizes[4]:=Round( aSizes[4]/1.6 , 0)

	Define MsDialog oMainDl2 Title cCadastro From aSizes[1], aSizes[2] To aSizes[3], aSizes[4] Pixel

	For nX := 1 To Len(aMark2) 
		If aMark2[nX][FIELDNAME_POS] == 'N4DESC'
			aadd( aStruc, { aMark2[nX][TEXT_POS] , &("{ || " + aMark2[nX][FIELDNAME_POS] + " }") ,  aMark2[nX][TYPE_POS], '', 0, aMark2[nX][SIZE_POS] , aMark2[nX][DECIMAL_POS]})	
		Else
			aadd( aStruc, { Alltrim(RetTitle(aMark2[nX][FIELDNAME_POS]))  , &("{ || " + aMark2[nX][FIELDNAME_POS] + " }") ,  aMark2[nX][TYPE_POS], GetSx3Cache( aMark2[nX][FIELDNAME_POS] , "x3_picture" ), 0, aMark2[nX][SIZE_POS] , aMark2[nX][DECIMAL_POS]})
		Endif
	Next nX

	o2Browse:=FWFormBrowse():New()

	o2Browse:SetDataQuery()
	o2Browse:SetAlias(CriaTrab(,.F.))
	o2Browse:SetQuery(cSelec3)
	o2Browse:SetColumns(aStruc)
	o2Browse:SetOwner(oMainDl2)
	o2Browse:DisableConfig()
	o2Browse:DisableReport()

	bS2Macr:=&("{ || R02MovLine(o2Browse:at()), RunFunc(o2Browse:at(), o2Browse:oBrowse:ColPos(), cAlFor2Br, &(cMacrS2), ntypeAct, aMark2) }" )

	o2Browse:SetDoubleClick(bS2Macr)
	o2Browse:Activate()
	a2BCMacr:={}
	aCode:={}
	aCode:=GetListArr(aCodeBloc)

	For nX:=1 to len(aCode)
		AADD(a2BCMacr,"{ || R02MovLine(o2Browse:at()), RunFunc(o2Browse:at(), o2Browse:oBrowse:ColPos(), cAlFor2Br, &(cMacrS2), " + STR(aCode[nX]) + ", aMark2) }" )
	Next nX 

	a2Buttons:={}
	cTemp1:=""
	For nX:=1 to len(aButtons2)
		If SUBSTR(aButtons2[nX][2],1,9)=="a2BCMacr["
			cTemp1:=&(aButtons2[nX][2])
			AADD(a2Buttons,{aButtons2[nX][1], &(cTemp1), aButtons2[nX][3], aButtons2[nX][4]})
		Else
			AADD(a2Buttons,{aButtons2[nX][1], &(aButtons2[nX][2]), aButtons2[nX][3], aButtons2[nX][4]})
		Endif
	Next

	Activate MsDialog oMainDl2 ON INIT (EnchoiceBar(oMainDl2,{||lOk:=.T.,oMainDl2:End()},{||oMainDl2:End()},,;
		a2Buttons,,,.F.,.T.,.F.,.F.,.F.)) CENTERED
Endif

Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/07-11-2018
@Description standart printing
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function tReport_SQL(nCalF as numeric)
Local oReport
Private nCal as numeric

nCal:=nCalF
	oReport := ReportDef()
//printing
	oReport:PrintDialog()
Return( NIL )
 
/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/07-11-2018
@Description standart printing
@Return Object
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function ReportDef()
Local oReport
Local oSection
Local nX 	as numeric
Local aCutMAliases as array

aCutMAliases:={}

For nX:=1 to len(aMAliases)
	aadd(aCutMAliases,aMAliases[nX][1][1])
Next

oReport := TReport():New(STR0005,STR0004+" "+STR0005,"ATFREP",{|oReport| PrintReport(oReport)},"", .F. ,  , .T. ,  , .F. , .F. ,  )
oSection := TRSection():New(oReport,"t1_section", aCutMAliases )

For nX:=1 to len(aMarked)
	TRCell():New(oSection, alltrim(aMarked[nx][FIELDNAME_POS]), aMAliases[1][1][1])
Next 

//add total in print report
For nX:=1 to len(aMarked)
	If alltrim(aMarked[nX][TYPE_POS])=="N"
		TRFunction():New(oSection:Cell(alltrim(aMarked[nx][FIELDNAME_POS])), NIL, "SUM",,,,,.F.,.T.,,,,,)
	Endif
Next

Return ( oReport )

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/07-11-2018
@Description standart printing
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function PrintReport(oReport)
Local oSection := oReport:Section(1)

if nCal==2
	If lGroup
		oSection:SetQuery(cAlFor2Br, cSelec3, .F. ,,)
	Else
		oSection:SetQuery(cSN4TmpAlias, cQuery, .F. ,,)
	Endif
elseif nCal==1
	oSection:SetQuery(cSN4TmpAlias, cQuery, .F. ,,)
endif

oSection:Print()

Return(NIL)

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/20-11-2018
@Description Filter 
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function FAOpenFilter()

oFWFilter:Show()
oFWFilter:Activate( oBrowse , .T. )
oFWFilter:SaveFilter()

Return


/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/20-11-2018
@Description Filter
@Return Character
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function FAGetFilters()
Local nCount as numeric
Local cAllFilter as character

cAllFilter	:= ''
oFWFilter:SaveFilter()

For nCount:=1 to Len(oFWFilter:aFilter)
	If oFWFilter:aFilter[nCount][6]
		If !empty(cAllFilter)
			cAllFilter += " AND " + Alltrim(oFWFilter:aFilter[nCount][3])
		Else
			cAllFilter += Alltrim(oFWFilter:aFilter[nCount][3])
		Endif
	Endif
Next nCount

Return cAllFilter


/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/03-12-2018
@Description Run function
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function RunFunc(nNOfLine as numeric, nNOfColumn as numeric, c2AlFor2Br as character, aDataFromLine as array, ntypeAct as numeric, aMarkFromFS as array) 

Local cTempCode as character
Local nX as numeric
Local aCodeBlock as array//outdated need check 

If !lgroup
	If aModColor!=Nil
		nNOfColumn:=nNOfColumn-1
	Endif
Endif

aCodeBlock:={}

For nX:=ntypeAct to (len(aCodeBloc)-1)

	cTempCode:=""

	If aCodeBloc[nX][2][2]==ntypeAct//type of activation
	If IIF(empty(aCodeBloc[nX][4]),.T.,Alltrim(aMarkFromFS[nNOfColumn][1]) $ aCodeBloc[nX][4])//confirm fields
		cTempCode:= " { || "
		If !empty(aCodeBloc[nX][1])
			cTempCode+= aCodeBloc[nX][1] + ", "
		Endif

		cTempCode+= aCodeBloc[nX][2][1]+"(c2AlFor2Br,nNOfLine,nNOfColumn,aDataFromLine,ntypeAct"
		cTempCode+= aCodeBloc[nX][2][3]

		cTempCode+= ") "

		If !empty(aCodeBloc[nX][3])
			cTempCode+= ", " + aCodeBloc[nX][3]
		Endif

		cTempCode+= " }"

		AADD(aCodeBlock,cTempCode)//outdated need check

		Eval(&(cTempCode),1)
		nX:=len(aCodeBloc)
	Endif
	Endif
Next nX

Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/03-12-2018
@Description working with array
@Return array
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC Function GetListArr(aArr as array)
Local a2Arr as array
Local nX as numeric

a2Arr:={}

For nX:=1 to Len(aArr)-1
	If nX==1
		AADD(a2Arr,aArr[nX][2][2])

	Elseif aArr[nX][2][2]!=aArr[nX-1][2][2]
		AADD(a2Arr,aArr[nX][2][2])
	Endif
Next nX
Return a2Arr

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/03-12-2018
@Description For run MATA020
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC function GetSuppMD()
Local aArea as Array
Local aAreaSA2 as Array
Local cSeek as character
local l1Ret as Logical

cSeek:=''

aArea := GetArea()
aAreaSA2 := &(aMAliases[3][2][1])->(GetArea())

if lGroup
	cSeek := (cAlFor2Br)->(&(substr(aMAliases[3][2][1],2,2)+"_COD"))
	cSeek += (cAlFor2Br)->(&(substr(aMAliases[3][2][1],2,2)+"_LOJA"))
else
	cSeek := (cSN4TmpAlias)->(&(substr(aMAliases[3][2][1],2,2)+"_COD"))
	cSeek += (cSN4TmpAlias)->(&(substr(aMAliases[3][2][1],2,2)+"_LOJA"))
endif

dbSelectArea(aMAliases[3][2][1])
&(aMAliases[3][2][1])->(dbSetOrder(1))
&(aMAliases[3][2][1])->(DBGoTop())
If &(aMAliases[3][2][1])->(dbSeek(xFilial(aMAliases[3][2][1]) + cSeek))
	If FwIsInCallStack("RU09T01PUR")
    	FwExecView('', "MATA020", MODEL_OPERATION_VIEW, , {|| .T.})
	Elseif FwIsInCallStack("RU09T01SAL")
		FwExecView('', "CRMA980", MODEL_OPERATION_VIEW, , {|| .T.})
	Else
		HELP(' ',1,STR0018)
	Endif

	l1Ret:=.T.
Else
	l1Ret:=.F.
	HELP(' ',1,STR0018)
EndIf

RestArea(aAreaSA2)
RestArea(aArea)

Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/03-12-2018
@Description For run MATA101n
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC function GetComInv()

Local aArea as Array
Local aAreaSF1 as Array
Local aAreaSD1 as Array
Local cSeek as character
Local l1Ret as Logical
Local aAreaSM0	:=SM0->(GetArea())

Private aRotinaTMP as array
Private aRotina as array

aRotinaTMP:={}
aRotina:={}

cSeek:=''

aRotinaTMP	:=	aClone(aRotina)
aRotina	:=	{{"","",0,2,0,Nil},;
			{"","",0,2,0,Nil},;
			{"","",0,2,0,Nil},;
			{"","",0,2,0,Nil}}

aArea := GetArea()
aAreaSD1 := SD1->(GetArea())
aAreaSF1 := &(aMAliases[1][1][1])->(GetArea())

if lGroup
	cFilTable	:=	(cAlFor2Br)->(&(substr(aMAliases[1][1][1],2,2)+"_FILIAL"))
	cSeek := (cAlFor2Br)->(&(substr(aMAliases[1][1][1],2,2)+"_FILIAL"))
	cSeek += (cAlFor2Br)->(&(substr(aMAliases[1][1][1],2,2)+"_DOC"))
	cSeek += (cAlFor2Br)->(&(substr(aMAliases[1][1][1],2,2)+"_SERIE"))
	cSeek += (cAlFor2Br)->(&(substr(aMAliases[1][1][1],2,2)+"_FORNECE"))
	cSeek += (cAlFor2Br)->(&(substr(aMAliases[1][1][1],2,2)+"_LOJA"))
	cSeek += (cAlFor2Br)->(&(substr(aMAliases[1][1][1],2,2)+"_TIPO"))
else
	cFilTable	:=	(cSN4TmpAlias)->(&(substr(aMAliases[1][1][1],2,2)+"_FILIAL"))
	cSeek := (cSN4TmpAlias)->(&(substr(aMAliases[1][1][1],2,2)+"_FILIAL"))
	cSeek += (cSN4TmpAlias)->(&(substr(aMAliases[1][1][1],2,2)+"_DOC"))
	cSeek += (cSN4TmpAlias)->(&(substr(aMAliases[1][1][1],2,2)+"_SERIE"))
	cSeek += (cSN4TmpAlias)->(&(substr(aMAliases[1][1][1],2,2)+"_FORNECE"))
	cSeek += (cSN4TmpAlias)->(&(substr(aMAliases[1][1][1],2,2)+"_LOJA"))
	cSeek += (cSN4TmpAlias)->(&(substr(aMAliases[1][1][1],2,2)+"_TIPO"))
endif
If !Empty(cFilTable)
	SM0->(DbSetOrder(1))
	SM0->(MsSeek(M0_CODIGO+cFilTable))
Endif

cFilant:=cFilTable

dbSelectArea(aMAliases[1][1][1])
&(aMAliases[1][1][1])->(dbSetOrder(1))
SD1->(dbSetOrder(1))
&(aMAliases[1][1][1])->(DBGoTop())
If &(aMAliases[1][1][1])->(dbSeek(cSeek))
    CtbDocEnt()//MATA101N
	l1Ret:=.T.
Else
	l1Ret:=.F.
	HELP(' ',1,STR0018)
EndIf

RestArea(aAreaSM0)
RestArea(aAreaSF1)
RestArea(aAreaSD1)
RestArea(aArea)
aRotina	:=	aClone(aRotinaTMP)
Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/03-12-2018
@Description For run 
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC function GetComInvS()

Local aArea as Array
Local aAreaSF1 as Array
Local aAreaSD1 as Array
Local cSeek as character
Local l1Ret as Logical
Local aAreaSM0	:=SM0->(GetArea())

Private aRotinaTMP as array
Private aRotina as array

aRotinaTMP:={}
aRotina:={}

cSeek:=''

aRotinaTMP	:=	aClone(aRotina)
aRotina	:=	{{"","",0,2,0,Nil},;
			{"","",0,2,0,Nil},;
			{"","",0,2,0,Nil},;
			{"","",0,2,0,Nil}}

aArea := GetArea()
aAreaSD1 := SD1->(GetArea())
aAreaSF1 := &(aMAliases[1][1][1])->(GetArea())

if lGroup
	cFilTable	:=	(cAlFor2Br)->(&(substr(aMAliases[1][1][1],2,2)+"_FILIAL"))
	cSeek := (cAlFor2Br)->(&(substr(aMAliases[1][1][1],2,2)+"_FILIAL"))
	cSeek += (cAlFor2Br)->(&(substr(aMAliases[1][1][1],2,2)+"_DOC"))
	cSeek += (cAlFor2Br)->(&(substr(aMAliases[1][1][1],2,2)+"_SERIE"))
	cSeek += (cAlFor2Br)->(&(substr(aMAliases[1][1][1],2,2)+"_CLIENTE"))
	cSeek += (cAlFor2Br)->(&(substr(aMAliases[1][1][1],2,2)+"_LOJA"))
	cSeek += (cAlFor2Br)->(&(substr(aMAliases[1][1][1],2,2)+"_FORMUL"))
	cSeek += (cAlFor2Br)->(&(substr(aMAliases[1][1][1],2,2)+"_TIPO"))
else
	cFilTable	:=	(cSN4TmpAlias)->(&(substr(aMAliases[1][1][1],2,2)+"_FILIAL"))
	cSeek := (cSN4TmpAlias)->(&(substr(aMAliases[1][1][1],2,2)+"_FILIAL"))
	cSeek += (cSN4TmpAlias)->(&(substr(aMAliases[1][1][1],2,2)+"_DOC"))
	cSeek += (cSN4TmpAlias)->(&(substr(aMAliases[1][1][1],2,2)+"_SERIE"))
	cSeek += (cSN4TmpAlias)->(&(substr(aMAliases[1][1][1],2,2)+"_CLIENTE"))
	cSeek += (cSN4TmpAlias)->(&(substr(aMAliases[1][1][1],2,2)+"_LOJA"))
	cSeek += (cSN4TmpAlias)->(&(substr(aMAliases[1][1][1],2,2)+"_FORMUL"))
	cSeek += (cSN4TmpAlias)->(&(substr(aMAliases[1][1][1],2,2)+"_TIPO"))
endif
If !Empty(cFilTable)
	SM0->(DbSetOrder(1))
	SM0->(MsSeek(M0_CODIGO+cFilTable))
Endif

cFilant:=cFilTable

dbSelectArea(aMAliases[1][1][1])
&(aMAliases[1][1][1])->(dbSetOrder(1))
SD1->(dbSetOrder(1))
&(aMAliases[1][1][1])->(DBGoTop())
If &(aMAliases[1][1][1])->(dbSeek(cSeek))
    CtbDocSaida() //MATA467N
	l1Ret:=.T.
Else
	l1Ret:=.F.
	HELP(' ',1,STR0018)
EndIf

RestArea(aAreaSM0)
RestArea(aAreaSF1)
RestArea(aAreaSD1)
RestArea(aArea)

aRotina	:=	aClone(aRotinaTMP)
Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/03-12-2018
@Description For run RU09T03
@Return
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

STATIC function GetVATInv()

Local aArea as Array
Local aAreaF37 as Array
Local cSeek as character
local l1Ret as Logical

Private INCLUI as Logical

INCLUI:=.F.

cSeek:=''

aArea := GetArea()
aAreaF37 := &(aMAliases[1][2][1]+"->(GetArea())")

if FWisincallstack("RU09T01PUR")
	if lGroup
		cSeek :=(cAlFor2Br)->(&(aMAliases[1][2][1]+"_FILIAL"))
		cSeek += (cAlFor2Br)->(&(aMAliases[1][2][1]+"_PDATE"))
		cSeek += (cAlFor2Br)->(&(aMAliases[1][2][1]+"_DOC"))
		cSeek += (cAlFor2Br)->(&(aMAliases[1][2][1]+"_TYPE"))
	else
		cSeek :=(cSN4TmpAlias)->(&(aMAliases[1][2][1]+"_FILIAL"))
		cSeek += (cSN4TmpAlias)->(&(aMAliases[1][2][1]+"_PDATE"))
		cSeek += (cSN4TmpAlias)->(&(aMAliases[1][2][1]+"_DOC"))
		cSeek += (cSN4TmpAlias)->(&(aMAliases[1][2][1]+"_TYPE"))
	Endif
else
	if lGroup
		cSeek :=(cAlFor2Br)->(&(aMAliases[2][2][1]+"_FILIAL"))
		cSeek += (cAlFor2Br)->(&(aMAliases[2][2][1]+"_PDATE"))
		cSeek += (cAlFor2Br)->(&(aMAliases[2][2][1]+"_DOC"))
		cSeek += (cAlFor2Br)->(&(aMAliases[2][2][1]+"_TYPE"))
	else
		cSeek :=(cSN4TmpAlias)->(&(aMAliases[2][2][1]+"_FILIAL"))
		cSeek += (cSN4TmpAlias)->(&(aMAliases[2][2][1]+"_PDATE"))
		cSeek += (cSN4TmpAlias)->(&(aMAliases[2][2][1]+"_DOC"))
		cSeek += (cSN4TmpAlias)->(&(aMAliases[2][2][1]+"_TYPE"))
	Endif
endif

cFilant:=(cAlFor2Br)->(&(aMAliases[1][2][1]+"_FILIAL"))
dbSelectArea(aMAliases[1][2][1])
&(aMAliases[1][2][1])->(dbSetOrder(1))
&(aMAliases[1][2][1])->(DBGoTop())
If &(aMAliases[1][2][1])->(dbSeek(cSeek))
	If FwIsInCallStack("RU09T01PUR")
		FwExecView('', "RU09T03", MODEL_OPERATION_VIEW, , {|| .T.})
	elseif FwIsInCallStack("RU09T01SAL")
    	FwExecView('', "RU09T02", MODEL_OPERATION_VIEW, , {|| .T.})
	endif
	l1Ret:=.T.
Else
	l1Ret:=.F.
	HELP(' ',1,STR0018)
EndIf

RestArea(aAreaF37)
RestArea(aArea)


Return

/*&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
@author Artem Nikitenko
@version/date 1.0/03-12-2018
@Description function for get summa of lines in DB
@Return logical
&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&*/

Function RU09T01VLD(PAR01,PAR02)

local lRet as Logical
lRet:=.T.

if PAR01>PAR02
	HELP(' ',1,STR0031)
	lRet:=.F.
endif

Return lRet