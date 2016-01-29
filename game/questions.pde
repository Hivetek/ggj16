final int QUESTION_MARGIN = 10;
final int QUESTION_PADDING = 10;

ArrayList<Question> questions = new ArrayList<Question>();

class Question {
  String question;
  ArrayList<Answer> answers = new ArrayList<Answer>();
  
  Question(String question) {
    this.question = question;
  }
  
  boolean guess(int index) {
    if (0 <= index && index < answers.size()) {
      return answers.get(index).correct;
    }
    return false;
  }
  
  void addAnswer(String answerString, boolean correct) {
    Answer a = new Answer(answerString, correct);
    addAnswer(a);
  }
  void addAnswer(Answer a) {
    answers.add(a);
  }
  
  void draw() {
    int text_size = 12;
    int height = (answers.size() + 1) * text_size + 2*QUESTION_PADDING;
    int strokeW = 3;
    int xOffset = QUESTION_MARGIN + strokeW + QUESTION_PADDING;
    int yOffset = QUESTION_MARGIN + strokeW + QUESTION_PADDING + text_size;
    
    pushStyle();
    
    // Box
    stroke(204, 102, 0);
    strokeWeight(strokeW);
    fill(0);
    rect(QUESTION_MARGIN, QUESTION_MARGIN, screenWidth - QUESTION_MARGIN*2, height);
    
    // Question
    textSize(text_size);
    fill(50);
    
    text(question, xOffset, yOffset);
    
    // Answers
    
    for (int i = 0; i < answers.size(); i++) {
      Answer a = answers.get(i);
      text(a.answer, xOffset, yOffset + (i+1) * text_size);
    }
    
    popStyle();
  }
}

class Answer {
  String answer;
  boolean correct;
  
  Answer(String answer, boolean correct) {
    this.answer = answer;
    this.correct = correct;
  }
}

void initQuestions() {
  Question q;
  
  q = new Question("What is my favorite color?");
  q.addAnswer("Red", false);
  q.addAnswer("Green", true);
  q.addAnswer("Blue", true);
  questions.add(q);
}