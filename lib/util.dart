import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class Util {
  static RelativeRect getPosition(
      BuildContext context, LongPressStartDetails details) {
    final RenderObject referenceBox = context.findRenderObject();
    var tapPosition = globalToLocal(referenceBox, details.globalPosition);

    final RenderObject button = context.findRenderObject();
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    return RelativeRect.fromRect(
      Rect.fromPoints(
        localToGlobal(button, tapPosition, ancestor: overlay),
        localToGlobal(button, tapPosition, ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
  }

  static Offset globalToLocal(RenderObject object, Offset point,
      {RenderObject ancestor}) {
    final Matrix4 transform = object.getTransformTo(ancestor);
    final double det = transform.invert();
    if (det == 0.0) return Offset.zero;
    final Vector3 n = Vector3(0.0, 0.0, 1.0);
    final Vector3 i = transform.perspectiveTransform(Vector3(0.0, 0.0, 0.0));
    final Vector3 d =
        transform.perspectiveTransform(Vector3(0.0, 0.0, 1.0)) - i;
    final Vector3 s =
        transform.perspectiveTransform(Vector3(point.dx, point.dy, 0.0));
    final Vector3 p = s - d * (n.dot(s) / n.dot(d));
    return Offset(p.x, p.y);
  }

  static Offset localToGlobal(RenderObject object, Offset point,
      {RenderObject ancestor}) {
    return MatrixUtils.transformPoint(object.getTransformTo(ancestor), point);
  }
  
  static final encodeMap = {
	  'а': 'a',
	  'б': 'b',
	  'в': 'v',
	  'г': 'g',
	  'д': 'd',
	  'е': 'e',
	  'ё': 'yo',
	  'ж': 'zh',
	  'з': 'z',
	  'и': 'i',
	  'й': 'j',
	  'к': 'k',
	  'л': 'l',
	  'м': 'm',
	  'н': 'n',
	  'о': 'o',
	  'п': 'p',
	  'р': 'r',
	  'с': 's',
	  'т': 't',
	  'у': 'u',
	  'ф': 'f',
	  'х': 'x',
	  'ц': 'c',
	  'ч': 'ch',
	  'ш': 'sh',
	  'щ': 'shh',
	  'ъ': '\'\'',
	  'ы': 'y\'',
	  'ь': '\'',
	  'э': 'e\'',
	  'ю': 'yu',
	  'я': 'ya',
	};

	static String tranlite(String text) {
	  return text.toLowerCase()
		  .split('')
		  .map((char) => encodeMap[char] ?? char)
		  .join();
	}
}
