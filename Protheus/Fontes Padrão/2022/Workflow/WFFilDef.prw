#include "WFFILDEF.CH"
#include "SIGAWF.CH"

// Tipos de dados
#define DT_UNKNOW        "U"
#define DT_NUMERIC       "N"
#define DT_STRING        "C"
#define DT_DATE          "D"
#define DT_LOGIC         "L"
#define DT_ALPHA         "A"

// Tipos de validação
#define TV_FIELD         1
#define TV_CAPTION       2
#define TV_REQUIRED      3
#define TV_FIELDTYPE     4
#define TV_FIELDLEN      5
#define TV_FIELDDEC      6
#define TV_FIELDMINVAL   7
#define TV_FIELDMAXVAL   8
#define TV_EVENTS        9
#define TV_COMBOVALUES   10
#define TV_READONLY      11
#define TV_COUNT         11

function TFldDefObj( oHtml )
return TWFFieldDef():New( oHtml )

class TWFFieldDef
	data oHtml    
	data aFields
	
	method New(poHtml) constructor
	method Free()
	method GetJSCode()
   method AddField(pcFieldName, pnDataType)
   method FieldName(pnField)
	method FieldPos(pcField)
	method Caption(pcField, pcValue)
	method Required(pcField, plValue)
	method CantEdit(pcField, plValue)
	method FieldType(pcField, pcValue)
	method FieldLen(pcField, pnValue)
	method FieldDec(pcField, pnValue)
	method FieldMinVal(pcField, pxValue)
	method FieldMaxVal(pcField, pxValue)
	method ComboValues(pcField, paValue)
	method Events(pcField, pcChange, pcBlur)
	method Count()

	method Clear()
endClass
                         
// *--< Inicializa a classe >--------------------------------------------------*
method  New(poHtml) class TWFFieldDef

	::Clear()
   
return

// *--< Libera a classe >------------------------------------------------------*
method Free() class TWFFieldDef
	::aFields := NIL
return

// *--< Limpa a lista de campos >----------------------------------------------*
method Clear() class TWFFieldDef
	::aFields := {}
return

// *--< Adiciona um campo na lista >-------------------------------------------*
method AddField(pcFieldName, pcDataType) class TWFFieldDef
	local aField := {}
	
	if (ascan(::aFields, {|x| x[1] == upper(pcFieldName)}) == 0)
		aField := array(TV_COUNT)

		aField[TV_FIELD      ] := upper(pcFieldName)
		aField[TV_CAPTION    ] := pcFieldName
		aField[TV_REQUIRED   ] := .F.
		aField[TV_FIELDTYPE  ] := pcDataType
		aField[TV_FIELDLEN   ] := nil
		aField[TV_FIELDDEC   ] := nil
		aField[TV_FIELDMINVAL] := nil
		aField[TV_FIELDMAXVAL] := nil
		aField[TV_EVENTS     ] := {nil, nil}
		aField[TV_COMBOVALUES] := {}
		aField[TV_READONLY   ] := .F.

		aAdd(::aFields,  aClone(aField) )
	endif
return

// *--< Propriedade FieldName >------------------------------------------------*
method FieldName(pnField) class TWFFieldDef
return (::aFields[pnField, TV_FIELD])

// *--< Retorna a posicao do Field >-------------------------------------------*
method FieldPos(pcField) class TWFFieldDef
return (aScan(::aFields, {|x| upper(x[TV_FIELD]) == upper(pcField)}))

// *--< Propriedade Caption >--------------------------------------------------*
method Caption(pcField, pcValue) class TWFFieldDef
	local rcValue := (::aFields[::FieldPos(pcField), TV_CAPTION])
	
	if pcValue != nil
		::aFields[::FieldPos(pcField), TV_CAPTION] := pcValue
	endif
	
return (rcValue)

// *--< Propriedade Required >-------------------------------------------------*
method Required(pcField, plValue) class TWFFieldDef
	local rlValue := (::aFields[::FieldPos(pcField), TV_REQUIRED])

	if plValue != nil
		::aFields[::FieldPos(pcField), TV_REQUIRED] := plValue
	endif
	
return (rlValue)

// *--< Propriedade CantEdit >------------------------------------------------*
method CantEdit(pcField, plValue) class TWFFieldDef
	local rlValue := (::aFields[::FieldPos(pcField), TV_READONLY])

	if plValue != nil
		::aFields[::FieldPos(pcField), TV_READONLY] := plValue
	endif
	
return (rlValue)

// *--< Propriedade FiledType >------------------------------------------------*
method FieldType(pcField, pcValue) class TWFFieldDef
	local rcValue := (::aFields[::FieldPos(pcField), TV_FIELDTYPE])

	if pcValue != nil
		::aFields[::FieldPos(pcField), TV_FIELDTYPE] := pcValue
	endif
	
return (rcValue)

// *--< Propriedade FieldLen >-------------------------------------------------*
method FieldLen(pcField, pnValue) class TWFFieldDef
	local rnValue := (::aFields[::FieldPos(pcField), TV_FIELDLEN])

	if pnValue != nil
		::aFields[::FieldPos(pcField), TV_FIELDLEN] := pnValue
	endif
	
return (rnValue)

// *--< Propriedade FieldDec >-------------------------------------------------*
method FieldDec(pcField, pnValue) class TWFFieldDef
	local rnValue := (::aFields[::FieldPos(pcField), TV_FIELDDEC])

	if pnValue != nil
		::aFields[::FieldPos(pcField), TV_FIELDDEC] := pnValue
	endif
	
return (rnValue)

// *--< Propriedade FieldMinVal >----------------------------------------------*
method FieldMinVal(pcField, pxValue) class TWFFieldDef
	local rxValue := (::aFields[::FieldPos(pcField), TV_FIELDMINVAL])

	if pxValue != nil
		::aFields[::FieldPos(pcField), TV_FIELDMINVAL] := pxValue
	endif
	
return (rxValue)

// *--< Propriedade FieldMaxVal >----------------------------------------------*
method FieldMaxVal(pcField, pxValue) class TWFFieldDef
	local rxValue := (::aFields[::FieldPos(pcField), TV_FIELDMAXVAL])

	if pxValue != nil
		::aFields[::FieldPos(pcField), TV_FIELDMAXVAL] := pxValue
	endif
	
return (rxValue)

// *--< Propriedade ComboValues >---------------------------------------------*
method ComboValues(pcField, paValue) class TWFFieldDef
	local raValue := {}, nInd, nPos := ::FieldPos(pcField)
	                                     
	if ::aFields[nPos, TV_COMBOVALUES] <> NIL
		aCopy(::aFields[nPos, TV_COMBOVALUES], raValue)
	else                                             
		raValue := NIL
	endif

	if paValue != nil
		::aFields[nPos, TV_COMBOVALUES] := {}
		for nInd := 1 to len(paValue)
			aAdd(::aFields[nPos, TV_COMBOVALUES], paValue[nInd])
		next
	endif
	
return (raValue)

// *--< Propriedade Count >---------------------------------------------------*
method Count() class TWFFieldDef
return (len(::aFields))

// *--< Propriedade Events >--------------------------------------------------*
method Events(pcField, pcChange, pcBlur) class TWFFieldDef
	local raValue := (::aFields[::FieldPos(pcField), TV_EVENTS])

	if pcChange != nil .or. pcBlur != nil
		::aFields[::FieldPos(pcField), TV_EVENTS] := { pcChange, pcBlur }
	endif
	
return (raValue)

// *--< Monta o código JavaScript >--------------------------------------------*
method GetJSCode() class TWFFieldDef
	local aRet := {}, aCpos := {}, nCount, nInd, nInd2, cAux
	
	aAdd(aRet, '<script language="javaScript">')
	aAdd(aRet, 'var NIL = null;')
	aAdd(aRet, 'var LAST_ERROR = null;')
	aAdd(aRet, 'var GLOBAL_VALID_LIST = new Array();')
	aAdd(aRet, 'var GLOBAL_VALIDA = false;')
	aAdd(aRet, 'var GLOBAL_ERROR = false;')
	aAdd(aRet, 'var NS4 = (document.layers) ? 1 : 0; // Netscape 4+')
	aAdd(aRet, 'var IE4 = (document.all) ? 1 : 0;    // Explorer 4+')
	aAdd(aRet, 'var ver4 = (IE4 || NS4) ? 1 : 0;      // ver 4+')
	aAdd(aRet, 'function setColor(poElement, pcColor)')
	aAdd(aRet, '{')
	aAdd(aRet, '   if (poElement.style)')
	aAdd(aRet, '   {')
	aAdd(aRet, '     poElement.style.backgroundColor = pcColor;')
	aAdd(aRet, '   }')
	aAdd(aRet, '}')
	aAdd(aRet, 'function warning(poField, pcMsg)')
	aAdd(aRet, '{')
	aAdd(aRet, '   if (poField)')
	aAdd(aRet, '   {')
	aAdd(aRet, '      LAST_ERROR = poField;')
	aAdd(aRet, '      setColor(poField, "#ccccFF");')
	aAdd(aRet, '      if (GLOBAL_VALIDA == false)')
	aAdd(aRet, '      {')
	aAdd(aRet, '         if (poField.type.substring(0,1) != "s")')
	aAdd(aRet, '            poField.select();')
	aAdd(aRet, '         poField.focus();')
	aAdd(aRet, '      }')
	aAdd(aRet, '   }')
	aAdd(aRet, '   alert(pcMsg);')
	aAdd(aRet, '}')
	aAdd(aRet, 'function validValue(AValue, ACheckOK)')
	aAdd(aRet, '{')
	aAdd(aRet, '   var lRet = true;')
	aAdd(aRet, '   for (i = 0;  i < AValue.length;  i++)')
	aAdd(aRet, '      if (ACheckOK.indexOf(AValue.charAt(i)) == "-1")')
	aAdd(aRet, '      {')
	aAdd(aRet, '         lRet = false;')
	aAdd(aRet, '         break;')
	aAdd(aRet, '      }')
	aAdd(aRet, '   return (lRet);')
	aAdd(aRet, '}')
	aAdd(aRet, 'function doValidField(poField, pcCaption,  plRequired,  pcFieldType, pnFieldLen, pnDecimals, pxMinValue, pxMaxValue)')
	aAdd(aRet, '{')
	aAdd(aRet, '   var cValid = null;')
	aAdd(aRet, '   if (plRequired && (poField.value == "" || (poField.selectedIndex && poField.selectedIndex < 0)))')
	aAdd(aRet, '   {')
	aAdd(aRet, '      warning(poField, "' + STR0001 + ' \"" + pcCaption + "\" ' + ; //"O prenchimento do campo"
							STR0002 + '");') //"é obrigatório."
	aAdd(aRet, '      return (false);')
	aAdd(aRet, '   }')
	aAdd(aRet, '   if (pcFieldType == "A")')
	aAdd(aRet, '      cValid = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞßàáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ"')
	aAdd(aRet, '   else if (pcFieldType == "I")')
	aAdd(aRet, '      cValid = "0123456789-"')
	aAdd(aRet, '   else if (pcFieldType == "N")') 
	aAdd(aRet, '      cValid = "0123456789-."')
	aAdd(aRet, '   else if (pcFieldType == "D")')
	aAdd(aRet, '      cValid = "0123456789/"')
	aAdd(aRet, '   else if (pcFieldType == "P" || pcFieldType == "S" || pcFieldType == "C")')
	aAdd(aRet, '      cValid = null;')
	aAdd(aRet, '   if (cValid && !validValue(poField.value, cValid))')
	aAdd(aRet, '   {')
	aAdd(aRet, '      warning(poField, "' + STR0003 + ' \"" + pcCaption + "\", ' + ; //"O valor informado para"
							STR0004 + '\n' + ; //"é inválido."
							STR0005 + '\n" + cValid);') //"Caracteres válidos para este campo:"
	aAdd(aRet, '      return (false);')
	aAdd(aRet, '   }')
	aAdd(aRet, '   if (pcFieldType == "I" || pcFieldType == "N") ')
	aAdd(aRet, '   {')
	aAdd(aRet, '      var cValue = poField.value;')
	aAdd(aRet, '      var cPos = cValue.indexOf("-");')
	aAdd(aRet, '      if (cPos != "-1")')
	aAdd(aRet, '      {')
	aAdd(aRet, '         if ( cPos != cValue.lastIndexOf("-"))')
	aAdd(aRet, '         {')
	aAdd(aRet, '            warning(poField, "' + STR0003 + ' \"" + pcCaption + "\", ' + ; //"O valor informado para"
									STR0006 + ' \"-\".");') //"possue mais de uma ocorrência do sinal"
	aAdd(aRet, '            return (false);')
	aAdd(aRet, '         }')
	aAdd(aRet, '         if ( cPos != "0")')
	aAdd(aRet, '            poField.value = "-" + cValue.substring(0, cPos) + cValue.substring(cPos + 1, 255);')
	aAdd(aRet, '      }')
	aAdd(aRet, '      if (pcFieldType == "N")')
	aAdd(aRet, '      {')
	aAdd(aRet, '         var cValue = poField.value;')
	aAdd(aRet, '         var cPos = cValue.indexOf(".");')
	aAdd(aRet, '         if (cPos != "-1")')
	aAdd(aRet, '         {')
	aAdd(aRet, '            if ( cPos != cValue.lastIndexOf("."))')
	aAdd(aRet, '            {')
	aAdd(aRet, '               warning(poField, "' + STR0003 + ' \"" + pcCaption + "\", ' + ; //"O valor informado para"
										STR0007 + '");') //"possue mais de uma ocorrência do ponto decimal."
	aAdd(aRet, '               return (false);')
	aAdd(aRet, '            }')
	aAdd(aRet, '            var cDec = cValue.substring(cPos + 1, cValue.length);')
	aAdd(aRet, '            if (cDec.length > pnDecimals)')
	aAdd(aRet, '            {')
	aAdd(aRet, '              warning(poField, "' + STR0008 + ' \"" + pcCaption + "\", ' + ; //"O número de decimais informado para"
										STR0009 + ' " + pnDecimals + " ' + ; //"ultrapassa o limite de"
										STR0010 + '");') //"casas decimais."
	aAdd(aRet, '              return (false);')
	aAdd(aRet, '            }')
	aAdd(aRet, '         }')
	aAdd(aRet, '      }')
	aAdd(aRet, '   }')
	aAdd(aRet, '   if (pcFieldType == "D")')
	aAdd(aRet, '   {')
	aAdd(aRet, '      var cValue = poField.value;')
	aAdd(aRet, '      var cBarraDia = cValue.indexOf("/");')
	aAdd(aRet, '      var cBarraMes = cValue.lastIndexOf("/");')
	aAdd(aRet, '      if (cBarraDia == cBarraMes || cValue.length < 6)')
	aAdd(aRet, '      {')
	aAdd(aRet, '         warning(poField, "' + STR0003 + ' \"" + pcCaption + "\", ' + ; //"O valor informado para"
								STR0004 + '\n' + ; //"é inválido."
								STR0011 + '");') //"Use o formato DD/MM/YYYY."
	aAdd(aRet, '         return (false);')
	aAdd(aRet, '      }')
	aAdd(aRet, '      var cDia = cValue.substr(0, cBarraDia);')
	aAdd(aRet, '      var cMes = cValue.substr(cBarraDia + 1, cBarraMes - cBarraDia - 1);')
	aAdd(aRet, '      var cAno = cValue.substr(cBarraMes + 1, 4);')
	aAdd(aRet, '      if (cAno < 40)')
	aAdd(aRet, '         cAno = "20" + cAno')
	aAdd(aRet, '      else if (cAno.length == 2)')
	aAdd(aRet, '         cAno = "19" + cAno;')
	aAdd(aRet, '      cMes = parseInt(cMes,10);')
	aAdd(aRet, '      if (cMes < 1 || cMes > 12)')
	aAdd(aRet, '      {')
	aAdd(aRet, '         warning(poField, "' + STR0012 + ' \"" + pcCaption + "\", ' + ; //"O mês informado para"
								STR0004 + '");') //"é inválido."
	aAdd(aRet, '         return (false);')
	aAdd(aRet, '      }')
	aAdd(aRet, '      var aDaysMonth = new Array(-1, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31);')
	aAdd(aRet, '      var nMaxDays = aDaysMonth[ cMes ];')
	aAdd(aRet, '      if (cMes == 2)')
	aAdd(aRet, '      {')
	aAdd(aRet, '         if ((cAno % 4) != 0 || ((cAno % 400) != 0 && (cAno % 100) == 0))')
	aAdd(aRet, '            nMaxDays = 28;')
	aAdd(aRet, '      }')
	aAdd(aRet, '      if (cDia < 1 || cDia > nMaxDays )')
	aAdd(aRet, '      {')
	aAdd(aRet, '         warning(poField, "' + STR0013 + ' \"" + pcCaption + "\", ' + ; //"O dia informado para"
								STR0004 + '");') //"é inválido."
	aAdd(aRet, '         return (false);')
	aAdd(aRet, '      }')
	aAdd(aRet, '      strDia = "A" + (100+eval(cDia));')
	aAdd(aRet, '      strMes = "A" + (100+eval(cMes));')
	aAdd(aRet, '      poField.value = strDia.substr(2,2) +')
	aAdd(aRet, '                      "/" + strMes.substr(2,2) +')
	aAdd(aRet, '                      "/" + cAno;')
	aAdd(aRet, '   }')
	aAdd(aRet, '   if (pcFieldType == "P")')
	aAdd(aRet, '   {')
	aAdd(aRet, '      if (poField.selectedIndex == 0)')
	aAdd(aRet, '      {')
	aAdd(aRet, '         warning(poField, "' + STR0014 + ' \"" + pcCaption + "\", ' + ; //"A primeira opção do campo"
								STR0004 + '");') //"é inválido."
	aAdd(aRet, '         return (false);')
	aAdd(aRet, '      }')
	aAdd(aRet, '   }')
	aAdd(aRet, '   if (pxMinValue && poField.value < pxMinValue)')
	aAdd(aRet, '   {')
	aAdd(aRet, '      warning(poField, "' + STR0003 + ' \"" + pcCaption + "\", ' + ; //"O valor informado para"
							STR0015 + '\"" + pxMinValue + "\".");') //"é inferior a"
	aAdd(aRet, '      return (false);')
	aAdd(aRet, '   }')
	aAdd(aRet, '   if (pxMaxValue && poField.value > pxMaxValue)')
	aAdd(aRet, '   {')
	aAdd(aRet, '      warning(poField, "' + STR0003 + ' \"" + pcCaption + "\", ' + ; //"O valor informado para"
							STR0016 + ' \"" + pxMaxValue + "\".");') //"é superior a"
	aAdd(aRet, '      return (false);')
	aAdd(aRet, '   }')
	aAdd(aRet, '   LAST_ERROR = null;')
	aAdd(aRet, '   setColor(poField, "white");')
	aAdd(aRet, '   return (true);')
	aAdd(aRet, '}')
	aAdd(aRet, 'function validField(poField)')
	aAdd(aRet, '{')
	aAdd(aRet, '   var j;')
	aAdd(aRet, '   for (j=0; j < GLOBAL_VALID_LIST.length; j++)')
	aAdd(aRet, '   {')
	aAdd(aRet, '      var nPosFinal = GLOBAL_VALID_LIST[j][0].length;')
	aAdd(aRet, '      if (poField.name.substr(0, nPosFinal) == GLOBAL_VALID_LIST[j][0])')
	aAdd(aRet, '      {')
	aAdd(aRet, '        if (!(doValidField(poField, GLOBAL_VALID_LIST[j][1], GLOBAL_VALID_LIST[j][2], GLOBAL_VALID_LIST[j][3],GLOBAL_VALID_LIST[j][4], GLOBAL_VALID_LIST[j][5], GLOBAL_VALID_LIST[j][6],GLOBAL_VALID_LIST[j][7])))')
	aAdd(aRet, '        {')
	aAdd(aRet, '          GLOBAL_ERROR = true;')
	aAdd(aRet, '          return ( false );')
	aAdd(aRet, '        }')
	aAdd(aRet, '      }')
	aAdd(aRet, '   }')
	aAdd(aRet, '   return ( true );')
	aAdd(aRet, '}')
	aAdd(aRet, 'function doSubmit(poForm)')
	aAdd(aRet, '{')
	aAdd(aRet, '  var oElements = poForm.elements;')
	aAdd(aRet, '  var lRet = true;')
	aAdd(aRet, '  for (var i = 0;  i < oElements.length; i++)')
	aAdd(aRet, '  {')
	aAdd(aRet, '    if (!(oElements[i].type == "hidden"))')
	aAdd(aRet, '	{')
	aAdd(aRet, '      lRet = validField(oElements[i]);')
	aAdd(aRet, '      if (!lRet)')
	aAdd(aRet, '      {')
	aAdd(aRet, '	    oElements[i].focus();')
	aAdd(aRet, '        break;')
	aAdd(aRet, '      }')
	aAdd(aRet, '    }')
	aAdd(aRet, '  }')
	aAdd(aRet, '  return (lRet);')
	aAdd(aRet, '}')
	aAdd(aRet, '//if (NS4) { document.forms[0].captureEvents(Event.SUBMIT) }')
	aAdd(aRet, 'document.forms[0].onsubmit = function () { return(doSubmit(this)) };')
	aAdd(aRet, 'var oElements = document.forms[0];');
               
	nCount := -1
	for nInd := 1 to len(::aFields)                   
		if (::aFields[nInd, TV_READONLY])
			loop
		endif
		
		if (::aFields[nInd, TV_REQUIRED]) .or. ;
			(valType(::aFields[nInd, TV_FIELDTYPE]) <> "U") .or. ;
			(valType(::aFields[nInd, TV_FIELDLEN]) <> "U") .or. ;
			(valType(::aFields[nInd, TV_FIELDMINVAL]) <> "U") .or. ;
			(valType(::aFields[nInd, TV_FIELDMAXVAL]) <> "U") 
			aAdd(aCpos, asString(::aFields[nInd, TV_FIELD]))      
			nCount := nCount + 1
			aAdd(aRet, "GLOBAL_VALID_LIST[" + allTrim(str(nCount)) + '] = new Array(' + ;
							asString(::aFields[nInd, TV_FIELD], .t.) + "," + ;
							asString(::aFields[nInd, TV_CAPTION], .t.) + "," + ;
							iif(::aFields[nInd, TV_REQUIRED], "true", "false") + "," + ;
							asString(::aFields[nInd, TV_FIELDTYPE], .t.) + "," + ;
							asString(::aFields[nInd, TV_FIELDLEN], .t.) + "," + ;
							asString(::aFields[nInd, TV_FIELDDEC], .t.) + "," + ;
							asString(::aFields[nInd, TV_FIELDMINVAL], .t.) + "," + ;
							asString(::aFields[nInd, TV_FIELDMAXVAL], .t.) + ");")
		endif
	next
	
	for nInd := 1 to len(::aFields)                   
		if !empty(::aFields[nInd,TV_COMBOVALUES]) .and. len(::aFields[nInd,TV_COMBOVALUES]) > 0
			aAdd(aRet, 'for (var i = 0; i < oElements.length; i++)')
			aAdd(aRet, '{')
			aAdd(aRet, '   if (oElements[i].name.substr(0, '+ alltrim(str(len(::aFields[nInd, TV_FIELD])))+') == '+asString(::aFields[nInd, TV_FIELD],.t.)+')')
			aAdd(aRet, '   {')
			aAdd(aRet, '      if (oElements[i].type.substr(0, 6) == "select")')
			aAdd(aRet, '      {')
			
			cAux := ""
			
			for nInd2 := 1 to len( ::aFields[ nInd,TV_COMBOVALUES ] )
				cAux := space(8) + "oElements[i].add( new Option('"
				if ( nPos := At( "=", ::aFields[ nInd,TV_COMBOVALUES ][ nInd2 ] ) ) > 0
					cAux += Substr( ::aFields[ nInd,TV_COMBOVALUES ][ nInd2 ], nPos +1 )
					cAux += "','"
					cAux += Left( ::aFields[ nInd,TV_COMBOVALUES ][ nInd2 ], nPos -1 )
				else
					cAux += ::aFields[ nInd,TV_COMBOVALUES ][ nInd2 ]
					cAux += "','"
					cAux += ::aFields[ nInd,TV_COMBOVALUES ][ nInd2 ]
				end 
				aAdd(aRet,cAux + "')," + AllTrim( str(nInd2) ) + ");" )
			next
			aAdd(aRet, '      }')
			aAdd(aRet, '   }')
			aAdd(aRet, '}')
		endif
	next

	cLinha := ''
	
	for nInd := 1 to len(::aFields)                   
		if ::aFields[nInd, TV_READONLY]
         cLinha += asString(alltrim(::aFields[nInd, TV_FIELD]), .t.) + ','
         if len(cLinha) % 70 > 60		
         	cLinha += chr(13)+chr(10)+space(5)
         endif
  		endif
	next

	if !empty(cLinha)   
		cLinha := allTrim(cLinha)                     
		cLinha := substr(cLinha, 1,rAt(",",cLinha)-1)
		aAdd(aRet, 'var aReadOnly = new Array(' + cLinha + ');')
		aAdd(aRet, 'for (var cItem in aReadOnly)')
		aAdd(aRet, '{')
		aAdd(aRet, '  for (var i = 0; i < oElements.length; i++)')
		aAdd(aRet, '  {')
		aAdd(aRet, '    var oElement = oElements[i];')
		aAdd(aRet, '    if (oElement.name.substr(0, cItem.length) == cItem)')
		aAdd(aRet, '    {')
		aAdd(aRet, '      if (oElement.type != "hidden")')
		aAdd(aRet, '      {')
		aAdd(aRet, '        oElement.onfocus = function () { oElement.blur() };')
		aAdd(aRet, '      };')
		aAdd(aRet, '    };')
		aAdd(aRet, '  };')
		aAdd(aRet, '};')
	endif

	//aAdd(aRet, 'for (var i = 0; i < oElements.length; i++)')
	//aAdd(aRet, '{')
	//aAdd(aRet, '	if (!(oElements[i].type == "hidden"))')
	//aAdd(aRet, '	{')
	//aAdd(aRet, '   }')
	//aAdd(aRet, '}')

	aAdd(aRet, '</script>')
	aAdd(aRet, '<noscript>')
	aAdd(aRet, STR0017 ) //"Esta mensagem possui rotinas em JavaScript e seu navegador não consegue executá-las."
	aAdd(aRet, '<br>')
	aAdd(aRet, STR0018 ) //"Favor atualiza-lo para uma versão mais recente."
	aAdd(aRet, '</noscript>')
	
	cRet := ""
	aEval(aRet, {|x| cRet += x + chr(13) + chr(10)})
return (cRet)
